// SPDX-License-Identifier: MIT

pragma solidity ^0.6.8;

import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/access/Ownable.sol";
import "./AaveSavingsProtocol.sol";

contract Agic is ERC20UpgradeSafe, OwnableUpgradeSafe {

    using SafeMath for uint256;

    //The pledge of the eth
    //质押的eth
    mapping(address => uint256) private _eth;

    //user => aaveContract
    mapping(address => address) _aaveContract;

    //Alternative construction method
    function initialize() public initializer {
        __ERC20_init("Automatically Generate Of Interest Coin", "AGIC");
        __Ownable_init();
    }

    modifier notZeroAddress(address _to) {
        require(_to != address(0), "transfer to the zero address");
        _;
    }

    function aaveProtocol(address owner) public view notZeroAddress(owner) returns (address){
        return _aaveContract[owner];
    }

    function ethOf(address owner) public view notZeroAddress(owner) returns (uint256){
        return _eth[owner];
    }

    function ethOfByAave(address owner) public view notZeroAddress(owner) returns (uint256){
        address aaveProtocolAddress = _aaveContract[msg.sender];
        if (aaveProtocolAddress == address(0)) {
            return 0;
        } else {
            AaveSavingsProtocol aave = AaveSavingsProtocol(aaveProtocolAddress);
            return aave.balanceOf();
        }
    }

    function addGas() public payable {
    }

    function totalEth() public view returns (uint256){
        return address(this).balance;
    }

    /// @dev Pledge eth in exchange for AGIC
    //质押的eth换成agic
    function deposit() public payable {
        uint256 eth = msg.value;
        uint256 agic = eth.mul(4);
        _eth[msg.sender] = _eth[msg.sender].add(eth);
        super._mint(msg.sender, agic);
        address aaveProtocolAddress = _aaveContract[msg.sender];
        AaveSavingsProtocol aave;
        if (aaveProtocolAddress == address(0)) {
            aave = new AaveSavingsProtocol(msg.sender, _addressToPayable(address(this)));
            _aaveContract[msg.sender] = address(aave);
        } else {
            aave = AaveSavingsProtocol(aaveProtocolAddress);
        }
        aave.deposit{value : eth.add(1e12)}(eth);
        emit Deposit(aaveProtocolAddress == address(0), eth, msg.sender);
    }

    //get 当前赚取的利息
    function interestAmount() public view returns (uint256){
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
        aave.redeem(amount.div(4));
        aave.withdrawal();
    }

    function _addressToPayable(address _address) private pure returns (address payable){
        return address(uint160(_address));
    }

    event Deposit(bool _new, uint256 _value, address _sender);

}