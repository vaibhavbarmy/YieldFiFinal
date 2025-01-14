
// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./YieldFiCollateral.sol";
import "./YieldFiFlashLoan.sol";
import "./YieldFiCalculations.sol";
import "./YieldFiAdmin.sol";
import "./ReentrancyGuard.sol";
import "./SafeERC20.sol";
import "./AggregatorV3Interface.sol";
import "./ILendingPool.sol";
import "./IAToken.sol";
import "./IDebtToken.sol";
import "./AToken.sol";
import "./DebtToken.sol";
import "./WadRayMath.sol";
import "./AToken.sol";
import "./DebtToken.sol";

contract YieldFiCore is ReentrancyGuard, YieldFiCollateral, YieldFiFlashLoan, YieldFiCalculations, YieldFiAdmin {
    using SafeERC20 for IERC20;
    using WadRayMath for uint256;

    uint256 public constant RAY = 1e27;

    mapping(address => uint256) public normalizedIncomeIndex; // New mapping for normalized income index

    mapping(address => address) public aTokenContracts;

    event Deposit(address indexed user, address indexed reserve, uint256 amount);
    event Withdraw(address indexed user, address indexed reserve, uint256 amount);
    event Borrow(address indexed user, address indexed reserve, uint256 amount);
    event Repay(address indexed user, address indexed reserve, uint256 amount);
    event InterestRateUpdated(address indexed reserve, uint256 liquidityRate, uint256 stableBorrowRate, uint256 variableBorrowRate);

    mapping(address => uint256) public totalSupply;

    constructor(
        address _ethOracle,
        address _wbtcOracle,
        address _lendingPoolAddress
    )
    YieldFiAdmin(_ethOracle, _wbtcOracle)
    YieldFiFlashLoan(_lendingPoolAddress)
    YieldFiCollateral(YieldFiAdmin(address(this)))
    YieldFiCalculations(YieldFiCollateral(address(this)), YieldFiFlashLoan(address(this)), YieldFiAdmin(address(this)))
    {}

    function deposit(address _reserve, uint256 _amount) external nonReentrant {
        require(_amount > 0, "Amount must be greater than zero");

        IERC20(_reserve).safeTransferFrom(msg.sender, address(this), _amount);
        updateState(_reserve);

        uint256 scaledAmount = _amount.rayDiv(normalizedIncomeIndex[_reserve]); // Use normalized income index
        userBalance[msg.sender][_reserve] += _amount;
        scaledUserBalance[msg.sender][_reserve] += scaledAmount;
        totalSupply[_reserve] += _amount;

        address aToken = aTokenContracts[_reserve];
        if (aToken == address(0)) {
            aToken = address(new AToken("Aave Token", "aToken", IERC20(_reserve).decimals(), _reserve, address(this)));
            aTokenContracts[_reserve] = aToken;
        }

        IAToken(aToken).mint(msg.sender, _amount);

        emit Deposit(msg.sender, _reserve, _amount);
    }

    function withdraw(address _reserve, uint256 _amount) external nonReentrant {
        require(_amount > 0, "Amount must be greater than zero");
        require(userBalance[msg.sender][_reserve] >= _amount, "Insufficient balance");

        updateState(_reserve);

        uint256 scaledAmount = _amount.rayDiv(normalizedIncomeIndex[_reserve]); // Use normalized income index
        userBalance[msg.sender][_reserve] -= _amount;
        scaledUserBalance[msg.sender][_reserve] -= scaledAmount;
        totalSupply[_reserve] -= _amount;

        address aToken = aTokenContracts[_reserve];
        require(aToken != address(0), "aToken not set");
        IAToken(aToken).burn(msg.sender, _amount);

        IERC20(_reserve).safeTransfer(msg.sender, _amount);

        emit Withdraw(msg.sender, _reserve, _amount);
    }

    function borrow(address _reserve, uint256 _amount) external nonReentrant {
        require(_amount > 0, "Amount must be greater than zero");
        require(totalBorrow[_reserve] + _amount <= totalSupply[_reserve], "Insufficient liquidity");

        updateState(_reserve);

        borrowBalance[msg.sender][_reserve] += _amount;
        principalBorrowBalance[msg.sender][_reserve] += _amount;
        totalBorrow[_reserve] += _amount;

        address variableDebtToken = variableDebtTokenContracts[_reserve];
        if (variableDebtToken == address(0)) {
            variableDebtToken = address(new DebtToken("Variable Debt Token", "vDebtToken", IERC20(_reserve).decimals(), _reserve, address(this)));
            variableDebtTokenContracts[_reserve] = variableDebtToken;
        }

        IDebtToken(variableDebtToken).mint(msg.sender, _amount);

        IERC20(_reserve).safeTransfer(msg.sender, _amount);

        emit Borrow(msg.sender, _reserve, _amount);
    }

    function repay(address _reserve, uint256 _amount) external nonReentrant {
        require(_amount > 0, "Amount must be greater than zero");
        require(borrowBalance[msg.sender][_reserve] >= _amount, "Insufficient borrow balance");

        IERC20(_reserve).safeTransferFrom(msg.sender, address(this), _amount);

        updateState(_reserve);

        uint256 scaledAmount = _amount.rayDiv(normalizedIncomeIndex[_reserve]); // Use normalized income index
        borrowBalance[msg.sender][_reserve] -= scaledAmount;
        principalBorrowBalance[msg.sender][_reserve] -= _amount;
        totalBorrow[_reserve] -= scaledAmount;

        address variableDebtToken = variableDebtTokenContracts[_reserve];
        require(variableDebtToken != address(0), "VariableDebtToken not set");

        IDebtToken(variableDebtToken).burn(msg.sender, _amount);

        emit Repay(msg.sender, _reserve, _amount);
    }

    function liquidate(address _borrower, address _reserve, uint256 _amount, address _collateral) external nonReentrant {
        require(_amount > 0, "Amount must be greater than zero");
        require(borrowBalance[_borrower][_reserve] >= _amount, "Insufficient borrow balance");
        require(isCollateralEnabled[_borrower][_collateral], "Collateral not enabled");

        uint256 healthFactor = calculateHealthFactor(_borrower);
        require(healthFactor < liquidationThresholds[_collateral], "Borrower is healthy");

        uint256 collateralAmount = calculateCollateralAmountToSeize(_reserve, _collateral, _amount);

        address collateralDebtToken = variableDebtTokenContracts[_collateral];
        require(collateralDebtToken != address(0), "Collateral DebtToken not set");

        IDebtToken(collateralDebtToken).safeTransferFrom(_borrower, msg.sender, collateralAmount);

        uint256 scaledAmount = _amount.rayDiv(normalizedIncomeIndex[_reserve]); // Use normalized income index
        borrowBalance[_borrower][_reserve] -= scaledAmount;
        principalBorrowBalance[_borrower][_reserve] -= _amount;
        totalBorrow[_reserve] -= scaledAmount;

        address variableDebtToken = variableDebtTokenContracts[_reserve];
        require(variableDebtToken != address(0), "VariableDebtToken not set");

        IDebtToken(variableDebtToken).burn(_borrower, _amount);

        emit Liquidate(_borrower, _reserve, _amount, _collateral, collateralAmount);
    }

    function updateState(address _reserve) internal {
        (
            ,
            uint128 liquidityIndex,
            uint128 variableBorrowIndex,
            uint128 currentLiquidityRate,
            uint128 currentVariableBorrowRate,
            ,
            uint40 lastUpdateTimestamp,
            address aTokenAddress,
            address variableDebtTokenAddress,
            ,
        ) = ILendingPool(lendingPoolAddress).getReserveData(_reserve);

        if (lastUpdateTimestamp == block.timestamp) {
            return;
        }

        cumulatedLiquidityIndex[_reserve] = uint256(liquidityIndex);
        cumulatedVariableBorrowIndex[_reserve] = uint256(variableBorrowIndex);

        // Update normalized income index
        uint256 newNormalizedIncomeIndex = normalizedIncomeIndex[_reserve].rayMul(uint256(currentLiquidityRate).rayDiv(RAY) + RAY);
        normalizedIncomeIndex[_reserve] = newNormalizedIncomeIndex;

        if (aTokenAddress == address(0)) {
            aTokenAddress = address(new AToken("Aave Token", "aToken", IERC20(_reserve).decimals(), _reserve, address(this)));
            aTokenContracts[_reserve] = aTokenAddress;
        }

        if (variableDebtTokenAddress == address(0)) {
            variableDebtTokenAddress = address(new DebtToken("Variable Debt Token", "vDebtToken", IERC20(_reserve).decimals(), _reserve, address(this)));
            variableDebtTokenContracts[_reserve] = variableDebtTokenAddress;
        }

        emit InterestRateUpdated(_reserve, currentLiquidityRate, 0, currentVariableBorrowRate);
    }
}