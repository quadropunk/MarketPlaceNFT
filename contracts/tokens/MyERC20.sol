// SPDX-License-Identifier: No-License
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyERC20 is ERC20 {
    constructor(string memory name_, string memory symbol_)
    ERC20(name_, symbol_) {}

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }

    function transferTokensFrom(address from, address to, uint256 amount) public returns(bool) {
        require(_balances[from] >= amount, "Not enough tokens");
        require(_allowances[from][to] >= amount, "Insufficient allowance");
        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][to] -= amount;
        return true;
    }

    function approveTokens(address spender, uint256 amount) public {
        require(_balances[msg.sender] >= amount, "Not enough tokens");
        _allowances[msg.sender][spender] = amount;
    }
}
