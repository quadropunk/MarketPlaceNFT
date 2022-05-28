// SPDX-License-Identifier: No-License
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyERC721 is ERC721 {
    using Counters for Counters.Counter;
    string private _uri;
    
    Counters.Counter private currentTokenId;

    constructor(string memory name_, string memory symbol_, string memory uri_)
    ERC721(name_, symbol_) {
        setUri(uri_);
    }

    function mintTo(address receiver) public returns(uint) {
        currentTokenId.increment();
        uint id = currentTokenId.current();
        _safeMint(receiver, id);
        emit Transfer(address(0), receiver, id);
        return id;
    }
    
    function _baseURI() internal override view virtual returns (string memory) {
        return _uri;
    }
    
    function setUri(string memory uri) internal {
        _uri = uri;
    }
}
