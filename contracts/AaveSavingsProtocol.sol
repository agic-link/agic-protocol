// SPDX-License-Identifier: MIT

pragma solidity ^0.6.8;

import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/access/Ownable.sol";
import "./constants/ConstantAddresses.sol";
import "./aave/ILendingPool.sol";
import "./aave/ILendingPoolAddressesProvider.sol";
import "./aave/IAToken.sol";

contract AaveSavingsProtocol is ConstantAddresses, OwnableUpgradeSafe {

    using SafeMath for uint256;

    //加载aave合约接口
    ILendingPoolAddressesProvider provider = ILendingPoolAddressesProvider(AAVE_LENDING_POOL_ADDRESSES_PROVIDER);
    ILendingPool lendingPool = ILendingPool(provider.getLendingPool());
    IAToken aToken = IAToken(AAVE_ATOKEN_ETH);

    address payable private _depositor;

    address payable private _referral;

    uint256 private _depositEth;

    uint256 private _balanceOfEth;

    uint256 private _gas = 1e12;

    constructor(address payable depositor, address payable referral) public {
        _depositor = depositor;
        _referral = referral;
        __Ownable_init();
    }

    function deposit(uint256 amount) public payable onlyOwner {
        uint256 eth = msg.value;
        uint256 gasAmount = eth.sub(amount);
        lendingPool.deposit { value : amount} (AAVE_MARKET_ETH, eth, 0);
        _depositEth = _depositEth.add(eth);
    }

    function balanceOf() public view onlyOwner returns (uint256){
        if (address(aToken) == address(0)) {
            return 0;
        }
        return aToken.balanceOf(_depositor);
    }

    function interestAmount() public view onlyOwner returns (uint256){
        return balanceOf().sub(_depositEth);
    }

    function redeem(uint256 _amount) public onlyOwner {
        require(balanceOf() >= _amount, "not have so much balance");
        aToken.redeem(_amount);
    }

    function withdrawal() public onlyOwner {
        uint256 balance = address(this).balance;
        // service charge
        uint256 amount = balance - 1e7;
        _depositor.transfer(amount);
        _referral.transfer(1e7);
    }

}