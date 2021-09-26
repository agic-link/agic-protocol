// SPDX-License-Identifier: agpl-3.0

pragma solidity 0.8.4;

interface IAgicFundPool {

    function getBalanceOf() external view returns (uint256);

    function getTotalAmount() external view returns (uint256);

    function _transfer(uint256 amount, address payable to) external;

    function recordTransfer() external payable;
}
