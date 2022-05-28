// SPDX-License-Identifier: No-License
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyERC1155 is ERC1155 {
    using Counters for Counters.Counter;
    
    Counters.Counter private currentTokenId;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_, string memory uri_)
    ERC1155(uri_)
    {
        _name = name_;
        _symbol = symbol_;
    }

    function mintTo(address account, uint256 amount) public returns(uint) {
        uint id = currentTokenId.current();
        currentTokenId.increment();
        _mint(account, id, amount, "");
        emit TransferSingle(address(0), address(0), account, id, amount);
        return id;
    }

    function mintBatch(address account, uint256[] memory amounts) public {
        for (uint i = 0; i < amounts.length; i++) {
            currentTokenId.increment();
            _balances[currentTokenId.current()][account] = amounts[i];
        }
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }
}
