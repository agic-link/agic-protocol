// SPDX-License-Identifier: MIT

pragma solidity ^0.6.8;

import "./interface/IERC20.sol";
import "../lib/Ownable.sol";

contract WzmCoin is IERC20, Ownable {

    //20的本质是质押eth根据设定比例生成的token，所以总量在最开始的时候是0
    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;

    //谁委托到谁多少币
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;

    string private _symbol;

    uint8 private _decimals;

    uint256 private _eth;

    constructor() public {
        _name = "Wzm Coin";
        _symbol = "WC";
        _decimals = 18;
    }

    modifier notZero(address _to) {
        require(_to != address(0), "transfer to the zero address");
        _;
    }

    modifier notZeroDouble(address _from, address _to) {
        require(_from != address(0), "transfer from the zero address");
        require(_to != address(0), "transfer to the zero address");
        _;
    }

    modifier hasMoney(uint256 _value) {
        require(_balances[msg.sender] > _value, "not have this money");
        _;
    }

    function totalSupply() public view override returns (uint256){
        return _totalSupply;
    }

    function name() public view returns (string memory){
        return _name;
    }

    function symbol() public view returns (string memory){
        return _symbol;
    }

    function decimals() public view returns (uint8){
        return _decimals;
    }

    function transfer(address _to, uint256 _value) public override notZero(_to) hasMoney(_value) returns (bool) {
        _balances[msg.sender] -= _value;
        _balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view override notZero(_owner) returns (uint256){
        return _balances[_owner];
    }

    function allowance(address _owner, address _spender) public view override notZeroDouble(_owner, _spender) returns (uint256){
        return _allowances[_owner][_spender];
    }

    function approve(address _spender, uint256 _value) public override notZero(_spender) hasMoney(_value) returns (bool){
        _allowances[msg.sender][_spender] += _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override notZeroDouble(_from, _to) returns (bool){
        require(_allowances[_from][msg.sender] > _value, "Not so much allowance");
        require(_balances[_from] > _value, "not have this money");
        _balances[_from] -= _value;
        _balances[_to] += _value;
        _allowances[_from][msg.sender] -= _value;
        return true;
    }

    function buy() public payable {
        uint256 eth = msg.value;
        _mint(msg.sender, eth);
    }

    function redemption(uint256 amount) public payable hasMoney(amount){
        _burn(msg.sender, amount);
        msg.sender.transfer(amount / 4);
    }

    function _mint(address account, uint256 eth) private notZero(account) {
        uint256 wzm = eth * 4;
        _balances[account] += wzm;
        _totalSupply += wzm;
        _eth += eth;
    }

    function _burn(address payable account, uint256 value) private notZero(account) {
        _balances[account] -= value;
        _totalSupply -= value;
        uint256 eth = value / 4;
        _eth -= eth;
    }

}