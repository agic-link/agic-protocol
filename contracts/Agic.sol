// SPDX-License-Identifier: MIT

pragma solidity ^0.6.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./AaveSavingsProtocol.sol";
import "./interface/IAgicAddressesProvider.sol";

contract Agic is ERC20, Ownable {

    using SafeMath for uint256;

    uint256 private _totalPledgeEth;

    //user => aaveContract
    mapping(address => address) _aaveContract;

    address private _agicAddressesProvider;

    IAgicAddressesProvider private provider;

    constructor (address agicAddressesProvider) public ERC20("Automatically Generate Of Interest Coin", "AGIC") Ownable(){
        provider = IAgicAddressesProvider(agicAddressesProvider);
    }

    modifier notZeroAddress(address _to) {
        require(_to != address(0), "transfer from the zero address");
        _;
    }

    function invalidAaveProtocol() public {
        _aaveContract[msg.sender] = address(0);
        uint256 agic = balanceOf(msg.sender);
        _burn(msg.sender, agic);
        _totalPledgeEth = _totalPledgeEth.sub(agic.div(4));
    }

    function aaveProtocol(address owner) public view notZeroAddress(owner) returns (address){
        return _aaveContract[owner];
    }

    function balanceOf(address owner) public view override(ERC20) notZeroAddress(owner) returns (uint256){
        return _ethOfAave(owner).mul(4);
    }

    function pledgeEth(address owner) public view notZeroAddress(owner) returns (uint256){
        address payable aaveProtocolAddress = _addressToPayable(_aaveContract[owner]);
        if (aaveProtocolAddress == address(0)) {
            return 0;
        } else {
            AaveSavingsProtocol aave = AaveSavingsProtocol(aaveProtocolAddress);
            return aave.getPledgeEth();
        }
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override(ERC20) {
        require(amount > 0, "Transferred amount needs to be greater than zero");
        require(balanceOf(sender) > amount, "ERC20: transfer amount exceeds balance");
        uint256 eth = amount.div(4);
        AaveSavingsProtocol aave = _getAaveProtocol(sender);
        aave.transfer(recipient, eth);
        super._transfer(sender, recipient, amount);
    }

    function _ethOfAave(address owner) private view returns (uint256){
        address payable aaveProtocolAddress = _addressToPayable(_aaveContract[owner]);
        if (aaveProtocolAddress == address(0)) {
            return 0;
        } else {
            AaveSavingsProtocol aave = AaveSavingsProtocol(aaveProtocolAddress);
            return aave.balanceOf();
        }
    }

    function _getAaveProtocol(address _owner) private view returns (AaveSavingsProtocol){
        address payable aaveProtocolAddress = _addressToPayable(_aaveContract[_owner]);
        require(aaveProtocolAddress != address(0), "not have aave protocol");
        return AaveSavingsProtocol(aaveProtocolAddress);
    }

    function totalPledgeEth() public view returns (uint256){
        return _totalPledgeEth;
    }

    //Pledge eth in exchange for AGIC
    function deposit() public payable {
        uint256 eth = msg.value;
        uint256 agic = eth.mul(4);
        _totalPledgeEth = _totalPledgeEth.add(eth);
        super._mint(msg.sender, agic);
        address payable aaveProtocolAddress = _addressToPayable(_aaveContract[msg.sender]);
        AaveSavingsProtocol aave;
        if (aaveProtocolAddress == address(0)) {
            aave = new AaveSavingsProtocol(msg.sender, _addressToPayable(provider.getAgicFundPool()));
            _aaveContract[msg.sender] = address(aave);
        } else {
            aave = AaveSavingsProtocol(aaveProtocolAddress);
        }
        aave.deposit { value : eth}();
        emit Deposit(aaveProtocolAddress == address(0), eth, msg.sender);
    }

    //Current interest earned
    function interestAmount() public view returns (uint256){
        address payable aaveProtocolAddress = _addressToPayable(_aaveContract[msg.sender]);
        if (aaveProtocolAddress == address(0)) {
            return 0;
        } else {
            AaveSavingsProtocol aave = AaveSavingsProtocol(aaveProtocolAddress);
            return aave.interestAmount();
        }
    }

    //Take out all pledge ETH
    function redeem() public {
        address payable aaveProtocolAddress = _addressToPayable(_aaveContract[msg.sender]);
        require(aaveProtocolAddress != address(0), "not have protocol");
        uint256 agic = balanceOf(msg.sender);
        require(agic > 0, "not have pledge Eth");
        AaveSavingsProtocol aave = AaveSavingsProtocol(aaveProtocolAddress);
        uint256 userPledgeEth = aave.getPledgeEth();
        aave.redeem();
        _burn(msg.sender, userPledgeEth.mul(4));
        uint256 eth = agic.div(4);
        _totalPledgeEth = _totalPledgeEth.sub(userPledgeEth);
        emit Redeem(msg.sender, eth);
    }

    function _addressToPayable(address _address) private pure returns (address payable){
        return address(uint160(_address));
    }

    event Deposit(bool _new, uint256 _value, address _sender);

    event Redeem(address _sender, uint256 _value);

}