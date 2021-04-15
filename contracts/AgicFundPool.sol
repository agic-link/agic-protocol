// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IAgicAddressesProvider.sol";
import "./interface/IAgicFundPool.sol";

contract AgicFundPool is IAgicFundPool {

    using SafeMath for uint256;

    IAgicAddressesProvider private _provider;

    uint256 private _balanceOf;

    uint256 private _totalAmount;

    constructor(address agicAddressesProvider) public {
        _provider = IAgicAddressesProvider(agicAddressesProvider);
    }

    modifier inWhiteList(address sender){
        require(_provider.verifyFundPoolWhiteList(sender), "AFP: This is not an address in the whitelist");
        _;
    }

    function getBalanceOf() public view override returns (uint256){
        return _balanceOf;
    }

    function getTotalAmount() public view override returns (uint256){
        return _totalAmount;
    }

    function _transfer(uint256 amount, address payable to) public override inWhiteList(msg.sender) {
        _balanceOf = address(this).balance;
        require(_balanceOf >= amount, "AFP: pool not have must balance");
        to.transfer(amount);
    }

    function recordTransfer() public payable override {
        _balanceOf = _balanceOf.add(msg.value);
        _totalAmount = _totalAmount.add(msg.value);
    }

    receive() external payable {}
}