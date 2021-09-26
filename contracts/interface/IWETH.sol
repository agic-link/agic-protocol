// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.4;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256) external;

    function approve(address to, uint value) external returns (bool);
}
