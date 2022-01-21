// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NewToken is ERC20, Ownable {
    constructor() ERC20('myToken','TruffCoin') {
        _mint(msg.sender, 10000 * 10 ** decimals());
        // _burn(msg.sender, 1000 * 10 ** decimals());
    }

    function mint(address to,uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
