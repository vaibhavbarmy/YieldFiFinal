// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./WadRayMath.sol";

contract YieldFiAdmin {
    using WadRayMath for uint256;

    uint256 public constant WAD = 1e18;

    mapping(address => uint256) public collateralFactors;
    mapping(address => uint256) public liquidationThresholds;
    mapping(address => uint256) public reserveFactors;
    mapping(address => address) public priceOracles;

    event CollateralFactorUpdated(address indexed reserve, uint256 collateralFactor);
    event LiquidationThresholdUpdated(address indexed reserve, uint256 liquidationThreshold);
    event ReserveFactorUpdated(address indexed reserve, uint256 reserveFactor);
    event OracleUpdated(address indexed reserve, address indexed oracle);

    constructor(
        address _ethOracle,
        address _wbtcOracle
    ) {
        priceOracles[address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeeeeEEeE)] = _ethOracle;
        priceOracles[address(0x2260FAC5E5542a773Aa44fBCfeDf7C11C599)] = _wbtcOracle;
    }

    function setCollateralFactor(address _reserve, uint256 _collateralFactor) external {
        require(_collateralFactor <= WAD, "Collateral factor must be less than or equal to 1");
        collateralFactors[_reserve] = _collateralFactor;
        emit CollateralFactorUpdated(_reserve, _collateralFactor);
    }

    function setLiquidationThreshold(address _reserve, uint256 _liquidationThreshold) external {
        require(_liquidationThreshold <= WAD, "Liquidation threshold must be less than or equal to 1");
        liquidationThresholds[_reserve] = _liquidationThreshold;
        emit LiquidationThresholdUpdated(_reserve, _liquidationThreshold);
    }

    function setReserveFactor(address _reserve, uint256 _reserveFactor) external {
        require(_reserveFactor <= WAD, "Reserve factor must be less than or equal to 1");
        reserveFactors[_reserve] = _reserveFactor;
        emit ReserveFactorUpdated(_reserve, _reserveFactor);
    }

    function setOracle(address _reserve, address _oracle) external {
        priceOracles[_reserve] = _oracle;
        emit OracleUpdated(_reserve, _oracle);
    }
}