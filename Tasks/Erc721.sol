// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Football is ERC721, Ownable {
    uint256 constant MaxLimit = 10;

    using Counters for Counters.Counter;
    Counters.Counter private tokenIds; 
    constructor() ERC721 ("Messi", "GOAT") {
        mintTokens(msg.sender, 10);
    }

    function mintTokens(address to, uint256 limit) public onlyOwner {
        require(limit <= MaxLimit, 'Token limit crossed the max limit');
        for (uint256 i = 0; i < limit; i++) {
            mintToken(to);
        }
    }

    function mintToken(address to) public onlyOwner {
        tokenIds.increment();
        uint256 newTokenId = tokenIds.current();
        _safeMint(to, newTokenId);
    }
}