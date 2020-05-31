// SPDX-License-Identifier: MIT

pragma solidity ^0.6.8;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "./constants/ConstantAddresses.sol";
import "./aave/ILendingPool.sol";
import "./aave/ILendingPoolAddressesProvider.sol";
import "./aave/IAToken.sol";

contract AaveSavingsProtocol is ConstantAddresses, Ownable {

    using SafeMath for uint256;

    //加载aave合约接口
    ILendingPoolAddressesProvider provider = ILendingPoolAddressesProvider(AAVE_LENDING_POOL_ADDRESSES_PROVIDER);
    ILendingPool lendingPool = ILendingPool(provider.getLendingPool());
    IAToken aToken = IAToken(AAVE_ATOKEN_ETH);

    address payable private _depositor;

    address payable private _referral;

    uint256 private _depositEth;

    uint256 private _balanceOfEth;

    constructor(address payable depositor, address payable referral) public {
        _depositor = depositor;
        _referral = referral;
    }

    function deposit() public payable onlyOwner {
        uint256 eth = msg.value;
        lendingPool.deposit { value : eth} (AAVE_MARKET_ETH, eth, 0);
        _depositEth = _depositEth.add(eth);
    }

    function balanceOf() public onlyOwner returns (uint256){
        _balanceOfEth = aToken.balanceOf(_depositor);
        return _balanceOfEth;
    }

    function interestAmount() public onlyOwner returns (uint256){
        balanceOf();
        return _balanceOfEth.sub(_depositEth);
    }

    function redeem(uint256 _amount) public onlyOwner {
        balanceOf();
        require(_balanceOfEth > _amount, "not have so much balance");
        aToken.redeem(_amount);
    }

    function withdrawal() public onlyOwner {
        uint256 balance = address(this).balance;
        // service charge
        uint256 amount = balance - 100;
        _depositor.transfer(amount);
        address payable owner = address(uint160(owner()));
        owner.transfer(100);
    }

}