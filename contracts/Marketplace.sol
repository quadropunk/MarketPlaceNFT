// SPDX-License-Identifier: No License
pragma solidity ^0.8.0;

import "./tokens/MyERC20.sol";
import "./tokens/MyERC721.sol";
import "./tokens/MyERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

contract Marketplace {

    /*-----------------------------------
    |                                   |
    |               STATES              |
    |                                   |
    |-----------------------------------*/
    using SafeMath for uint256;

    struct SellingOrder {
        address owner;
        uint256 amount;
        uint256 price;
        uint256 startedTime;
        address lastBidder;
    }

    uint256 public constant AUCTION_PERIOD = 3 seconds;

    MyERC20 public erc20;
    MyERC721 public erc721;
    MyERC1155 public erc1155;

    mapping(uint256 => SellingOrder) public tokensInfo;
    address private platform;

    constructor(address erc20_, address erc721_, address erc1155_) {
        erc20 = MyERC20(erc20_);
        erc721 = MyERC721(erc721_);
        erc1155 = MyERC1155(erc1155_);
        platform = address(this);
    }

    modifier onlyTokenOwner(uint256 tokenId) {
        if (tokensInfo[tokenId].owner != msg.sender)
            revert("You are not owner of this token");
        _;
    }

    /*-----------------------------------
    |                                   |
    |        MARKETPLACE FUNCTIONS      |
    |                                   |
    |-----------------------------------*/

    function createItem(uint256 tokenId) external {
        require(tokensInfo[tokenId].owner == address(0), "Token with such id exists");
        erc721.mintTo(msg.sender, tokenId);
        tokensInfo[tokenId] = SellingOrder({
            owner: msg.sender,
            amount: 1,
            price: 0,
            startedTime: 0,
            lastBidder: address(0)
        });
    }

    function createItem(uint256 amount, uint256 tokenId) external {
        require(amount != 0, "Amount cannot be zero");
        require(tokensInfo[tokenId].owner == address(0), "Token with such id exists");
        erc1155.mintTo(msg.sender, amount, tokenId);
        tokensInfo[tokenId] = SellingOrder({
            owner: msg.sender,
            amount: amount,
            price: 0,
            startedTime: 0,
            lastBidder: address(0)
        });
    }

    function listItem(uint256 tokenId, uint256 price) external onlyTokenOwner(tokenId) {
        require(tokensInfo[tokenId].price == 0, "This item is already listed");
        erc721.transferFrom(msg.sender, platform, tokenId);
        tokensInfo[tokenId].price = price;
    }

    function listItem(uint256 tokenId, uint256 price, uint256 amount) external onlyTokenOwner(tokenId) {
        require(tokensInfo[tokenId].price == 0, "This item is already listed");
        require(erc1155.balanceOf(msg.sender, tokenId) >= amount, "Not enough tokens to list");
        erc1155.transferFrom(msg.sender, platform, tokenId, amount);
        tokensInfo[tokenId].price = price;
    }

    function cancel(uint256 tokenId) external onlyTokenOwner(tokenId) {
        require(tokensInfo[tokenId].price != 0, "Item is not listed");
        tokensInfo[tokenId].price = 0;
    }

    function buyItem(uint256 tokenId) external {
        require(tokensInfo[tokenId].price != 0, "Item is not listed");
        require(erc721.owners(tokenId) != address(0), "Token does not exist");
        require(erc20.transferTokensFrom(msg.sender, tokensInfo[tokenId].owner, tokensInfo[tokenId].price), "Transaction cancelled");
        erc721.transferFrom(platform, msg.sender, tokenId);
        tokensInfo[tokenId].owner = msg.sender;
        tokensInfo[tokenId].price = 0;
    }

    function buyItem(uint256 tokenId, uint256 amount) external {
        require(tokensInfo[tokenId].price != 0, "Item is not listed");
        require(erc1155.balanceOf(platform, tokenId) >= amount, "Not enough tokens in stock");
        require(erc20.transferTokensFrom(msg.sender, tokensInfo[tokenId].owner, tokensInfo[tokenId].price.mul(amount)), "Transaction cancelled");
        erc1155.transferFrom(platform, msg.sender, tokenId, amount);
        tokensInfo[tokenId].owner = msg.sender;
        tokensInfo[tokenId].price = 0;
    }

    /*-----------------------------------
    |                                   |
    |        AUCTION FUNCTIONS          |
    |                                   |
    |-----------------------------------*/

    function listItemOnAuction(uint256 tokenId, uint256 minPrice) external onlyTokenOwner(tokenId) {
        require(tokensInfo[tokenId].startedTime == 0, "Token is already on auction");
        erc721.transferFrom(msg.sender, platform, tokenId);
        tokensInfo[tokenId].price = minPrice;
        tokensInfo[tokenId].startedTime = block.timestamp;
    }

    function listItemOnAuction(uint256 tokenId, uint256 minPrice, uint256 amount) external onlyTokenOwner(tokenId) {
        require(tokensInfo[tokenId].startedTime == 0, "Token is already on auction");
        require(tokensInfo[tokenId].amount >= amount, "Not enough tokens");
        erc1155.transferFrom(msg.sender, platform, tokenId, amount);
        tokensInfo[tokenId].price = minPrice;
        tokensInfo[tokenId].startedTime = block.timestamp;
    }

    function finishAuction(uint256 tokenId) external {
        require(tokensInfo[tokenId].startedTime + AUCTION_PERIOD > block.timestamp, "Auction is not over yet");
        if (tokensInfo[tokenId].amount == 1)
            erc721.transferFrom(platform, tokensInfo[tokenId].lastBidder, tokenId);
        else erc1155.transferFrom(platform, tokensInfo[tokenId].lastBidder, tokenId, tokensInfo[tokenId].amount);
        tokensInfo[tokenId].startedTime = 0;
        tokensInfo[tokenId].price = 0;
        tokensInfo[tokenId].owner = tokensInfo[tokenId].lastBidder;
        tokensInfo[tokenId].lastBidder = address(0);
    }

    function makeBid(uint256 tokenId, uint256 price) external {
        require(tokensInfo[tokenId].startedTime != 0, "Token is not on auction");        
        require(tokensInfo[tokenId].startedTime + AUCTION_PERIOD > block.timestamp, "Token is not on auction");
        require(tokensInfo[tokenId].price < price, "Cannot pay <= current price");
        if (tokensInfo[tokenId].lastBidder != address(0))
            erc20.transfer(tokensInfo[tokenId].lastBidder, tokensInfo[tokenId].price);
        erc20.transferFrom(msg.sender, platform, price);
        tokensInfo[tokenId].price = price;
        tokensInfo[tokenId].lastBidder = msg.sender;
    }
}
