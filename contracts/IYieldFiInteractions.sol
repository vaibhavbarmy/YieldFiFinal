// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

interface IYieldFiInteractions {
    function calculateHealthFactor(address _user) external view returns (uint256);
    function calculateCollateralValue(address _user, address _reserve) external view returns (uint256);
    function calculateBorrowValue(address _user, address _reserve) external view returns (uint256);
    function calculateCollateralAmountToSeize(address _reserve, address _collateral, uint256 _debtToCover) external view returns (uint256);
    function getAssetPrice(address _reserve) external view returns (uint256);
    function isCollateralEnabled(address _user, address _reserve) external view returns (bool);
    function borrowBalance(address _user, address _reserve) external view returns (uint256);
    function cumulatedVariableBorrowIndex(address _reserve) external view returns (uint256);
    function collateralFactors(address _reserve) external view returns (uint256);
    function priceOracle(address _reserve) external view returns (address);
    function liquidationThresholds(address _collateral) external view returns (uint256);
}