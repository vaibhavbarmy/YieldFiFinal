// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./IERC20.sol";

interface IDebtToken is IERC20 {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
    function safeTransferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}