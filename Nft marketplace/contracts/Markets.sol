// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract Markets {
    using Counters for Counters.Counter;
    Counters.Counter private _totaltokens;

    enum TokenStatus {
        Active,
        Sold,
        Cancelled
    }
    struct TokenData {
        address owner;
        address tokenAddress;
        uint256 tokenID;
        uint256 price;
        TokenStatus status;
    }
    mapping(uint256 => TokenData) private tokensList;

    /* events */
    event TokenListed(address owner, address tokenAddress, uint256 tokenID, uint256 tokenPrice, TokenStatus tokenStatus);
    event TokenSold(address from, address to, address tokenAddress, uint256 tokenID, uint256 price);
    event DeactivateToken(address tokenAddress, TokenStatus status);
    event ActiveToken(address tokenAddress, TokenStatus status);

    
    function listTokens(address _tokenAddress, uint256 _tokenID, uint256 _price) external {
        /* check sender should be the token owner */
        address owner = IERC721(_tokenAddress).ownerOf(_tokenID);
        require(msg.sender == owner, "You are not a owner of this token");

        /* now transfer the token to this address for selling purpose */
        IERC721(_tokenAddress).transferFrom(msg.sender, address(this), _tokenID);

        /* now update the mapping */
        _totaltokens.increment();
        uint256 newItemId = _totaltokens.current();
        tokensList[newItemId] = TokenData(msg.sender, _tokenAddress, _tokenID, _price, TokenStatus.Active);

        /* emitting an event */
        emit TokenListed(msg.sender, _tokenAddress, _tokenID, _price, TokenStatus.Active);
    }

    function buyToken(uint256 listingID) external payable {
        TokenData storage data = tokensList[listingID];
        address currentOwner = data.owner;

        /* checking the token status */
        require(data.status == TokenStatus.Active, "Token is not active");

        /* checking the buyer is the token owner or not */
        require(msg.sender != currentOwner, "Owner cannot purchase their own token");

        /* checking the price */
        require(msg.value >= data.price, "Insufficient amount");

        /* transferring the token */
        IERC721(data.tokenAddress).transferFrom(address(this), msg.sender, data.tokenID);

        /* transferring the amount to user and updating the status and owner */
        payable(data.owner).transfer(data.price);
        data.status = TokenStatus.Sold;
        data.owner = msg.sender;
        
        /* emitting an event */
        emit TokenSold(currentOwner, msg.sender, data.tokenAddress, data.tokenID, data.price);
    }

    function cancelSell(uint256 listingID) external {
        TokenData storage data = tokensList[listingID];

        /* checking the token status */
        require(data.status == TokenStatus.Active, "Token is not active");

        /* checking the buyer is the token owner or not */
        require(msg.sender == data.owner, "You must be the owner to deactivate the token");

        /* updating the status */
        data.status = TokenStatus.Cancelled;

        /* emitting an event */
        emit DeactivateToken(data.tokenAddress, TokenStatus.Cancelled);
    }

    function makeActive(uint256 listingID) external {
        TokenData storage data = tokensList[listingID];

        /* checking the token status */
        require(data.status == TokenStatus.Cancelled, "Token is should be deactivated to activate");

        /* checking the buyer is the token owner or not */
        require(msg.sender == data.owner, "You must be the owner to deactivate the token");

        /* updating the status */
        data.status = TokenStatus.Active;

        /* emitting an event */
        emit ActiveToken(data.tokenAddress, TokenStatus.Cancelled);
    }

    function getTokensList(uint256 listingID) external view returns (TokenData memory) {
        return tokensList[listingID];
    }
}