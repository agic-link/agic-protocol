// SPDX-License-Identifier: MIT

pragma solidity ^0.6.8;

//import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./constants/ConstantMetadata.sol";
import "./AgicFundPool.sol";

contract AgicEquityCard is ERC721 {

    //token Builder（Self-increasing）
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address private _agicFundPool;

    //Number of three equity cards
    uint8 private _fivePercent;

    uint8 private _threePercent;

    uint8 private _onePercent;

    constructor() public ERC721("Agic Equity Card", "AEC") {
        AgicFundPool pool = new AgicFundPool();
        _agicFundPool = address(pool);
    }

    function getAgicFundPoolAddress() public view returns (address){
        return _agicFundPool;
    }

    //todo 直接检测value，然后百分比转入到资金池
    function issuingOneCard(address to) public returns (uint256) {
        require(_onePercent < 14, "One Percent Card 14 Only");
        return _issuingCard(to, ONE_PERCENT_METADATA_URI);
    }

    function issuingThreeCard(address to) public returns (uint256) {
        require(_threePercent < 7, "Three Percent Card 7 Only");
        return _issuingCard(to, THREE_PERCENT_METADATA_URI);
    }

    function issuingFiveCard(address to) public returns (uint256) {
        require(_fivePercent < 3, "Five Percent Card 3 Only");
        return _issuingCard(to, FIVE_PERCENT_METADATA_URI);
    }

    function _issuingCard(address to, string tokenURI) private returns (uint256) {
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        return tokenId;
    }

}