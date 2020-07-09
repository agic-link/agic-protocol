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

    uint256 private _pledgeEth;

    constructor(address payable depositor, address payable referral) public {
        _depositor = depositor;
        _referral = referral;
        __Ownable_init();
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
        uint256 balanceOf = balanceOf();
        if (balanceOf > 0) {
            aToken.redeem(balanceOf);
        }
        uint256 balance = address(this).balance;
        if (balance > 0) {
            if (balance > _pledgeEth) {
                uint256 interest = balance.sub(_pledgeEth);
                uint256 serviceCharge = _mulDiv(interest, 3, 100);
                uint256 newBalance = balance.sub(serviceCharge);
                _depositor.transfer(newBalance);
                _referral.transfer(address(this).balance);
                emit LedgerAccount(interest, serviceCharge, newBalance);
            } else {
                _depositor.transfer(balance);
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