// SPDX-License-Identifier: MIT

pragma solidity ^0.6.8;

interface IAgicFundPool {

    function getThisAccountPeriodAmount() external view returns (uint256);

    function getLastAccountPeriodAmount() external view returns (uint256);

    function afterSettlement() external;

    function _transfer(uint256 amount, address payable to) external;

    function recordTransfer() external payable;
}