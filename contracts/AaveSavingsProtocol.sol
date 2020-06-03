// SPDX-License-Identifier: MIT

pragma solidity ^0.6.8;

import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/access/Ownable.sol";
import "./constants/ConstantAddresses.sol";
import "./aave/ILendingPool.sol";
import "./aave/ILendingPoolAddressesProvider.sol";
import "./aave/IAToken.sol";
import "./Agic.sol";

contract AaveSavingsProtocol is ConstantAddresses, OwnableUpgradeSafe {

    using SafeMath for uint256;

    //加载aave合约接口
    ILendingPoolAddressesProvider provider = ILendingPoolAddressesProvider(AAVE_LENDING_POOL_ADDRESSES_PROVIDER);
    ILendingPool lendingPool = ILendingPool(provider.getLendingPool());
    IAToken aToken = IAToken(AAVE_ATOKEN_ETH);

    address payable private _depositor;

    address payable private _referral;

    constructor(address payable depositor, address payable referral) public {
        _depositor = depositor;
        _referral = referral;
        __Ownable_init();
    }

    function deposit() public payable onlyOwner {
        uint256 amount = msg.value;
        lendingPool.deposit { value : amount} (AAVE_MARKET_ETH, amount, 0);
    }

    function principalBalanceOf() public view returns (uint256){
        return aToken.principalBalanceOf(_depositor);
    }

    function balanceOf() public view onlyOwner returns (uint256){
        return aToken.balanceOf(address(this));
    }

    function interestAmount() public view onlyOwner returns (uint256){
        return balanceOf().sub(principalBalanceOf());
    }

    function redeem(uint256 _amount) public onlyOwner {
        require(balanceOf() >= _amount, "not have so much balance");
        aToken.redeem(_amount);
    }

    function withdrawal() public onlyOwner {
        uint256 balance = address(this).balance;
        // service charge
        _depositor.transfer(_mulDiv(balance, 97, 100));
        _referral.transfer(_mulDiv(balance, 3, 100));
    }

    function _mulDiv(uint256 a, uint256 b, uint256 c) private returns (uint256){
        return a.mul(c).div(b);
    }

receive() external payable {}

}