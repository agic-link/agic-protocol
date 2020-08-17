// SPDX-License-Identifier: MIT
pragma solidity ^0.6.8;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IAgicAddressesProvider.sol";
import "./interface/IAgicFundPool.sol";


contract AgicFundPool is IAgicFundPool{

    using SafeMath for uint256;

    uint256 private _thisAccountPeriodAmount;

    IAgicAddressesProvider private provider;

    constructor(address agicAddressesProvider) public {
        provider = IAgicAddressesProvider(agicAddressesProvider);
    }

    modifier inWhiteList(address _send){
        require(provider.verifyFundPoolWhiteList(_send), "AgicFundPool: This is not an address in the whitelist");
        _;
    }

    function getThisAccountPeriodAmount() public view override returns (uint256){
        return _thisAccountPeriodAmount;
    }

    function afterSettlement() public override inWhiteList(msg.sender) {
        _thisAccountPeriodAmount = 0;
    }

    function _transfer(uint256 amount, address payable to) public payable override inWhiteList(msg.sender) {
        to.transfer(amount);
    }

    function recordTransfer() public payable override {
        _thisAccountPeriodAmount = _thisAccountPeriodAmount.add(msg.value);
    }

    receive() external payable {}
}