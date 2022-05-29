// SPDX-License-Identifier: No License
pragma solidity ^0.8.0;

import "./tokens/MyERC20.sol";
import "./tokens/MyERC721.sol";
import "./tokens/MyERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Marketplace {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    Counters.Counter private currentTokenId;

    struct SellingOrder {
        address owner;
        uint256 price;
    }

    MyERC20 public erc20;
    MyERC721 public erc721;
    MyERC1155 public erc1155;

    mapping(uint256 => SellingOrder) public tokensInfo;

    constructor(address erc20_, address erc721_, address erc1155_) {
        erc20 = MyERC20(erc20_);
        erc721 = MyERC721(erc721_);
        erc1155 = MyERC1155(erc1155_);
    }

    modifier onlyTokenOwner(uint256 tokenId) {
        if (tokensInfo[tokenId].owner != msg.sender)
            revert("You are not owner of this token");
        _;
    }

    function createItem(uint256 tokenId) external {
        require(tokensInfo[tokenId].owner == address(0), "Token with such id exists");
        erc721.mintTo(msg.sender, tokenId);
        tokensInfo[tokenId] = SellingOrder({
            owner: msg.sender,
            price: 0
        });
    }

    function createItem(uint256 amount, uint256 tokenId) external {
        require(amount != 0, "Amount cannot be zero");
        require(tokensInfo[tokenId].owner == address(0), "Token with such id exists");
        erc1155.mintTo(msg.sender, amount, tokenId);
        tokensInfo[tokenId] = SellingOrder({
            owner: msg.sender,
            price: 0
        });
    }

    function listItem(uint256 tokenId, uint256 price) external onlyTokenOwner(tokenId) {
        require(tokensInfo[tokenId].price == 0, "This item is already listed");
        tokensInfo[tokenId].price = price;
    }

    function listItem(uint256 tokenId, uint256 price, uint256 amount) external onlyTokenOwner(tokenId) {
        require(tokensInfo[tokenId].price == 0, "This item is already listed");
        require(erc1155.balanceOf(msg.sender, tokenId) >= amount, "Not enough tokens to list");
        tokensInfo[tokenId].price = price;
    }

    function cancel(uint256 tokenId) external onlyTokenOwner(tokenId) {
        require(tokensInfo[tokenId].price != 0, "Item is not listed");
        tokensInfo[tokenId].price = 0;
    }

    function buyItem(uint256 tokenId) external {
        require(tokensInfo[tokenId].price != 0, "Item is not listed");
        require(erc721.owners(tokenId) != address(0), "Token does not exist");
        require(erc20.transferFrom(msg.sender, tokensInfo[tokenId].owner, tokensInfo[tokenId].price), "Transaction cancelled");
        erc721.transferFrom(tokensInfo[tokenId].owner, msg.sender, tokenId);
        tokensInfo[tokenId].owner = msg.sender;
        tokensInfo[tokenId].price = 0;
    }

    function buyItem(uint256 tokenId, uint256 amount) external {
        require(tokensInfo[tokenId].price != 0, "Item is not listed");
        require(erc1155.balanceOf(tokensInfo[tokenId].owner, tokenId) >= amount, "Not enough tokens in stock");
        require(erc20.transferFrom(msg.sender, tokensInfo[tokenId].owner, tokensInfo[tokenId].price.mul(amount)), "Transaction cancelled");
        erc1155.safeTransferFrom(tokensInfo[tokenId].owner, msg.sender, tokenId, amount, "");
        tokensInfo[tokenId].owner = msg.sender;
        tokensInfo[tokenId].price = 0;
    }
}
