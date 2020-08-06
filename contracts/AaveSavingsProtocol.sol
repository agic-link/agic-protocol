// SPDX-License-Identifier: MIT

pragma solidity ^0.6.8;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./constants/ConstantAddresses.sol";
import "./aave/ILendingPool.sol";
import "./aave/ILendingPoolAddressesProvider.sol";
import "./aave/IAToken.sol";

contract AaveSavingsProtocol is ConstantAddresses, Ownable {

    using SafeMath for uint256;

    //load aave contract
    ILendingPoolAddressesProvider provider = ILendingPoolAddressesProvider(AAVE_LENDING_POOL_ADDRESSES_PROVIDER);
    ILendingPool lendingPool = ILendingPool(provider.getLendingPool());
    IAToken aToken = IAToken(AAVE_ATOKEN_ETH);

    address payable private _depositor;

    address payable private _referral;

    constructor(address payable depositor, address payable referral) public Ownable() {
        _depositor = depositor;
        _referral = referral;
    }

    function deposit() public payable onlyOwner {
        lendingPool.deposit { value : msg.value} (AAVE_MARKET_ETH, msg.value, 0);
    }

    function balanceOf() public view onlyOwner returns (uint256){
        return aToken.balanceOf(address(this));
    }

    function transfer(address recipient, uint256 amount) external returns (bool){
        return aToken.transfer(recipient, amount);
    }

    function redeem(uint256 eth, uint256 serviceCharge) public onlyOwner {
        aToken.redeem(eth);
        uint256 addressBalance = address(this).balance;
        uint256 newBalance = addressBalance.sub(serviceCharge);
        _depositor.transfer(newBalance);
        if (serviceCharge > 0) {
            _referral.transfer(address(this).balance);
        }
    }

    receive() external payable {}

}