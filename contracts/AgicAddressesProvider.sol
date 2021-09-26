// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.4;

import "./interface/IAgicAddressesProvider.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
@title AgicAddressesProvider interface
@notice provides the interface to fetch the Agic address
 */

contract AgicAddressesProvider is IAgicAddressesProvider, Ownable {

    address payable private _agicFundPool;

    address private _agic;

    address private _agicInterestCard;

    address private _extendAddressesProvider;

    mapping(address => uint256) private _whiteListIndex;

    address[] private _whiteList;

    constructor() {
        _whiteList.push();
    }

    function getAgicFundPoolWhiteList() public view override returns (address[] memory){
        return _whiteList;
    }

    function verifyFundPoolWhiteList(address aicAddress) override public view returns (bool){
        return _whiteListIndex[aicAddress] != 0;
    }

    function addAgicFundPoolWhiteList(address aicAddress) public override onlyOwner {
        require(_whiteListIndex[aicAddress] == 0, "Address already exists");
        _whiteListIndex[aicAddress] = _whiteList.length;
        _whiteList.push(aicAddress);
    }

    function subAgicFundPoolWhiteList(address aicAddress) public override onlyOwner {
        uint256 index = _whiteListIndex[aicAddress];
        if (index != 0) {
            delete _whiteList[index];
            delete _whiteListIndex[aicAddress];
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

    function getAgicInterestCard() public view override returns (address){
        return _agicInterestCard;
    }

    function setAgicInterestCard(address agicInterestCard) public override onlyOwner {
        _agicInterestCard = agicInterestCard;
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
