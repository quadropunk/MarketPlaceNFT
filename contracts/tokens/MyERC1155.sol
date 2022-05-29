// SPDX-License-Identifier: No-License
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract MyERC1155 is ERC1155 {
    constructor(
        string memory uri_
    ) ERC1155(uri_) {}

    function mintTo(
        address account,
        uint256 amount,
        uint256 tokenId
    ) public {
        _mint(account, tokenId, amount, "");
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
