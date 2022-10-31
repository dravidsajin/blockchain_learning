// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20, Ownable {
    uint256 public MINT_AMOUNT = 10 ** decimals();
    mapping(address => bool) public WHITELISTED_USERS;

    constructor() ERC20("Milkey", "ML") {}

    function mintToken(address _to) external onlyOwner {
        _mint(_to, MINT_AMOUNT);
    }

    function burnToken(address _to) external onlyOwner {
        _burn(_to, MINT_AMOUNT);
    }

    function addUsers(address _useraddress) external onlyOwner {
        WHITELISTED_USERS[_useraddress] = true;
    }

    function removeUsers(address _useraddress) external onlyOwner {
        WHITELISTED_USERS[_useraddress] = false;
    }

    function transfer(address _toAddress, uint256 amount) public override returns (bool) {
        require(WHITELISTED_USERS[msg.sender] == true, 'You are not allowed to transfer the tokens');
        address owner = _msgSender();
        _transfer(owner, _toAddress, amount);
        return true;
    }

    function transferFrom(address _fromAddress, address _toAddress, uint256 amount) public override returns (bool) {
        require(WHITELISTED_USERS[msg.sender] == true, 'You are not allowed to transfer the tokens');
        address spender = _msgSender();
        _spendAllowance(_fromAddress, spender, amount);
        _transfer(_fromAddress, _toAddress, amount);
        return true;
    }
}