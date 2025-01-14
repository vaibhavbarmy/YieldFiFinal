// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./WadRayMath.sol";
import "./YieldFiCollateral.sol";
import "./YieldFiFlashLoan.sol";
import "./YieldFiAdmin.sol";
import "./AggregatorV3Interface.sol";
import "./IERC20.sol";

contract YieldFiCalculations {
    using WadRayMath for uint256;

    YieldFiCollateral public yieldFiCollateralInterface;
    YieldFiFlashLoan public yieldFiFlashLoanInterface;
    YieldFiAdmin public yieldFiAdminInterface;

    uint256 public constant WADNew = 1e18;
    mapping(address => mapping(address => uint256)) public scaledUserBalance;
    mapping(address => uint256) public cumulatedLiquidityIndex;

    constructor(
        YieldFiCollateral _collateral,
        YieldFiFlashLoan _flashLoan,
        YieldFiAdmin _admin
    ) {
        yieldFiCollateralInterface = _collateral;
        yieldFiFlashLoanInterface = _flashLoan;
        yieldFiAdminInterface = _admin;
    }

    function calculateHealthFactor(address _user) public view returns (uint256) {
        uint256 totalCollateralValue = 0;
        uint256 totalBorrowValue = 0;

        address[] memory reserves = yieldFiFlashLoanInterface.getAllReserves();

        for (uint256 i = 0; i < reserves.length; i++) {
            address reserve = reserves[i];
            if (yieldFiCollateralInterface.isCollateralEnabled(_user, reserve)) {
                uint256 collateralValue = calculateCollateralValue(_user, reserve);
                totalCollateralValue += collateralValue;
            }
            totalBorrowValue += calculateBorrowValue(_user, reserve);
        }

        if (totalBorrowValue == 0) {
            return type(uint256).max;
        }

        return (totalCollateralValue * WADNew) / totalBorrowValue;
    }

    function calculateCollateralValue(address _user, address _reserve) internal view returns (uint256) {
        uint256 scaledBalance = scaledUserBalance[_user][_reserve];
        uint256 liquidityIndex = cumulatedLiquidityIndex[_reserve];
        uint256 price = getAssetPrice(_reserve);
        uint256 collateralFactor = yieldFiAdminInterface.collateralFactors(_reserve);

        return (scaledBalance * liquidityIndex * price * collateralFactor) / (WADNew * WADNew);
    }

    function calculateBorrowValue(address _user, address _reserve) internal view returns (uint256) {
        uint256 borrowBalance = yieldFiCollateralInterface.borrowBalance(_user, _reserve);
        uint256 variableBorrowIndex = yieldFiCollateralInterface.cumulatedVariableBorrowIndex(_reserve);
        uint256 price = getAssetPrice(_reserve);
        return (borrowBalance * variableBorrowIndex * price) / WADNew;
    }

    function calculateCollateralAmountToSeize(
        address _reserve,
        address _collateral,
        uint256 _debtToCover
    ) public view returns (uint256) {
        uint256 collateralPrice = getAssetPrice(_collateral);
        uint256 debtPrice = getAssetPrice(_reserve);
        uint256 collateralDecimals = IERC20(_collateral).decimals();
        uint256 debtDecimals = IERC20(_reserve).decimals();
        uint256 maxCollateralToSeize = (_debtToCover * debtPrice * 10**collateralDecimals) / (collateralPrice * debtDecimals * yieldFiAdminInterface.liquidationThresholds(_collateral)) / WADNew;
        return maxCollateralToSeize;
    }

    function getAssetPrice(address _reserve) internal view returns (uint256) {
        AggregatorV3Interface oracle = AggregatorV3Interface(yieldFiAdminInterface.priceOracles(_reserve));
        (, int256 price, , , ) = oracle.latestRoundData();
        return uint256(price);
    }
}