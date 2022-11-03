// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
  @title This contract for transferring the tokens by the whitelisted users
  @author Dravid Sajinraj
  @notice The contract calls are implemented with in this
 */
contract Token is ERC20, Ownable {
    uint256 public MINT_AMOUNT = 10 ** decimals();
    mapping(address => bool) public WHITELISTED_USERS;

    /// @notice constructor part
    constructor() ERC20("Milkey", "ML") {}

    /**
      @notice This function for minting erc20 tokens
      @param _to Address of the receipient
      @dev Only accessible by the owner of the contract
     */
    function mintToken(address _to) external onlyOwner {
        _mint(_to, MINT_AMOUNT);
    }

    /**
      @notice This function for minting erc20 tokens
      @param _to Address of the receipient
      @dev Only accessible by the owner of the contract
     */
    function burnToken(address _to) external onlyOwner {
        _burn(_to, MINT_AMOUNT);
    }

    /**
      @notice This function for whitelisting the users
      @param _useraddress Address of the user
      @dev Only accessible by the owner of the contract
     */
    function addUsers(address _useraddress) external onlyOwner {
        WHITELISTED_USERS[_useraddress] = true;
    }

    /**
      @notice This function for removing the user from whitelist
      @param _useraddress Address of the user
      @dev Only accessible by the owner of the contract
     */
    function removeUsers(address _useraddress) external onlyOwner {
        WHITELISTED_USERS[_useraddress] = false;
    }

    /**
      @notice This function for transferring the tokens to another user
      @param _toAddress Address of the to user
      @param amount Amount to be transferred
      @return bool true
     */
    function transfer(address _toAddress, uint256 amount) public override returns (bool) {
        require(WHITELISTED_USERS[msg.sender] == true, 'You are not allowed to transfer the tokens');
        address owner = _msgSender();
        _transfer(owner, _toAddress, amount);
        return true;
    }

    /**
      @notice This function for transferring the tokens to another user
      @param _fromAddress Address of the from user
      @param _toAddress Address of the to user
      @param amount Amount to be transferred
      @return bool true
     */
    function transferFrom(address _fromAddress, address _toAddress, uint256 amount) public override returns (bool) {
        require(WHITELISTED_USERS[msg.sender] == true, 'You are not allowed to transfer the tokens');
        address spender = _msgSender();
        _spendAllowance(_fromAddress, spender, amount);
        _transfer(_fromAddress, _toAddress, amount);
        return true;
    }
}