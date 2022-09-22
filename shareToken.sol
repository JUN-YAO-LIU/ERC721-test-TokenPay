// Contract based on https://docs.openzeppelin.com/contracts/3.x/erc721
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract JimShareToken is ERC721Enumerable, Ownable {
    using Strings for uint256;

    //State
    bool public _isActiveMint = false;
    bool public _friendShare = false;

    // Constants
    uint256 public constant MAX_SUPPLY = 10;
    uint256 public tokenPrice = 0.0035 ether;
    uint256 public discountPrice = 0.002 ether;
    uint256 public maxBalance = 2;

    string baseURI;
    string public notRevealedUri;
    string public baseExtension = ".json";

    mapping(uint256 => string) private _tokenURIs;

    //Declare an Event
    event rtnMsgToUser(string rtnMsg);
    event Log(address indexed sender, string message);

    constructor(string memory initBaseURI, string memory initNotRevealedUri)
        ERC721("Jim Share Token", "JST")
    {
        setBaseURI(initBaseURI);
        setNotRevealedURI(initNotRevealedUri);
    }

    function mintTokenId() public payable {
        require(
            totalSupply() + 1 <= MAX_SUPPLY,
            "token is empty"
        );
        require(
            _isActiveMint, 
            "the activity don't start !"
        );
        require(
            balanceOf(msg.sender) + 1 <= maxBalance,
            "you already have many tokens !"
        );
        require(
            1 * tokenPrice <= msg.value,
            "Not enough ether sent"
        );
        _mintTokenId();
    }

    function _mintTokenId() internal {
        //get the index of next tokenid 
        uint256 mintIndex = totalSupply();
        if (totalSupply() < MAX_SUPPLY) {
            _safeMint(msg.sender, mintIndex);
        }
    }

    function _mintFriendTokenId(address _friendAddr) internal {
        //get the index of next tokenid 
        uint256 mintIndex = totalSupply();
        if (totalSupply() < MAX_SUPPLY) {
            _safeMint(_friendAddr, mintIndex);
        }
    }

    function mintReducePriceToken(address _friendAddr) public payable {
        //add the two token.
        require(
            totalSupply() + 2 <= MAX_SUPPLY,
            "token is empty"
        );

        require(
            _friendShare, 
            "the share activity don't start !"
        );
        
        require(
            balanceOf(msg.sender) == 0,
            "you already have the token !"
        );

        //friend can spend less money to get this NFT.
        require(
            1 * discountPrice <= msg.value,
            "Not enough ether sent"
        );

        //calculate and add the friend's token.
        addFriendToken(_friendAddr);

        //mintTokenId
        _mintTokenId();

        //emit rtnMsgToUser("");
    }

    function addFriendToken(address _friendAddr) private
    {
        require(
            totalSupply() + 1 <= MAX_SUPPLY,
            "token is empty"
        );
        require(
            balanceOf(_friendAddr) + 1 <= maxBalance,
            "your friend already have many tokens !"
        );
        _mintFriendTokenId(_friendAddr);
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

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return
            string(abi.encodePacked(base, tokenId.toString(), baseExtension));
    }

    function testEvent() public{
        emit Log(msg.sender, "Hello World!");
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    //##-------------------------------only owner-------------------------------
    function activeMint() public onlyOwner {
        _isActiveMint = !_isActiveMint;
    }

    function activeFriendShare() public onlyOwner {
        _friendShare = !_friendShare;
    }

    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        tokenPrice = _mintPrice;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function setMaxBalance(uint256 _maxBalance) public onlyOwner {
        maxBalance = _maxBalance;
    }


    function withdraw(address to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(to).transfer(balance);
    }
}