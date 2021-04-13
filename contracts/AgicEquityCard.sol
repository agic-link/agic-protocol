// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./constants/ConstantMetadata.sol";
import "./interface/IAgicFundPool.sol";
import "./interface/IAgicAddressesProvider.sol";

contract AgicEquityCard is ERC721, Ownable, ConstantMetadata {

    //token Builder（Self-increasing）
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    struct Token {
        uint256 id;
        uint8 cardType;
        //which phase
        uint256 phase;
    }

    struct Map {
        Token[] value;
        ///@dev tokenId => value order
        mapping(uint256 => uint256) _indexes;
    }

    function _add(Token memory token) private {
        uint256 index = _tokens.value.length;
        _tokens._indexes[token.id] = index;
        _tokens.value.push(token);
    }

    function _get(uint256 tokenId) private view returns (Token memory){
        return _tokens.value[_tokens._indexes[tokenId]];
    }

    Counters.Counter private _tokenIds;

    // last settlement date
    uint private _lastSettlementTime;

    Map private _tokens;

    uint256 private _phase;

    //type=>interest
    mapping(uint8 => uint256) private _cardInterest;

    //type=>amount
    mapping(uint8 => uint8) private _numberOfCard;

    IAgicAddressesProvider private provider;

    constructor (address agicAddressesProvider) public ERC721("Agic Equity Card", "AEC") Ownable() {
        provider = IAgicAddressesProvider(agicAddressesProvider);
        _lastSettlementTime = now;
    }

    function lastSettlementTime() public view returns (uint){
        return _lastSettlementTime;
    }

    function nextSettlementTime() public view returns (uint){
        return _lastSettlementTime + 30 days;
    }

    function getPhase() public view returns (uint256){
        return _phase;
    }

    function getTokenInfo(uint256 tokenId) public view returns (uint8, uint256){
        require(_exists(tokenId), "ERC721: nonexistent token");
        Token memory token = _get(tokenId);
        return (token.cardType, token.phase);
    }

    //Receivable interest
    function receivableAmount(uint256 tokenId) public view returns (uint256){
        require(_exists(tokenId), "ERC721: nonexistent token");
        Token memory token = _get(tokenId);
        IAgicFundPool pool = IAgicFundPool(provider.getAgicFundPool());

        if (token.phase == _phase) {
            return pool.getThisAccountPeriodAmount().mul(token.cardType).div(100);
        } else {
            return pool.getLastAccountPeriodAmount().mul(token.cardType).div(100);
        }
    }

    function issuingOneCard() public payable returns (uint256) {
        require(_numberOfCard[1] <= 14, "AEC: One Percent Card 14 Only");
        uint256 amount = msg.value;
        require(amount >= 1 ether, "AEC: One Percent Card Value 1Eth");
        _addressToPayable(owner()).transfer(amount);
        return _issuingCard(msg.sender, ONE_PERCENT_METADATA_URI, 1);
    }

    function issuingThreeCard() public payable returns (uint256) {
        require(_numberOfCard[3] <= 7, "AEC: Three Percent Card 7 Only");
        uint256 amount = msg.value;
        require(amount >= 3 ether, "AEC: Three Percent Card Value 3eth");
        _addressToPayable(owner()).transfer(amount);
        return _issuingCard(msg.sender, THREE_PERCENT_METADATA_URI, 3);
    }

    function issuingFiveCard() public payable returns (uint256) {
        require(_numberOfCard[5] <= 3, "AEC: Five Percent Card 3 Only");
        uint256 amount = msg.value;
        require(amount >= 5 ether, "AEC: Five Percent Card Value 5eth");
        _addressToPayable(owner()).transfer(amount);
        return _issuingCard(msg.sender, FIVE_PERCENT_METADATA_URI, 5);
    }

    function receiveInterest(uint256 tokenId) public payable {
        address tokenOwner = ownerOf(tokenId);
        require(msg.sender == tokenOwner, "AEC: This token doesn't belong to you");

        if (_lastSettlementTime + 30 days < now) {
            _settlement();
        }

        Token memory token = _get(tokenId);
        require(_phase > token.phase, "AEC: The interest has been collected");

        IAgicFundPool pool = IAgicFundPool(provider.getAgicFundPool());
        uint256 interest = pool.getLastAccountPeriodAmount().mul(token.cardType).div(100);
        require(interest > 0, "AEC: Not have interest");
        uint256 index = _tokens._indexes[tokenId];
        _tokens.value[index].phase = _phase;
        address payable to = _addressToPayable(ownerOf(tokenId));
        pool._transfer(interest, to);
        emit ReceiveInterest(now, msg.sender, tokenId, token.cardType, interest);
    }

    //Settlement of monthly interest distribution for each card
    function _settlement() private {
        _lastSettlementTime = now;
        IAgicFundPool pool = IAgicFundPool(provider.getAgicFundPool());
        pool.afterSettlement();
        _phase = _phase.add(1);
        emit Settlement(now, msg.sender, pool.getLastAccountPeriodAmount());
    }

    function _issuingCard(address to, string memory tokenURI, uint8 cardType) private returns (uint256) {
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        Token memory token = Token(tokenId, cardType, 0);
        _add(token);
        _numberOfCard[cardType] += 1;
        return tokenId;
    }

    function _addressToPayable(address _address) private pure returns (address payable){
        return address(uint160(_address));
    }

    event Settlement(uint time, address user, uint256 lastAccountPeriodAmount);

    event ReceiveInterest(uint time, address user, uint256 tokenId, uint8 cardType, uint256 interest);

}