// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721Enumerable, Ownable {

  struct UserStruct {
    uint index;
  }
  mapping(address => UserStruct) private userStructs;
  address[] private userIndex;
  address[] private luckyAddress;


  using Strings for uint256;
  // https://gateway.pinata.cloud/ipfs/QmQtfYemFqU7sWW4mPK9LdBeDozDHLsN2VmikqpZRYwGXq?filename=Lucky.svg
  string public luckyUri;
  // https://gateway.pinata.cloud/ipfs/QmS8KvUTmRzQQr5QPPKaTZWTWxrvXQfewqMN4jXz3X3KFr/UnLucky.svg
  string public unLuckyUri;
  string public drewUri;
  uint256 public maxSupply = 1;
  uint256 public maxLucky = 10;
  uint256 public probability = 3000;
  uint256 public drawingResult = 2;

  constructor(
    string memory _initLuckyUri,
    string memory _initUnLuckyUri,
    string memory _initDrewUri
  ) ERC721("PromoteNft", "PMNFT") {
    setLuckyURI(_initLuckyUri);
    setUnLuckyURI(_initUnLuckyUri);
    setDrewURI(_initDrewUri);
    mint(1);
  }

  function mint(uint256 _mintAmount) public payable {
    uint256 supply = totalSupply();
    require(_mintAmount > 0);
    require(supply + _mintAmount <= maxSupply);

    for (uint256 i = 1; i <= _mintAmount; i++) {
      _safeMint(msg.sender, supply + i);
    }
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    
    if(drawingResult == 0){
      return drewUri;
    }
    else if(drawingResult == 1){
        return luckyUri;
    } else{
        return unLuckyUri;
    }
  }
  
  function setLuckyURI(string memory _newURI) private onlyOwner {
    luckyUri = _newURI;
  }

  function setUnLuckyURI(string memory _newURI) private onlyOwner {
    unLuckyUri = _newURI;
  }

  function setDrewURI(string memory _newURI) private onlyOwner {
    drewUri = _newURI;
  }


  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public virtual override {
    //solhint-disable-next-line max-line-length
    require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

    if(isUser(to)) {
        drawingResult = 0;
    } else {
        drawingResult = drawing(tokenId)? 1:2;
        if(drawingResult == 1){
            luckyAddress.push(to);
        }
        userIndex.push(to);
    }
    _transfer(from, to, tokenId);
  }

  function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
  ) public virtual override {
    safeTransferFrom(from, to, tokenId, "");
  }

  function random(string memory input) internal pure returns (uint256) {
    return uint256(keccak256(abi.encodePacked(input)));
  }

  function drawing(uint256 tokenId) private
    view
    returns (bool) 
  {

    if(luckyAddress.length >= maxLucky){
        return false;
    }

    uint256 rand = random(string(abi.encodePacked(toString(tokenId))));
    if(rand % probability == 0){
        return true;
    } else {
        return false;
    }
  }

  function isUser(address userAddress)  public
    view
    returns (bool) {
    if(userIndex.length == 0) return false;
    return (userIndex[userStructs[userAddress].index] == userAddress);
  }

  function insertUser(address userAddress) private
  returns(bool)
  {
      if(isUser(userAddress)) return false;
      userIndex.push(userAddress);
      userStructs[userAddress].index = userIndex.length-1;
      return true;
  }

    function toString(uint256 value) internal pure returns (string memory) {
  // Inspired by OraclizeAPI's implementation - MIT license
  // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

      if (value == 0) {
          return "0";
      }
      uint256 temp = value;
      uint256 digits;
      while (temp != 0) {
          digits++;
          temp /= 10;
      }
      bytes memory buffer = new bytes(digits);
      while (value != 0) {
          digits -= 1;
          buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
          value /= 10;
      }
      return string(buffer);
  }
}