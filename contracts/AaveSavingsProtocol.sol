// SPDX-License-Identifier: MIT

pragma solidity ^0.6.8;

import "./aave/ILendingPool.sol";
import "./constants/ConstantAddresses.sol";
import "./lib/Ownable.sol";

contract AaveSavingsProtocol is ConstantAddresses, Ownable {

    //加载aave合约接口
    ILendingPool lendingPool = ILendingPool(AAVE_LENDING_POOL);

    constructor() public {

    }

    function deposit() payable onlyOwner {
        lendingPool.deposit(AAVE_MARKET_ETH, msg.value, referral);

    }

}