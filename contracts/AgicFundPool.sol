// SPDX-License-Identifier: MIT
pragma solidity ^0.6.8;

import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/access/Ownable.sol";


contract AgicFundPool is OwnableUpgradeSafe {

    using SafeMath for uint256;

    uint256 private _thisAccountPeriodAmount;

    constructor() public {
        __Ownable_init();
    }

    function getThisAccountPeriodAmount() public view returns (uint256){
        return _thisAccountPeriodAmount;
    }

    function afterSettlement() public onlyOwner {
        _thisAccountPeriodAmount = 0;
    }

    function _transfer(uint256 amount, address payable to) public payable onlyOwner {
        to.transfer(amount);
    }

    receive() external payable {
        _thisAccountPeriodAmount = _thisAccountPeriodAmount.add(msg.value);
    }
}