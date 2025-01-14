// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./WadRayMath.sol";
import "./IYieldFiInteractions.sol";
import "./IDebtToken.sol";
import "./IERC20.sol";
import "./YieldFiAdmin.sol";

contract YieldFiCollateral {
    using WadRayMath for uint256;

    YieldFiAdmin public yieldFiAdmin;
    address public yieldFiCore;

    mapping(address => mapping(address => bool)) public isCollateralEnabled;
    mapping(address => mapping(address => uint256)) public userBalance;
    mapping(address => mapping(address => uint256)) public borrowBalance;
    mapping(address => mapping(address => uint256)) public principalBorrowBalance;
    mapping(address => address) public variableDebtTokenContracts;
    mapping(address => uint256) public totalBorrow;
    mapping(address => uint256) public cumulatedVariableBorrowIndex;

    event UseAsCollateral(address indexed user, address indexed reserve, bool useAsCollateral);
    event RepayWithCollateral(address indexed user, address indexed reserve, uint256 amount, address indexed onBehalfOf);
    event DelegateBorrowingPower(address indexed user, address indexed to, address indexed reserve, uint256 amount);
    event Liquidate(address indexed borrower, address indexed reserve, uint256 amount, address indexed collateral, uint256 collateralAmount);

    constructor(YieldFiAdmin _admin) {
        yieldFiAdmin = _admin;
    }

    function useAsCollateral(address _reserve, bool _useAsCollateral) public {
        require(userBalance[msg.sender][_reserve] > 0, "No balance to use as collateral");

        isCollateralEnabled[msg.sender][_reserve] = _useAsCollateral;

        emit UseAsCollateral(msg.sender, _reserve, _useAsCollateral);
    }

    function repayWithCollateral(address _reserve, uint256 _amount, address _onBehalfOf) public {
        require(_amount > 0, "Amount must be greater than zero");
        require(borrowBalance[_onBehalfOf][_reserve] >= _amount, "Insufficient borrow balance");
        require(isCollateralEnabled[_onBehalfOf][_reserve], "Collateral not enabled");

        IDebtToken(variableDebtTokenContracts[_reserve]).safeTransferFrom(msg.sender, address(this), _amount);

        uint256 scaledAmount = _amount.rayDiv(cumulatedVariableBorrowIndex[_reserve]);
        borrowBalance[_onBehalfOf][_reserve] -= scaledAmount;
        principalBorrowBalance[_onBehalfOf][_reserve] -= scaledAmount;
        totalBorrow[_reserve] -= scaledAmount;

        IDebtToken(variableDebtTokenContracts[_reserve]).burn(_onBehalfOf, _amount);

        emit RepayWithCollateral(msg.sender, _reserve, _amount, _onBehalfOf);
    }

    function delegateBorrowingPower(address _to, address _reserve, uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than zero");
        require(borrowBalance[msg.sender][_reserve] >= _amount, "Insufficient borrow balance");

        borrowBalance[_to][_reserve] += _amount;
        borrowBalance[msg.sender][_reserve] -= _amount;

        emit DelegateBorrowingPower(msg.sender, _to, _reserve, _amount);
    }
}