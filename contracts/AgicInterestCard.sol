// SPDX-License-Identifier: agpl-3.0

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./constants/ConstantMetadata.sol";
import "./interface/IAgicFundPool.sol";
import "./interface/IAgicAddressesProvider.sol";

contract AgicInterestCard is  ERC721URIStorage, Ownable, ConstantMetadata {

    //token Builder（Self-increasing）
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    Counters.Counter private _tokenIds;

    //tokenId => received
    mapping(uint256 => uint256) private _cardReceived;

    //type => amount
    mapping(uint8 => uint8) private _numberOfCard;

    //tokenId => cardType
    mapping(uint256 => uint8) private _cardType;

    IAgicAddressesProvider public immutable _provider;

    constructor (address agicAddressesProvider) ERC721("Agic Interest Card", "AIC") Ownable() {
        _provider = IAgicAddressesProvider(agicAddressesProvider);
    }

    function getTokenType(uint256 tokenId) public view returns (uint8){
        require(_exists(tokenId), "ERC721: nonexistent token");
        return _cardType[tokenId];
    }

    /// @return dividends Can receive dividends
    function getDividends(uint256 tokenId) public view returns (uint256 dividends, uint8 cardType){
        require(_exists(tokenId), "ERC721: nonexistent token");
        uint256 totalAmount = IAgicFundPool(_provider.getAgicFundPool()).getTotalAmount();
        cardType = _cardType[tokenId];
        uint256 tokenTotalDividends = totalAmount.mul(cardType).div(100);
        uint256 received = _cardReceived[tokenId];
        dividends = tokenTotalDividends.sub(received);
    }

    function issuingOneCard() public payable returns (uint256) {
        require(_numberOfCard[1] <= 14, "AIC: One Percent Card 14 Only");
        uint256 amount = msg.value;
        require(amount >= 1 ether, "AIC: One Percent Card Value 1Eth");
        payable(owner()).transfer(amount);
        return _issuingCard(msg.sender, ONE_PERCENT_METADATA_URI, 1);
    }

    function issuingThreeCard() public payable returns (uint256) {
        require(_numberOfCard[3] <= 7, "AIC: Three Percent Card 7 Only");
        uint256 amount = msg.value;
        require(amount >= 3 ether, "AIC: Three Percent Card Value 3eth");
        payable(owner()).transfer(amount);
        return _issuingCard(msg.sender, THREE_PERCENT_METADATA_URI, 3);
    }

    function issuingFiveCard() public payable returns (uint256) {
        require(_numberOfCard[5] <= 3, "AIC: Five Percent Card 3 Only");
        uint256 amount = msg.value;
        require(amount >= 5 ether, "AIC: Five Percent Card Value 5eth");
        payable(owner()).transfer(amount);
        return _issuingCard(msg.sender, FIVE_PERCENT_METADATA_URI, 5);
    }

    function receiveDividends(uint256 tokenId) public payable {
        require(_exists(tokenId), "ERC721: nonexistent token");
        address tokenOwner = ownerOf(tokenId);
        require(msg.sender == tokenOwner, "AIC: This token doesn't belong to you");

        (uint256 dividends, uint8 cardType) = getDividends(tokenId);
        require(dividends > 0, "AIC: No dividends available");
        _cardReceived[tokenId] = _cardReceived[tokenId].add(dividends);

        IAgicFundPool(_provider.getAgicFundPool())._transfer(dividends, payable(msg.sender));
        emit ReceiveInterest(block.timestamp, msg.sender, tokenId, cardType, dividends);
    }

    function _issuingCard(address to, string memory tokenURI, uint8 cardType) private returns (uint256 tokenId) {
        _tokenIds.increment();
        tokenId = _tokenIds.current();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        _numberOfCard[cardType] += 1;
        _cardType[tokenId] = cardType;
        _cardReceived[tokenId] = 0;
    }

    event Settlement(uint time, address user, uint256 lastAccountPeriodAmount);

    event ReceiveInterest(uint time, address user, uint256 tokenId, uint8 cardType, uint256 interest);

}
