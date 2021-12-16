pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";

contract Minter is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    event NewMint(address sender, uint256 tokenId);

    constructor() ERC721("Minter", "minter of nfts by trade") {
        console.log("beep beep beep... initializing minter");
    }

    function mintNFT() public {
        uint256 newMintId = _tokenIds.current();

        // receive jpg/nft data here
        // convert image into metadata
        // store metadata on ipfs and filecoin
        string memory finalTokenUri = 'url of metadata goes here';

        _safeMint(msg.sender, newMintId);
        _setTokenURI(newMintId, finalTokenUri);
        _tokenIds.increment();

        console.log(
            "An NFT w/ ID %s has been minted to %s",
            newMintId,
            msg.sender
        );

        emit NewMint(msg.sender, newMintId);
    }
}
