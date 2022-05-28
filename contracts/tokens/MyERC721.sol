// SPDX-License-Identifier: No-License
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyERC721 is ERC721 {
    string private _uri;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory uri_
    ) ERC721(name_, symbol_) {
        setUri(uri_);
    }

    function mintTo(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _uri;
    }

    function setUri(string memory uri) internal {
        _uri = uri;
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
