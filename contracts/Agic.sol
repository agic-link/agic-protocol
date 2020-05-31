// SPDX-License-Identifier: MIT

pragma solidity ^0.6.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "./AaveSavingsProtocol.sol";

contract Agic is ERC20, ERC20Detailed, Ownable {

    using SafeMath for uint256;

    //The pledge of the eth
    //质押的eth
    mapping(address => uint256) private _eth;

    //user => aaveContract
    mapping(address => address) _aaveContract;

    //The total amount of eth pledged
    //总共质押的eth
    uint256 private _totalEth;

    constructor() public ERC20Detailed(
        "Automatically Generate Of Interest Coin",
        "AGIC",
        18) {
    }

    modifier notZeroAddress(address _to) {
        require(_to != address(0), "transfer to the zero address");
        _;
    }

    modifier notZeroAddressDouble(address _from, address _to) {
        require(_from != address(0), "transfer from the zero address");
        require(_to != address(0), "transfer to the zero address");
        _;
    }

    modifier hasAmount(uint256 _amount) {
        require(_balances[msg.sender] > _amount, "not have this amount");
        _;
    }

    function ethOf(address owner) public view notZeroAddress(owner) returns (uint256){
        return _eth[owner];
    }

    /// @dev Pledge eth in exchange for AGIC
    //质押的eth换成agic
    function deposit() public payable returns (uint256) {
        uint256 eth = msg.value;
        uint256 agic = eth.mul(4);
        _totalEth = _totalEth.add(eth);
        _eth[msg.sender] = _eth[msg.sender].add(eth);
        super._mint(msg.sender, agic);
        AaveSavingsProtocol aave = new AaveSavingsProtocol(msg.sender, owner());
        _aaveContract[msg.sender] = address(aave);
        aave.deposit{value : eth}();
        return agic;
    }

    function redeem(uint256 amount) public payable hasAmount(amount) {

    }

}