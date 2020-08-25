// SPDX-License-Identifier: MIT

pragma solidity ^0.6.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./AaveSavingsProtocol.sol";
import "./interface/IAgicAddressesProvider.sol";

contract Agic is ERC20, Ownable {

    using SafeMath for uint256;

    uint256 private _totalPledgeEth;

    mapping(address => uint256) private _pledgeEth;

    //user => aaveContract
    mapping(address => address) private _aaveContract;

    address private _agicAddressesProvider;

    address payable private _provider;

    constructor (address payable agicAddressesProvider) public ERC20("Automatically Generate Of Interest Coin", "AGIC") Ownable(){
        _provider = agicAddressesProvider;
    }

    modifier notZeroAddress(address _to) {
        require(_to != address(0), "Agic: transfer from the zero address");
        _;
    }

    function getAgicAddressesProviderAddress() public view returns (address){
        return _provider;
    }

    function totalPledgeEth() public view returns (uint256){
        return _totalPledgeEth;
    }

    function _getAgicAddressesProvider() private view returns (IAgicAddressesProvider){
        return IAgicAddressesProvider(_provider);
    }

    function aaveProtocol(address owner) public view notZeroAddress(owner) returns (address){
        return _aaveContract[owner];
    }

    function balanceOf(address owner) public view override(ERC20) notZeroAddress(owner) returns (uint256){
        return _ethOfAave(owner).mul(4);
    }

    function pledgeEth(address owner) public view notZeroAddress(owner) returns (uint256){
        return _pledgeEth[owner];
    }

    //Current interest earned
    function interestAmount(address owner) public view notZeroAddress(owner) returns (uint256){
        return _interestAmount(owner);
    }

    function _interestAmount(address owner) private view returns (uint256){
        uint256 ethOfAave = _ethOfAave(owner);
        return ethOfAave > _pledgeEth[owner] ? ethOfAave.sub(_pledgeEth[owner]) : 0;
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
        require(aaveProtocolAddress != address(0), "Agic: not have aave protocol");
        return AaveSavingsProtocol(aaveProtocolAddress);
    }

    function _transfer(address from, address to, uint256 amount) internal override(ERC20) {
        require(amount > 0, "Agic: Transferred amount needs to be greater than zero");
        uint256 balance = balanceOf(from);
        require(balance > amount, "Agic: transfer amount exceeds balance");

        uint256 percentage = _percentage(amount, balance);
        uint256 subPledgeEth = _takePercentage(_pledgeEth[from], percentage);
        _pledgeEth[from] = _pledgeEth[from].sub(subPledgeEth);
        _pledgeEth[to] = _pledgeEth[to].add(subPledgeEth);

        uint256 eth = amount.div(4);
        AaveSavingsProtocol fromAave = _getAaveProtocol(from);
        AaveSavingsProtocol toAave = _getOrNewAaveProtocol(_addressToPayable(to));
        fromAave.transfer(address(toAave), eth);
        super._transfer(from, to, amount);
    }

    function _getOrNewAaveProtocol(address payable _owner) private returns (AaveSavingsProtocol){
        AaveSavingsProtocol aave;
        address payable aaveProtocolAddress = _addressToPayable(_aaveContract[_owner]);
        if (aaveProtocolAddress == address(0)) {
            aave = new AaveSavingsProtocol(_owner, _provider);
            _aaveContract[_owner] = address(aave);
        } else {
            aave = AaveSavingsProtocol(aaveProtocolAddress);
        }
        return aave;
    }

    //Pledge eth in exchange for AGIC
    function deposit() public payable {
        uint256 eth = msg.value;
        uint256 agic = eth.mul(4);
        _totalPledgeEth = _totalPledgeEth.add(eth);
        _pledgeEth[msg.sender] = _pledgeEth[msg.sender].add(eth);
        super._mint(msg.sender, agic);
        AaveSavingsProtocol aave = _getOrNewAaveProtocol(msg.sender);
        aave.deposit {value : eth}();
        emit Deposit(eth, agic, msg.sender);
    }

    function redeem(uint256 agic) public {
        address payable aaveProtocolAddress = _addressToPayable(_aaveContract[msg.sender]);
        require(aaveProtocolAddress != address(0), "Agic: not have protocol");

        uint256 balance = balanceOf(msg.sender);
        require(balance >= agic, "Agic: Not so much balance");

        uint256 userEth = _ethOfAave(msg.sender);
        uint256 thisEth = agic.div(4);
        require(userEth >= thisEth, "Agic: Not so much pledge Eth");

        uint256 interest = _interestAmount(msg.sender);
        uint256 serviceCharge = interest >= 1e15 ? interest.div(20) : 0;
        uint256 redeemAmount = thisEth.add(serviceCharge);

        uint256 userPledgeEth = _pledgeEth[msg.sender];
        uint256 subPledgeEth;
        if (redeemAmount >= userEth) {
            subPledgeEth = userPledgeEth;
            redeemAmount = userEth;
        } else {
            uint256 percentage = _percentage(redeemAmount, userEth);
            subPledgeEth = _takePercentage(userPledgeEth, percentage);
            subPledgeEth = subPledgeEth > userPledgeEth ? userPledgeEth : subPledgeEth;
        }

        _pledgeEth[msg.sender] = userPledgeEth.sub(subPledgeEth);
        _totalPledgeEth = _totalPledgeEth.sub(subPledgeEth);
        _burn(msg.sender, subPledgeEth.mul(4));

        AaveSavingsProtocol aave = AaveSavingsProtocol(aaveProtocolAddress);
        aave.redeem(redeemAmount, serviceCharge);

        emit Redeem(eth, agic, serviceCharge, subPledgeEth);
    }

    function _addressToPayable(address _address) private pure returns (address payable){
        return address(uint160(_address));
    }

    /// @dev 40% = 400000000, 0.01%=10000, Calculate percentage with 6 decimal places,rounding 0.5=1,0.4=0
    function _percentage(uint256 a, uint256 b) private pure returns (uint256){
        return a.mul(1e7).div(b).add(5).div(10);
    }

    function _takePercentage(uint256 a, uint256 percentage) private pure returns (uint256){
        return a.mul(percentage).div(1e5).add(5).div(10);
    }

    event Deposit(uint256 _value, uint256 _agic, address _sender);

    event Redeem(uint256 _value, uint256 _agic, uint256 serviceCharge, uint256 subPledgeEth);

}