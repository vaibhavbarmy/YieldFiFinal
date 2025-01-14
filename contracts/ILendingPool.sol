// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

interface ILendingPool {
    function flashLoan(
        address receiverAddress,
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata modes,
        address onBehalfOf,
        bytes calldata params,
        uint16 referralCode
    ) external;

    function getReserveData(address asset)
    external
    view
    returns (
        uint256 configuration,
        uint128 liquidityIndex,
        uint128 variableBorrowIndex,
        uint128 currentLiquidityRate,
        uint128 currentVariableBorrowRate,
        uint128 currentStableBorrowRate,
        uint40 lastUpdateTimestamp,
        address aTokenAddress,
        address variableDebtTokenAddress,
        address interestRateStrategyAddress,
        uint8 id
    );

    function getReservesList() external view returns (address[] memory);
}
interface IYieldFiFlashLoanInterface {
    function lendingPoolAddress() external view returns (address);
}