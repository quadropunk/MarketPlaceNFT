// SPDX-License-Identifier: No License
pragma solidity ^0.8.0;

import "./tokens/MyERC20.sol";
import "./tokens/MyERC721.sol";
import "./tokens/MyERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Marketplace {
    using Counters for Counters.Counter;

    Counters.Counter private currentTokenId;

    struct NFT {
        address owner;
        uint256 amount;
        bool forSale;
        uint256 price;
        bool sold;
    }

    MyERC20 private erc20;
    MyERC721 private erc721;
    MyERC1155 private erc1155;

    mapping(uint256 => NFT) public nfts;

    constructor(address erc20_, address erc721_, address erc1155_) {
        erc20 = MyERC20(erc20_);
        erc721 = MyERC721(erc721_);
        erc1155 = MyERC1155(erc1155_);
    }

    function createItem(uint256 tokenId) external {
        require(nfts[tokenId].owner == address(0), "Token with such id exists");
        erc721.mintTo(msg.sender, tokenId);
        nfts[tokenId] = NFT({
            owner: msg.sender,
            amount: 1,
            forSale: false,
            price: 0,
            sold: false
        });
    }

    function createItem(uint256 amount, uint256 tokenId) external {
        require(amount != 0, "Amount cannot be zero");
        require(nfts[tokenId].owner == address(0), "Token with such id exists");
        erc1155.mintTo(msg.sender, amount, tokenId);
        nfts[tokenId] = NFT({
            owner: msg.sender,
            amount: amount,
            forSale: false,
            price: 0,
            sold: false
        });
    }

    function listItem(uint256 tokenId, uint256 price) external {
        require(
            nfts[tokenId].sold == false && nfts[tokenId].forSale == false,
            "Already sold or listed"
        );
        nfts[tokenId].forSale = true;
        nfts[tokenId].price = price;
    }

    function cancel(uint256 tokenId) external {
        require(
            nfts[tokenId].sold == false && nfts[tokenId].forSale == true,
            "Sold or not listed"
        );
        nfts[tokenId].forSale = false;
    }

    function buyItem(uint256 tokenId) external {
        require(
            nfts[tokenId].sold == false && nfts[tokenId].forSale == true,
            "Sold or not listed"
        );
        require(erc20.transferFrom(msg.sender, nfts[tokenId].owner, nfts[tokenId].price), "Transaction cancelled");
        nfts[tokenId].sold = true;
    }
}
