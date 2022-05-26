// SPDX-License-Identifier: No-License
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MyERC1155 is ERC1155 {
    constructor()
    ERC1155("https://token-cdn-domain/")
    {
        _mint(msg.sender, 1, 10, "");
    }

    function tokenUri(uint256 _id) public view returns (string memory) {
        return string(abi.encodePacked(uri(0), Strings.toString(_id), ".json"));
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data) public {
        _mint(account, id, amount, data);
    }

    function mintBatch(address account, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public {
        _mintBatch(account, ids, amounts, data);
    }
}
