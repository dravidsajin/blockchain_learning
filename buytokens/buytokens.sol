// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
contract buyErc20 is ERC20{
    uint256 public tokenAmountEth;
    address public contractowner;
    event mintSuccess(uint256 tokenvalue, string message, address mintedUser);
    event tokenTransferred(string message, address toUser);

    constructor() ERC20("myToken","DS"){
        tokenAmountEth = 0.0001 * 10 ** 18;
        contractowner = msg.sender;
    }

    modifier onlyOwner() { 
        require(msg.sender == contractowner, "Only owner can change the price of token");
        _;
    }

    function changeTokenPrice(uint256 price) public onlyOwner {
        tokenAmountEth = price;
    }

    function buy(address payable _to) public payable {
        uint256 totalTokens = div(msg.value, tokenAmountEth, "Entered amount should be greater then zero");
        _mint(msg.sender, totalTokens);
        emit mintSuccess(totalTokens, "tokens minted to", msg.sender);
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
}