// SPDX-License-Identifier: No License
pragma solidity ^0.8.0;

contract Marketplace {
    uint256 private ids;
    address public owner;

    constructor() {
        ids = 0;
        owner = msg.sender;
    }

    /// @notice creates NFT
    function createItem(string memory tokenUri_, address owner_) external {

    }

    /// @notice mints NFT (ERC721, ERC1155)
    function mint() internal {

    }

    /// @notice puts up for sale
    function listItem(uint256 tokenId_, uint256 price_) external {

    }

    /// @notice cancels sale
    function cancel(uint256 tokenId_) external {

    }

    /// @notice buys token
    function buyItem(uint256 tokenId_) external {

    }
}