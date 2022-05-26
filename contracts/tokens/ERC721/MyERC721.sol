// SPDX-License-Identifier: No-License
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MyERC721 is ERC721 {
    string private baseUri = "https://token-cdn-domain/";
    uint256 private tokenIds;

    constructor(string memory name_, string memory symbol_)
    ERC721(name_, symbol_)
    {
        tokenIds = 1;
    }

    function tokenURI(uint256 _id) public override view returns (string memory) {
        return string(abi.encodePacked(baseUri, Strings.toString(_id), ".json"));
    }

    function awardItem(address player) public returns(uint256) {
        uint256 newItemId = tokenIds++;
        _mint(player, newItemId);
        return newItemId;
    }

    function _baseURI()
        internal override
        view virtual
        returns(string memory) {
        return baseUri;
    }
}
