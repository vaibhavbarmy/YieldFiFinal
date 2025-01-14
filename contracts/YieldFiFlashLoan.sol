// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./IFlashLoanReceiver.sol";
import "./ILendingPool.sol";
import "./SafeERC20.sol";

contract YieldFiFlashLoan is IFlashLoanReceiver {
    using SafeERC20 for IERC20;

    address public lendingPoolAddress;

    constructor(address _lendingPoolAddress) {
        lendingPoolAddress = _lendingPoolAddress;
    }

    event FlashLoan(address indexed user, address indexed reserve, uint256 amount);

    function flashLoan(address _receiver, address _reserve, uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");

        address[] memory assets = new address[](1);
        assets[0] = _reserve;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = _amount;
        uint256[] memory modes = new uint256[](1);
        modes[0] = 0;

        ILendingPool(lendingPoolAddress).flashLoan(_receiver, assets, amounts, modes, msg.sender, "", 0);

        emit FlashLoan(msg.sender, _reserve, _amount);
    }

    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata
    ) external override returns (bool) {
        for (uint256 i = 0; i < assets.length; i++) {
            uint256 totalDebt = amounts[i] + premiums[i];
            require(IERC20(assets[i]).balanceOf(address(this)) >= totalDebt, "Flashloan not repaid");

            IERC20(assets[i]).safeTransfer(initiator, totalDebt);
        }

        return true;
    }

    function getAllReserves() public view returns (address[] memory) {
        return ILendingPool(lendingPoolAddress).getReservesList();
    }
}