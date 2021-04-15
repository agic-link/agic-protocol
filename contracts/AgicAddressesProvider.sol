// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.6.12;

import "./interface/IAgicAddressesProvider.sol";
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

    mapping(address => uint256) private _whiteListIndex;

    address[] private _whiteList;

    constructor() public {
        _whiteList.push();
    }

    function getAgicFundPoolWhiteList() public view override returns (address[] memory){
        return _whiteList;
    }

    function verifyFundPoolWhiteList(address aecAddress) override public view returns (bool){
        return _whiteListIndex[aecAddress] != 0;
    }

    function addAgicFundPoolWhiteList(address aecAddress) public override onlyOwner {
        require(_whiteListIndex[aecAddress] == 0, "Address already exists");
        _whiteListIndex[aecAddress] = _whiteList.length;
        _whiteList.push(aecAddress);
    }

    function subAgicFundPoolWhiteList(address aecAddress) public override onlyOwner {
        uint256 index = _whiteListIndex[aecAddress];
        if (index != 0) {
            delete _whiteList[index];
            delete _whiteListIndex[aecAddress];
            _whiteList.pop();
        }
    }

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
        subAgicFundPoolWhiteList(_agicEquityCard);
        addAgicFundPoolWhiteList(agicEquityCard);
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