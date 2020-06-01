// SPDX-License-Identifier: MIT

pragma solidity ^0.6.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "./AaveSavingsProtocol.sol";

contract Agic is ERC20, Ownable, Initializable {

    using SafeMath for uint256;

    //The pledge of the eth
    //质押的eth
    mapping(address => uint256) private _eth;

    //user => aaveContract
    mapping(address => address) _aaveContract;

    constructor() public ERC20(
        "Automatically Generate Of Interest Coin",
        "AGIC") {
    }

    modifier notZeroAddress(address _to) {
        require(_to != address(0), "transfer to the zero address");
        _;
    }

    function ethOf(address owner) public view notZeroAddress(owner) returns (uint256){
        return _eth[owner];
    }

    function totalEth() public view returns (uint256){
        return address(this).balance;
    }

    /// @dev Pledge eth in exchange for AGIC
    //质押的eth换成agic
    function deposit() public payable returns (uint256) {
        uint256 eth = msg.value;
        uint256 agic = eth.mul(4);
        _eth[msg.sender] = _eth[msg.sender].add(eth);
        super._mint(msg.sender, agic);
        address aaveProtocolAddress = _aaveContract[msg.sender];
        AaveSavingsProtocol aave;
        if (aaveProtocolAddress == address(0)) {
            aave = new AaveSavingsProtocol(msg.sender, _addressToPayable(owner()));
            _aaveContract[msg.sender] = address(aave);
        } else {
            aave = AaveSavingsProtocol(aaveProtocolAddress);
        }
        aave.deposit{value : eth}();
        return agic;
    }

    //get 当前赚取的利息
    function interestAmount() public returns (uint256){
        address aaveProtocolAddress = _aaveContract[msg.sender];
        if (aaveProtocolAddress == address(0)) {
            return 0;
        } else {
            AaveSavingsProtocol aave = AaveSavingsProtocol(aaveProtocolAddress);
            return aave.interestAmount();
        }
    }

    //赎回eth并获得利息
    function redeem(uint256 amount) public {
        address aaveProtocolAddress = _aaveContract[msg.sender];
        require(aaveProtocolAddress != address(0), "not have protocol");
        AaveSavingsProtocol aave = AaveSavingsProtocol(address(_aaveContract[msg.sender]));
        aave.redeem(amount);
        aave.withdrawal();
    }

    function _addressToPayable(address _address) private pure returns (address payable){
        return address(uint160(_address));
    }

}