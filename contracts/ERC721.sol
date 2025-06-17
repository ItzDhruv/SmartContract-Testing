// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
 
contract NftContract is ERC721,ERC721URIStorage, Ownable{
    uint256 private _nextTokenId;
    uint256[] public _listedNftList; 

    event nftMinted(address  owner, uint256  tokenId, string uri );
    
    event nftListed(uint256 tokenId, address owner, uint256 price);
    event CancelListing(uint256 tokenId);
    event NftPurchased(uint256  tokenId, address buyer, uint price );
    
    struct Listing{
        address seller;
        uint256 prize;
    }

    mapping(uint256 => Listing) public  ListedNft;

    constructor() ERC721("CryptoSetu","CS") Ownable(msg.sender){}



    function safeMint( string memory uri) public returns (uint256){
        _nextTokenId++;
        _safeMint(msg.sender, _nextTokenId);   
        _setTokenURI(_nextTokenId,uri);  // id ne storage sathe map kre 
        emit nftMinted(msg.sender, _nextTokenId, uri);
        return _nextTokenId;
    }

    function listNft(uint256 tokenId, uint256 price)public {
        require (ownerOf(tokenId) == msg.sender, "only owner can list NFT ");
        require (price > 0, "price must be gretear than 0");
        ListedNft[tokenId] = Listing(msg.sender,price);
        _listedNftList.push(tokenId);
    emit nftListed(tokenId,msg.sender,price);
    }





        function removefromArray(uint256 tokenId) public {
        for (uint i = 0;i<_listedNftList.length;i++ ){
            if(_listedNftList[i] == tokenId){
                _listedNftList[i] = _listedNftList [_listedNftList .length - 1];
                _listedNftList.pop();
            break;
            }
        }
        }

    function buyNft(uint256 tokenId) public payable {
        require (ListedNft[tokenId].seller != address(0), "Listing not found");
        require (msg.value >= ListedNft[tokenId].prize ,"not enough fee recieved");
        payable(ListedNft[tokenId].seller).transfer(ListedNft[tokenId].prize);
        _transfer(ListedNft[tokenId].seller, msg.sender, tokenId);
        delete ListedNft[tokenId];
         removefromArray(tokenId);
        emit NftPurchased(tokenId, msg.sender,ListedNft[tokenId].prize );
    }


    function cancelListing(uint256 tokenId) public {
   
    require (ListedNft[tokenId].seller == msg.sender, "Only Owner can cancel");
    delete ListedNft[tokenId];
     removefromArray(tokenId);
    emit CancelListing(tokenId);
}

function getAllListedNfts() public view returns (Listing[] memory, uint256[] memory) {
    uint256 count = _listedNftList.length;

    Listing[] memory activeListings = new Listing[](count);
    uint256[] memory tokenIds = new uint256[](count);
    for (uint i = 0 ;i<count;i++){
        uint256 tokenid = _listedNftList[i];
        activeListings[i] = ListedNft[i];
        tokenIds[i] = tokenid;
    }

   

    return (activeListings, tokenIds);
}


   function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
    return super.supportsInterface(interfaceId);
   }

     function tokenURI(uint256 tokenId) public view override (ERC721,ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
     }
}