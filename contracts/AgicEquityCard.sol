// SPDX-License-Identifier: MIT

pragma solidity ^0.6.8;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./constants/ConstantMetadata.sol";
import "./AgicFundPool.sol";
import "./interface/IAgicAddressesProvider.sol";

contract AgicEquityCard is ERC721, Ownable, ConstantMetadata {

    using SafeMath for uint256;

    struct Map {
        Token[] value;
        mapping(uint256 => uint256) _indexes;
    }

    function add(Token memory token) private {
        uint256 index = _tokens.value.length + 1;
        _tokens.value[_tokens._indexes[index]] = token;
    }

    function get(uint256 tokenId) private view returns (Token memory){
        return _tokens.value[_tokens._indexes[tokenId]];
    }

    struct Token {
        uint256 id;
        uint8 cardType;
        //which phase
        uint256 phase;
    }

    //token Builder（Self-increasing）
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // last settlement date
    uint private _lastSettlement;

    Map private _tokens;

    uint256 private _phase;

    //type=>interest
    mapping(uint8 => uint256) private _cardInterest;

    //type=>amount
    mapping(uint8 => uint8) private _numberOfCard;

    IAgicAddressesProvider private provider;

    constructor (address agicAddressesProvider) public ERC721("Agic Equity Card", "AEC") Ownable() {
        provider = IAgicAddressesProvider(agicAddressesProvider);
        _lastSettlement = now;
    }

    function issuingOneCard() public payable returns (uint256) {
        require(_numberOfCard[1] < 14, "AEC: One Percent Card 14 Only");
        uint256 amount = msg.value;
        require(amount >= 1 ether, "AEC: One Percent Card Value 1eth");
        _addressToPayable(owner()).transfer(amount);
        return _issuingCard(msg.sender, ONE_PERCENT_METADATA_URI, 1);
    }

    function issuingThreeCard() public payable returns (uint256) {
        require(_numberOfCard[3] < 7, "AEC: Three Percent Card 7 Only");
        uint256 amount = msg.value;
        require(amount >= 3 ether, "AEC: Three Percent Card Value 3eth");
        _addressToPayable(owner()).transfer(amount);
        return _issuingCard(msg.sender, THREE_PERCENT_METADATA_URI, 3);
    }

    function issuingFiveCard() public payable returns (uint256) {
        require(_numberOfCard[5] < 3, "AEC: Five Percent Card 3 Only");
        uint256 amount = msg.value;
        require(amount >= 5 ether, "AEC: Five Percent Card Value 5eth");
        _addressToPayable(owner()).transfer(amount);
        return _issuingCard(msg.sender, FIVE_PERCENT_METADATA_URI, 5);
    }

    //Settlement of monthly interest distribution for each card
    function settlement() public onlyOwner {
        require(_lastSettlement + 30 days > now, "AEC: Only one settlement per month");
        _lastSettlement = now;
        AgicFundPool pool = AgicFundPool(provider.getAgicFundPool());
        uint256 thisAccountPeriodAmount = pool.getThisAccountPeriodAmount();
        pool.afterSettlement();
        _cardInterest[5] = thisAccountPeriodAmount.mul(5).div(100);
        _cardInterest[3] = thisAccountPeriodAmount.mul(3).div(100);
        _cardInterest[1] = thisAccountPeriodAmount.div(100);
        _phase = _phase.add(1);
    }

    function receiveInterest(uint256 tokenId) public payable {
        address tokenOwner = ownerOf(tokenId);
        require(msg.sender == tokenOwner, "AEC: This token doesn't belong to you");
        Token memory token = get(tokenId);
        require(token.phase < _phase, "AEC: The interest has been collected");
        uint256 interest = _cardInterest[token.cardType];
        require(interest > 0, "AEC: No interest.");
        _tokens.value[tokenId].phase = _tokens.value[tokenId].phase.add(1);
        AgicFundPool pool = AgicFundPool(provider.getAgicFundPool());
        pool._transfer(interest, msg.sender);
    }

    function _issuingCard(address to, string memory tokenURI, uint8 cardType) private returns (uint256) {
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        Token memory token = Token(tokenId, cardType, 0);
        add(token);
        _numberOfCard[cardType] += 1;
        return tokenId;
    }

    function _addressToPayable(address _address) private pure returns (address payable){
        return address(uint160(_address));
    }

}