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

    uint256 private _pledgeEth;

    constructor(address payable depositor, address payable referral) public Ownable() {
        _depositor = depositor;
        _referral = referral;
    }

    function deposit() public payable onlyOwner {
        uint256 amount = msg.value;
        _pledgeEth = _pledgeEth.add(amount);
        lendingPool.deposit { value : amount} (AAVE_MARKET_ETH, amount, 0);
    }

    function balanceOf() public view onlyOwner returns (uint256){
        return aToken.balanceOf(address(this));
    }

    function transfer(address recipient, uint256 amount) external returns (bool){
        return aToken.transfer(recipient, amount);
    }

    function interestAmount() public view onlyOwner returns (uint256){
        return balanceOf().sub(_pledgeEth);
    }

    function getPledgeEth() public view onlyOwner returns (uint256){
        return _pledgeEth;
    }

    function redeem() public onlyOwner {
        uint256 userBalance = balanceOf();
        if (userBalance > 0) {
            aToken.redeem(userBalance);
        }
        uint256 addressBalance = address(this).balance;
        if (addressBalance > 0) {
            if (addressBalance > _pledgeEth) {
                uint256 interest = addressBalance.sub(_pledgeEth);
                uint256 serviceCharge = interest.div(10);
                uint256 newBalance = addressBalance.sub(serviceCharge);
                _depositor.transfer(newBalance);
                _referral.transfer(address(this).balance);
                emit LedgerAccount(interest, serviceCharge, newBalance);
            } else {
                _depositor.transfer(addressBalance);
            }
            _pledgeEth = 0;
        }
    }

    function _mulDiv(uint256 a, uint256 b, uint256 c) private pure returns (uint256){
        return a.mul(c).div(b);
    }

    event LedgerAccount(uint256 interest, uint256 serviceCharge, uint256 balance);

    receive() external payable {}

}