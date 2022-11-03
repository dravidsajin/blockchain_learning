// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Milkey is ERC20, Ownable {
    uint256 public MINT_AMOUNT = 10 ** decimals();
    constructor() ERC20("Milkey", "ML") {
        _mint(msg.sender, MINT_AMOUNT);
    }

    function mintToken(address _to) external onlyOwner {
        _mint(_to, MINT_AMOUNT);
    }

    function burnToken(address _to) external onlyOwner {
        _burn(_to, MINT_AMOUNT);
    }
}