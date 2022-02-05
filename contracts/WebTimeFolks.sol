pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WebTimeFolks is ERC721Enumerable, Ownable {
    using Strings for uint256;

    string private baseURI;
    string private notRevealedUri;
    string private baseExtension = ".json";

    bool public isAllowListActive = false;
    bool public isPublicSaleActive = false;
    bool public revealed = false;

    uint256 public PRICE = 0.08 ether;
    uint256 public MAX_SUPPLY = 8080;
    uint256 public MAX_MINT_AMOUNT = 3;
    uint256 public RESERVE_COUNT = 100;

    mapping(address => uint8) private _allowList;

    constructor(
        string memory _initBaseURI,
        string memory _initNotRevealedUri
    ) ERC721("WebTimeFolks", "WTF") {
        setBaseURI(_initBaseURI);
        setNotRevealedURI(_initNotRevealedUri);
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function setIsAllowListActive(bool _isAllowListActive) external onlyOwner {
        isAllowListActive = _isAllowListActive;
    }

    function setSaleState(bool newState) public onlyOwner {
        isPublicSaleActive = newState;
    }

    function setRevealed(bool _state) public onlyOwner {
      revealed = _state;
    }

    function setPrice(uint256 _newCost) public onlyOwner {
        PRICE = _newCost;
    }

    function setAllowList(address[] calldata addresses, uint8 numAllowedToMint) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            _allowList[addresses[i]] = numAllowedToMint;
        }
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function mintAllowList(uint8 numberOfTokens) external payable {
        uint256 supply = totalSupply();
        require(isAllowListActive, "WL is not active");
        require(numberOfTokens <= _allowList[msg.sender], "Exceeded max available to purchase");
        require(supply + numberOfTokens <= MAX_SUPPLY, "Purchase would exceed max tokens");
        require(PRICE * numberOfTokens <= msg.value, "Ether value sent is not correct");

        _allowList[msg.sender] -= numberOfTokens;
        for (uint256 i = 0; i < numberOfTokens; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }

    function mint(uint256 _mintAmount) public payable {
        uint256 supply = totalSupply();
        require(isPublicSaleActive, "Public sale is not active");
        require(_mintAmount > 0, "Cannot mint less than 1");
        require(_mintAmount <= MAX_MINT_AMOUNT, "Exceeded max available to purchase");
        require(supply + _mintAmount <= MAX_SUPPLY, "Purchase would exceed max tokens");

        if (msg.sender != owner()) {
            require(msg.value >= PRICE * _mintAmount, "Ether value sent is not correct");
        }

        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "Inexistent Token ID");

        if (revealed == false) {
            return notRevealedUri;
        }

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    function withdraw() public payable onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
}
