//SPDX-License-Identifier: MIT

pragma abicoder v2;
pragma solidity 0.7.6;

import {Test} from "../../lib/forge-std/src/Test.sol";
import {Token} from "../../src/Token.sol";
import {TokenFactory} from "../../src/TokenFactory.sol";
import {MockWETH9} from "../mocks/MockWETH9.sol";
import {MockPositionManager} from "../mocks/MockPositionManager.sol";

contract SellTokensTest is Test {
    //////////////////////////////
    /////     Variables     /////
    ////////////////////////////
    TokenFactory public tokenFactory;
    uint256 public constant TOTAL_SUPPLY = 100000e18;
    uint256 public constant AMOUNT = 1 ether;
    uint256 public constant REQUIRED_ETH = 10 ether;
    address owner;
    address user1;
    address user2;
    address newToken;
    MockWETH9 mockWETH9;
    MockPositionManager mockPositionManager;



    ///////////////////////////
    /////     Set Up     /////
    /////////////////////////
    function setUp() public {
        owner = makeAddr("owner");
        vm.deal(owner, 10 ether);
        user1 = makeAddr("user1");
        vm.deal(user1, 10 ether);
        user2 = makeAddr("user2");
        vm.deal(user2, 20 ether);

        mockWETH9 = new MockWETH9();
        mockPositionManager = new MockPositionManager();

        vm.startPrank(owner);
        tokenFactory = new TokenFactory(address(mockWETH9), address(mockPositionManager));
        vm.stopPrank();

        vm.startPrank(user1);
        newToken = tokenFactory.createToken{value: tokenFactory.i_fee()}(
            "UserToken",
            "UTK"
        );
        vm.stopPrank();
    }



    /////////////////////////////////////
    /////     Sell Token Tests     /////
    ///////////////////////////////////
    function testSellTokens() public {
        vm.prank(user2);
        uint256 tokensBought = tokenFactory.buyTokens{value: AMOUNT}(newToken);
        uint256 previousUserTokenBalance = Token(newToken).balanceOf(user2);
        uint256 previousUserEthBalance = user2.balance;

        vm.prank(user2);
        uint256 ethReceived = tokenFactory.sellTokens(newToken, tokensBought);
        uint256 currentUserTokenBalance = Token(newToken).balanceOf(user2);
        uint256 currentUserEthBalance = user2.balance;

        assertEq(currentUserTokenBalance, previousUserTokenBalance - tokensBought);
        assertEq(currentUserEthBalance, previousUserEthBalance + ethReceived);
    }

    function testSellTokensUpdatesTokenData() public {
        vm.prank(user2);
        uint256 tokensBought = tokenFactory.buyTokens{value: AMOUNT}(newToken);

        TokenFactory.TokenData memory previousTokenData = tokenFactory.getTokenData(newToken);
        uint256 previousEthRaised = previousTokenData.ethRaised;
        uint256 previousTokensSold = previousTokenData.tokensSold;

        vm.prank(user2);
        uint256 ethReceived = tokenFactory.sellTokens(newToken, tokensBought);

        TokenFactory.TokenData memory currentTokenData = tokenFactory.getTokenData(newToken);
        uint256 currentEthRaised = currentTokenData.ethRaised;
        uint256 currentTokensSold = currentTokenData.tokensSold;

        assertEq(currentEthRaised, previousEthRaised - ethReceived);
        assertEq(currentTokensSold, previousTokensSold - tokensBought);
    }

    function testRevertIfUserSellsAfterTokenHasBeenAddedToLiquidityPool() public {
        vm.prank(user2);
        uint256 tokensBought = tokenFactory.buyTokens{value: REQUIRED_ETH}(newToken);

        vm.prank(user2);
        vm.expectRevert("Token sale is closed");
        tokenFactory.sellTokens(newToken, tokensBought);
    }


    function testRevertIfUserSellsMoreTokensThanTheyHave() public {
        vm.prank(user2);
        uint256 tokensBought = tokenFactory.buyTokens{value: AMOUNT}(newToken);

        uint256 doubleTokens = tokensBought * 2;

        vm.prank(user2);
        vm.expectRevert("Not enough token balance");
        tokenFactory.sellTokens(newToken, doubleTokens);
    }
}