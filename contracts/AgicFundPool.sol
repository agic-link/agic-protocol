// SPDX-License-Identifier: MIT
pragma solidity ^0.6.8;

import "@openzeppelin/contracts/access/Ownable.sol";

contract AgicFundPool is Ownable {

    constructor() Ownable{}

    function _transfer(uint256 amount, address payable to) public payable onlyOwner {
        to.transfer(amount);
    }

    receive() external payable {}

}