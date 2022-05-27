// SPDX-License-Identifier: No-License
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyERC721 is ERC721 {
    using Counters for Counters.Counter;
    
    Counters.Counter private currentTokenId;

    constructor(string memory name_, string memory symbol_)
    ERC721(name_, symbol_) {}

    function mintTo(address receiver) public returns(uint) {
        currentTokenId.increment();
        uint id = currentTokenId.current();
        _safeMint(receiver, id);
        emit Transfer(address(0), receiver, id);
        return id;
    }
}
