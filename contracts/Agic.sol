// SPDX-License-Identifier: MIT

pragma solidity ^0.6.8;

import "./interface/IERC20.sol";
import "./lib/Ownable.sol";
import "./lib/SafeMath.sol";

contract Agic is IERC20, Ownable {

    using SafeMath for uint256;

    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;

    //The pledge of the eth
    mapping(address => uint256) private _eth;

    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;

    string private _symbol;

    uint8 private _decimals;

    //The total amount of eth pledged
    uint256 private _totalEth;

    constructor() public {
        _name = "Automatically Generate Of Interest Coin";
        _symbol = "AGIC";
        _decimals = 18;
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

    function transfer(address to, uint256 amount) public override notZeroAddress(to) returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function balanceOf(address owner) public view override notZeroAddress(owner) returns (uint256){
        return _balances[owner];
    }

    function ethOf(address owner) public view notZeroAddress(owner) returns (uint256){
        return _eth[owner];
    }

    function allowance(address owner, address spender) public view override notZeroAddressDouble(owner, spender) returns (uint256){
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override notZeroAddress(spender) hasAmount(amount) returns (bool){
        _allowances[msg.sender][spender] = _allowances[msg.sender][spender].add(amount);
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool){
        _transfer(from, to, amount);
        _allowances[from][msg.sender] = _allowances[from][msg.sender].sub(amount);
        return true;
    }

    /// @dev Pledge eth in exchange for AGIC
    function buy() public payable returns (uint256) {
        uint256 eth = msg.value;
        uint256 amount = eth.mul(4);
        _totalEth = _totalEth.add(eth);
        _eth[msg.sender] = _eth[msg.sender].add(eth);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        return amount;
    }

    function redemption(uint256 amount) public payable hasAmount(amount) {


    }

    function _mint(address _account, uint256 _eth) private notZeroAddress(_account) {
        uint256 wzm = _eth * 4;
        _balances[_account] += wzm;
        _totalSupply += wzm;
        _eth += _eth;
    }

    function _burn(address payable _account, uint256 _amount) private notZeroAddress(_account) {
        _balances[_account] -= _amount;
        _totalSupply -= _amount;
        uint256 eth = _amount / 4;
        _eth -= eth;
    }

    function _transfer(address _sender, address _recipient, uint256 _amount) internal notZeroAddressDouble(_sender, _recipient) {
        _balances[_sender] = _balances[_sender].sub(_amount, "transfer amount exceeds balance");
        _balances[_recipient] = _balances[_recipient].add(_amount);
        emit Transfer(_sender, _recipient, _amount);
    }

}