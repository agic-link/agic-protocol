// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IAgicAddressesProvider.sol";
import "./interface/IAgicFundPool.sol";


contract AgicFundPool is IAgicFundPool {

    using SafeMath for uint256;

    uint256 private _thisAccountPeriodAmount;

    uint256 private _lastAccountPeriodAmount;

    IAgicAddressesProvider private provider;

    constructor(address agicAddressesProvider) public {
        provider = IAgicAddressesProvider(agicAddressesProvider);
    }

    modifier inWhiteList(address _sender){
        require(provider.verifyFundPoolWhiteList(_sender), "AFP: This is not an address in the whitelist");
        _;
    }

    function getThisAccountPeriodAmount() public view override returns (uint256){
        return _thisAccountPeriodAmount;
    }

    function getLastAccountPeriodAmount() public view override returns (uint256){
        return _lastAccountPeriodAmount;
    }

    function afterSettlement() public override inWhiteList(msg.sender) {
        uint256 thisAccountPeriodAmount = _thisAccountPeriodAmount;
        _lastAccountPeriodAmount = thisAccountPeriodAmount;
        _thisAccountPeriodAmount = 0;
    }

    function _transfer(uint256 amount, address payable to) public override inWhiteList(msg.sender) {
        require(getBalance() >= amount, "AFP: pool not have must balance");
        to.transfer(amount);
    }

    function recordTransfer() public payable override {
        _thisAccountPeriodAmount = _thisAccountPeriodAmount.add(msg.value);
    }

    function getBalance() public view returns (uint256){
        return address(this).balance;
    }

    receive() external payable {}
}