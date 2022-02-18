// SPDX-License-Identifier: MIT
pragma solidity ^0.5.12;

import "./IERC20.sol";
import "./CTokenInterface.sol";
import "./ComptrollerInterface.sol";

contract compound {

    IERC20 public Dai;
    CTokenInterface public cDai;
    IERC20 public Bat;
    CTokenInterface public cBat;
    ComptrollerInterface public comptroller;

    constructor (
        address _dai,
        address _cDai,
        address _bat,
        address _cBat,
        address _comptroller
    ) public {
        Dai = IERC20(_dai);
        cDai = CTokenInterface(_cDai);
        Bat = IERC20(_bat);
        cBat = CTokenInterface(_cBat);
        comptroller = ComptrollerInterface(_comptroller);
    }

    function invest(uint collatral) external {
        Dai.approve(address(cDai), collatral);
        require(cDai.mint(collatral) == 0, "Compound mint failed");
    }

    function getBalance() public view returns (uint) {
        return cDai.balanceOf(address(this));
    }

    function fetchUnderlying() public returns (uint) {
        uint bal = cDai.balanceOfUnderlying(address(this));
        return bal;
    }

    function redeemToken(address transferAddress) external {
        uint balance = getBalance();
        cDai.redeem(balance);
        // cDai.transfer(transferAddress, balance);
    }

    function borrow(uint collatral, uint borrowAmount) external {
        Dai.approve(address(cDai), collatral);
        cDai.mint(collatral);

        address[] memory markets = new address[](1);
        markets[0] = address(cDai);
        comptroller.enterMarkets(markets);
        cBat.borrow(borrowAmount);
    }

    function repay(uint borrowedAmount) external {
        Bat.approve(address(cBat), borrowedAmount);
        cBat.repayBorrow(borrowedAmount);
    }
}






