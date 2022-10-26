// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20, Ownable {
    uint256 public MINT_AMOUNT = 10 ** decimals();
    address[] public WHITELISTED_USERS;

    constructor() ERC20("Milkey", "ML") {}
    
    function getTotalUsers() public view returns (uint) {
        return WHITELISTED_USERS.length;
    }

    function mintToken(address _to) external onlyOwner {
        _mint(_to, MINT_AMOUNT);
    }

    function burnToken(address _to) external onlyOwner {
        _burn(_to, MINT_AMOUNT);
    }

    function addUsers(address _useraddress) external onlyOwner {
        require(WHITELISTED_USERS.length <= 10, 'Cannot add more than 10 users');
        WHITELISTED_USERS.push(_useraddress);
    }

    function removeUsers(address _useraddress) external onlyOwner {
        require(WHITELISTED_USERS.length > 0, 'No users found');

        for (uint256 i = 0; i < WHITELISTED_USERS.length; i++) {
            if (_useraddress == WHITELISTED_USERS[i]) {
                address lastPositionAddress = WHITELISTED_USERS[WHITELISTED_USERS.length - 1];
                WHITELISTED_USERS[i] = lastPositionAddress;
                WHITELISTED_USERS.pop();
                break;
            }
        }
    }

    function transferTokens(address _fromAddress, address _toAddress, uint256 amount) external {
        bool isExist = false;
         for (uint256 i = 0; i < WHITELISTED_USERS.length; i++) {
            if (msg.sender == WHITELISTED_USERS[i]) {
                isExist = true;
                break;
            }
        }
        require(isExist == true, 'You are not allowed to transfer the tokens');
        transferFrom(_fromAddress, _toAddress, amount);
    }
}