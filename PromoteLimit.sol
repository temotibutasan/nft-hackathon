// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721Enumerable, Ownable {
  uint256 private maxHistory = 100;
  address[] private userIndex;
  uint256 private userIndexOffset = 0;
  address[] private luckyAddress;

  using Strings for uint256;
  uint256 public maxSupply = 1;
  uint256 public maxLucky = 10;
  uint256 public probability = 10;
  uint256 public drawingResult = 2;

  constructor() ERC721("PromoteNft", "PMNFT") {
    userIndex = new address[](100);
    mint(1);
  }

  // internal
  function _baseURI() internal pure override returns (string memory) {
      return "https://gateway.pinata.cloud/ipfs/QmaeoJwShoQJYrPdaiifZUwLbKNoPFzPcdcKNT2nDNBJMR/";
  }

  function mint(uint256 _mintAmount) public payable {
    uint256 supply = totalSupply();
    require(_mintAmount > 0);
    require(supply + _mintAmount <= maxSupply);

    for (uint256 i = 1; i <= _mintAmount; i++) {
      _safeMint(msg.sender, supply + i);
    }
  }

  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
      require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
      string memory baseURI = _baseURI();
      string memory resultURI = drawingResult == 0 ? "lucky.json":"unlucky.json"; 
      return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI,resultURI)) : "";
  }

  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public virtual override {
    //solhint-disable-next-line max-line-length
    require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
    updateResult(to,tokenId);
    _transfer(from, to, tokenId);
  }

  function updateResult(address to,uint256 tokenId) private {
    if(insertUser(to)){
      drawingResult = drawing(tokenId)? 1:2;
      if(drawingResult == 1){
          luckyAddress.push(to);
      }
      insertUser(to);
    } else {
      drawingResult = 0;
    }
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
    for(uint256 i=0; i < maxHistory; i++){
      if(userIndex[i] == userAddress) return true;
    }
    return false;
  }

  function insertUser(address userAddress) private
  returns(bool)
  {
      if(isUser(userAddress)) return false;
      userIndex[userIndexOffset] = userAddress;
      if(userIndexOffset >= maxHistory){
        userIndexOffset = 0;
      }
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

  // debug用 不要になったら消す
  function debugUpdateResult(address to,uint256 tokenId) public onlyOwner {
    updateResult(to, tokenId);
  }
  // debug用 不要になったら消す
  function debugGetUsers() public onlyOwner view returns (address[] memory)
  {
    return userIndex;
  }
}