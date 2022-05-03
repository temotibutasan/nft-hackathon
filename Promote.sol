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
  event LogNewUser(address indexed userAddress, uint index);


  using Strings for uint256;
  string public luckyUri;
  string public unLuckyUri;
  uint256 public maxSupply = 1;
  uint256 public maxLucky = 10;
  uint256 public probability = 3000;
  bool public drawingResult = false;

  constructor(
    string memory _initLuckyURI,
    string memory _initUnLuckyUri
  ) ERC721("OnChainPromoteNft", "OCPN") {
    setLuckyURI(_initLuckyURI);
    setUnUnLuckyURI(_initUnLuckyUri);
    mint(1);
  }

  // public
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
    
    if(drawingResult){
        return luckyUri;
    } else{
        return unLuckyUri;
    }
  }
  
  function setLuckyURI(string memory _newURI) public onlyOwner {
    luckyUri = _newURI;
  }

  function setUnUnLuckyURI(string memory _newURI) public onlyOwner {
    unLuckyUri = _newURI;
  }


  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public virtual override {
    //solhint-disable-next-line max-line-length
    require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

    if(isUser(to)) {
        drawingResult = false;
    } else {
        drawingResult = drawing(tokenId);
        if(drawingResult == true){
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

  function drawing(uint256 tokenId) public
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
        return true;
    }
  }

  function isUser(address userAddress)  public
    view
    returns (bool) {
    if(userIndex.length == 0) return false;
    return (userIndex[userStructs[userAddress].index] == userAddress);
  }

    function insertUser(address userAddress) 
    public
    returns(bool)
    {
        if(isUser(userAddress)) return false;
        userIndex.push(userAddress);
        userStructs[userAddress].index = userIndex.length-1;
        LogNewUser(
            userAddress, 
            userStructs[userAddress].index);
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