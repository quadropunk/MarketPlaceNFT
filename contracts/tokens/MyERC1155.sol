// SPDX-License-Identifier: No-License
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract MyERC1155 is ERC1155 {
    string private _name;
    string private _symbol;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory uri_
    ) ERC1155(uri_) {
        _name = name_;
        _symbol = symbol_;
    }

    function mintTo(
        address account,
        uint256 amount,
        uint256 tokenId
    ) public {
        _mint(account, tokenId, amount, "");
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
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
