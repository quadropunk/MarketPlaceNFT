// SPDX-License-Identifier: No-License
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MyERC721 is ERC721URIStorage {
    using Strings for uint256;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseUri_
    ) ERC721(name_, symbol_) {
        _baseUri = baseUri_;
    }

    function mintTo(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenId.toString());
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
