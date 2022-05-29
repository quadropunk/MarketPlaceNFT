// SPDX-License-Identifier: No-License
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract MyERC1155 is ERC1155 {
    mapping(uint256 => mapping(address => uint256)) private approvals;

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

    function approve(address to, uint256 tokenId, uint256 amount) public {
        approvals[tokenId][to] = amount;
    }

    function transferFrom(address from, address to, uint256 tokenId, uint256 amount) public {
        require(from != to, "Cannot send back to sender");
        require(approvals[tokenId][to] >= amount, "Receiver is not approved");
        require(balances[tokenId][from] >= amount, "Not enough balance");
        approvals[tokenId][to] -= amount;
        balances[tokenId][to] += amount;
        balances[tokenId][from] -= amount;
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
