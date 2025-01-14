// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

interface IInterestRateStrategy {
    function calculateInterestRates(
        address reserve,
        uint256 availableLiquidity,
        uint256 totalStableDebt,
        uint256 totalVariableDebt,
        uint256 averageStableBorrowRate,
        uint256 reserveFactor
    ) external view returns (uint256, uint256, uint256);
}