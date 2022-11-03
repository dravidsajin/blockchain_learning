// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
  @title This is a erc 20 contract
  @author Dravid Sajinraj
  @notice The contract calls are implemented with in this
 */
contract Milkey is ERC20, Ownable {
    uint256 public MINT_AMOUNT = 10 ** decimals();

    /// @notice constructor part
    constructor() ERC20("Milkey", "ML") {
        _mint(msg.sender, MINT_AMOUNT);
    }

    /**
      @notice This function for minting erc20 tokens
      @param _to Address of the receipient
      @dev Only accessible by the owner of the contract
     */
    function mintToken(address _to) external onlyOwner {
        _mint(_to, MINT_AMOUNT);
    }

    /**
      @notice This function for burning the erc20 tokens
      @param _to Address of the receipient
      @dev Only accessible by the owner of the contract
     */
    function burnToken(address _to) external onlyOwner {
        _burn(_to, MINT_AMOUNT);
    }
}