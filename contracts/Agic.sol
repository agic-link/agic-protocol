// SPDX-License-Identifier: MIT

pragma solidity ^0.6.8;

import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/access/Ownable.sol";
import "./AaveSavingsProtocol.sol";

contract Agic is ERC20UpgradeSafe, OwnableUpgradeSafe {

    using SafeMath for uint256;

    uint256 private _totalPledgeEth;

    mapping(address => uint256) private _pledgeEth;

    //user => aaveContract
    mapping(address => address) _aaveContract;

    //Alternative construction method
    function initialize() public initializer {
        __ERC20_init("Automatically Generate Of Interest Coin", "AGIC");
        __Ownable_init();
    }

    modifier notZeroAddress(address _to) {
        require(_to != address(0), "transfer from the zero address");
        _;
    }

    function invalidAaveProtocol() public {
        _aaveContract[msg.sender] = address(0);
        uint256 pledgeEth = _pledgeEth[msg.sender];
        uint256 agic = pledgeEth.mul(4);
        _burn(msg.sender, agic);
        _pledgeEth[msg.sender] = 0;
        _totalPledgeEth = _totalPledgeEth.sub(pledgeEth);
    }

    function aaveProtocol(address owner) public view notZeroAddress(owner) returns (address){
        return _aaveContract[owner];
    }

    function balanceOf(address owner) public view override(ERC20UpgradeSafe) notZeroAddress(owner) returns (uint256){
        return _ethOfAave(owner).mul(4);
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

    function pledgeEth(address owner) public view notZeroAddress(owner) returns (uint256){
        return _pledgeEth[owner];
    }

    function totalPledgeEth() public view returns (uint256){
        return _totalPledgeEth;
    }

    /// @dev Pledge eth in exchange for AGIC
    //质押的eth换成agic
    function deposit() public payable {
        uint256 eth = msg.value;
        uint256 agic = eth.mul(4);
        _pledgeEth[msg.sender] = _pledgeEth[msg.sender].add(eth);
        _totalPledgeEth = _totalPledgeEth.add(eth);
        super._mint(msg.sender, agic);
        address payable aaveProtocolAddress = _addressToPayable(_aaveContract[msg.sender]);
        AaveSavingsProtocol aave;
        if (aaveProtocolAddress == address(0)) {
            aave = new AaveSavingsProtocol(msg.sender, _addressToPayable(owner()));
            _aaveContract[msg.sender] = address(aave);
        } else {
            aave = AaveSavingsProtocol(aaveProtocolAddress);
        }
        aave.deposit{value : eth}();
        emit Deposit(aaveProtocolAddress == address(0), eth, msg.sender);
    }

    //get 当前赚取的利息
    function interestAmount() public view returns (uint256){
        address payable aaveProtocolAddress = _addressToPayable(_aaveContract[msg.sender]);
        if (aaveProtocolAddress == address(0)) {
            return 0;
        } else {
            AaveSavingsProtocol aave = AaveSavingsProtocol(aaveProtocolAddress);
            return aave.interestAmount();
        }
    }

    //赎回全部eth并获得利息
    function redeem() public {
        address payable aaveProtocolAddress = _addressToPayable(_aaveContract[msg.sender]);
        require(aaveProtocolAddress != address(0), "not have protocol");
        uint256 eth = _pledgeEth[msg.sender];
        require(eth > 0, "not have pledge Eth");
        AaveSavingsProtocol aave = AaveSavingsProtocol(aaveProtocolAddress);
        aave.redeem();
        aave.withdrawal();
        _burn(msg.sender, eth.mul(4));
        _pledgeEth[msg.sender] = _pledgeEth[msg.sender].sub(eth);
        _totalPledgeEth = _totalPledgeEth.sub(eth);
        emit Redeem(msg.sender, eth);
    }

    function _addressToPayable(address _address) private pure returns (address payable){
        return address(uint160(_address));
    }

    event Deposit(bool _new, uint256 _value, address _sender);

    event Redeem(address _sender, uint256 _value);

    receive() external payable {}
}