// SPDX-License-Identifier: No-License
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyERC721 is ERC721 {
    constructor(string memory name_, string memory symbol_)
    ERC721(name_, symbol_)
    {
        for (uint id = 1; id < 100; id++)
            _mint(msg.sender, id);
    }
}
