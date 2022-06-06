// SPDX-License-Identifier: No License
pragma solidity ^0.8.0;

import "./tokens/MyERC20.sol";
import "./tokens/MyERC721.sol";
import "./tokens/MyERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Marketplace {
    using SafeMath for uint256;

    uint256 public constant AUCTION_PERIOD = 3 days;

    MyERC20 immutable public erc20;
    MyERC721 immutable public erc721;
    MyERC1155 immutable public erc1155;

    mapping(uint256 => address) public owners;
    mapping(uint256 => uint256) public auctionStartedTime;
    mapping(uint256 => address) public lastBidder;
    mapping(uint256 => uint256) public prices;
    mapping(uint256 => uint256) public amounts;

    event ItemCreated(uint256 indexed tokenId, address owner, uint256 amount);
    event ItemListed(uint256 indexed tokenId, address owner, uint256 amount, uint256 price);
    event ListingCanceled(uint256 indexed tokenId);
    event ItemBought(uint256 indexed tokenId, address buyer, uint256 amount, uint256 price);

    event ItemListedOnAuction(
        uint256 indexed tokenId,
        address seller,
        uint256 amount,
        uint256 price,
        uint256 startTime
    );
    event AuctionFinished(
        uint256 indexed tokenId,
        address newOwner,
        uint256 amount,
        uint256 price,
        uint256 endTime
    );
    event BidMade(uint256 indexed tokenId, address bidder, uint256 price);

    constructor(address erc20_, address erc721_, address erc1155_) {
        (erc20, erc721, erc1155) = (MyERC20(erc20_), MyERC721(erc721_), MyERC1155(erc1155_));
    }

    function createItem(uint256 tokenId) external {
        require(owners[tokenId] == address(0), "Token with such id exists");
        erc721.mintTo(msg.sender, tokenId);
        owners[tokenId] = msg.sender;
        amounts[tokenId] = 1;
        emit ItemCreated(tokenId, msg.sender, 1);
    }

    function createItem(uint256 amount, uint256 tokenId) external {
        require(amount != 0, "Amount cannot be zero");
        require(owners[tokenId] == address(0), "Token with such id exists");
        erc1155.mintTo(msg.sender, amount, tokenId);
        owners[tokenId] = msg.sender;
        amounts[tokenId] = amount;
        emit ItemCreated(tokenId, msg.sender, amount);
    }

    function listItem(uint256 tokenId, uint256 price) external {
        require(prices[tokenId] == 0, "This item is already listed");
        erc721.transferFrom(msg.sender, address(this), tokenId);
        prices[tokenId] = price;
        emit ItemListed(tokenId, msg.sender, amounts[tokenId], price);
    }

    function listItem(uint256 tokenId, uint256 price, uint256 amount) external {
        require(prices[tokenId] == 0, "This item is already listed");
        require(erc1155.balanceOf(msg.sender, tokenId) >= amount, "Not enough tokens to list");
        erc1155.transferFrom(msg.sender, address(this), tokenId, amount);
        prices[tokenId] = price;
        amounts[tokenId] = amount;
        emit ItemListed(tokenId, msg.sender, amount, price);
    }

    function cancel(uint256 tokenId) external  {
        require(prices[tokenId] != 0, "Item is not listed");
        delete prices[tokenId];
        emit ListingCanceled(tokenId);
    }

    function buyItem(uint256 tokenId) external {
        require(prices[tokenId] != 0, "Item is not listed");
        require(erc721.owners(tokenId) != address(0), "Token does not exist");
        erc20.transferTokensFrom(msg.sender, owners[tokenId], prices[tokenId]);
        erc721.transferFrom(address(this), msg.sender, tokenId);
        emit ItemBought(tokenId, msg.sender, amounts[tokenId], prices[tokenId]);
        owners[tokenId] = msg.sender;
        prices[tokenId] = 0;
    }

    function buyItem(uint256 tokenId, uint256 amount) external {
        require(prices[tokenId] != 0, "Item is not listed");
        erc20.transferTokensFrom(msg.sender, owners[tokenId], prices[tokenId].mul(amount));
        erc1155.transferFrom(address(this), msg.sender, tokenId, amount);
        emit ItemBought(tokenId, msg.sender, amount, prices[tokenId]);
        owners[tokenId] = msg.sender;
        prices[tokenId] = 0;
    }

    function listItemOnAuction(uint256 tokenId, uint256 minPrice) external {
        require(auctionStartedTime[tokenId] == 0, "Token is already on auction");
        erc721.transferFrom(msg.sender, address(this), tokenId);
        prices[tokenId] = minPrice;
        auctionStartedTime[tokenId] = block.timestamp;
        emit ItemListedOnAuction(tokenId, msg.sender, amounts[tokenId], minPrice, auctionStartedTime[tokenId]);
    }

    function listItemOnAuction(uint256 tokenId, uint256 minPrice, uint256 amount) external {
        require(auctionStartedTime[tokenId] == 0, "Token is already on auction");
        require(amounts[tokenId] >= amount, "Not enough tokens");
        erc1155.transferFrom(msg.sender, address(this), tokenId, amount);
        prices[tokenId] = minPrice;
        auctionStartedTime[tokenId] = block.timestamp;
        emit ItemListedOnAuction(tokenId, msg.sender, amount, minPrice, auctionStartedTime[tokenId]);
    }

    function finishAuction(uint256 tokenId) external {
        require(auctionStartedTime[tokenId] + AUCTION_PERIOD > block.timestamp, "Auction is not over yet");
        if (amounts[tokenId] == 1)
            erc721.transferFrom(address(this), lastBidder[tokenId], tokenId);
        else erc1155.transferFrom(address(this), lastBidder[tokenId], tokenId, amounts[tokenId]);
        emit AuctionFinished(tokenId, msg.sender, amounts[tokenId], prices[tokenId], auctionStartedTime[tokenId] + AUCTION_PERIOD);
        auctionStartedTime[tokenId] = 0;
        prices[tokenId] = 0;
        owners[tokenId] = lastBidder[tokenId];
        lastBidder[tokenId] = address(0);
    }

    function makeBid(uint256 tokenId, uint256 price) external {
        require(auctionStartedTime[tokenId] != 0, "Token is not on auction");        
        require(auctionStartedTime[tokenId] + AUCTION_PERIOD > block.timestamp, "Token is not on auction");
        require(prices[tokenId] < price, "Cannot pay <= current price");
        if (lastBidder[tokenId] != address(0))
            erc20.transfer(lastBidder[tokenId], price);
        erc20.transferFrom(msg.sender, address(this), price);
        prices[tokenId] = price;
        lastBidder[tokenId] = msg.sender;
        emit BidMade(tokenId, msg.sender, price);
    }
}
