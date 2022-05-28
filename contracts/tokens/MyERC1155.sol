// SPDX-License-Identifier: No-License
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyERC1155 is ERC1155 {
    using Counters for Counters.Counter;
    
    Counters.Counter private currentTokenId;

    string private _name = "MyERC1155";
    string private _symbol = "MERC1155";

    constructor()
    ERC1155("https://bafybeiditohxkmdsrpeivbpy64vjftilx63kbavwtqzhhrzbgw7vjygg7y.ipfs.nftstorage.link/metadata/")
    {
        mintTo(msg.sender, 10);
    }

    function mintTo(address account, uint256 amount) public returns(uint) {
        currentTokenId.increment();
        uint id = currentTokenId.current();
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
