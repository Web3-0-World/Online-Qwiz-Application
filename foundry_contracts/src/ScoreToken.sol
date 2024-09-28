// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ScoreToken is ERC20, Ownable {
    constructor()
        ERC20("ScoreToken", "ST")
        Ownable(msg.sender)
    {}
    function mint(address to, uint256 amount) onlyOwner public {
        _mint(to, amount);
    }
    function bal(address to) onlyOwner public view returns (uint256) {
        return balanceOf(to);
    }
}