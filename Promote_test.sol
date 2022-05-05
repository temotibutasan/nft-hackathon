// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.4.2/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.4.2/contracts/utils/Counters.sol";

contract Promote is ERC721 {
    using Counters for Counters.Counter;
    using Strings for uint256;
    
    Counters.Counter private _tokenIds;
    uint256 private _result = 1;

    constructor () ERC721 ("Promote", "PMNFT") {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://gateway.pinata.cloud/ipfs/QmaeoJwShoQJYrPdaiifZUwLbKNoPFzPcdcKNT2nDNBJMR/";
    }

    function mint() public returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        return newItemId;
    }

    function setResult(uint256 newResult) public returns (bool) {
        _result = newResult;
        return true;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        string memory resultURI = _result == 0 ? "lucky.json":"unlucky.json"; 
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI,resultURI)) : "";
    }
}