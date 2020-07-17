// SPDX-License-Identifier: MIT
pragma solidity ^0.6.8;

import "../interface/IAgicAddressesProvider.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
@title AgicAddressesProvider interface
@notice provides the interface to fetch the Agic address
 */

contract AgicAddressesProvider is IAgicAddressesProvider, Ownable {

    address payable private _agicFundPool;

    address private _agic;

    address private _agicEquityCard;

    address private _extendAddressesProvider;

    function getAgicFundPool() public view override returns (address payable){
        return _agicFundPool;
    }

    function setAgicFundPool(address payable pool) public override onlyOwner {
        _agicFundPool = pool;
    }

    function getAgic() public view override returns (address){
        return _agic;
    }

    function setAgic(address agic) public override onlyOwner {
        _agic = agic;
    }

    function getAgicEquityCard() public view override returns (address){
        return _agicEquityCard;
    }

    function setAgicEquityCard(address agicEquityCard) public override onlyOwner {
        _agicEquityCard = agicEquityCard;
    }

    //Not used yet
    function getExtendAddressesProvider() public view override returns (address){
        return _extendAddressesProvider;
    }

    //Not used yet
    function setExtendAddressesProvider(address extend) public override onlyOwner {
        _extendAddressesProvider = extend;
    }


}