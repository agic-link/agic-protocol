// SPDX-License-Identifier: MIT
pragma solidity ^0.6.8;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";


contract AgicFundPool is Ownable {

    using SafeMath for uint256;

    uint256 private _thisAccountPeriodAmount;

    constructor() public Ownable() {}

    function getThisAccountPeriodAmount() public view returns (uint256){
        return _thisAccountPeriodAmount;
    }

    function afterSettlement() public onlyOwner {
        _thisAccountPeriodAmount = 0;
    }

    function _transfer(uint256 amount, address payable to) public payable onlyOwner {
        to.transfer(amount);
    }

    function receive() external payable {
        _thisAccountPeriodAmount = _thisAccountPeriodAmount.add(msg.value);
    }
}