//SPDX-License-Identifier: MIT

pragma abicoder v2;
pragma solidity 0.7.6;

import {Test} from "../../lib/forge-std/src/Test.sol";
import {Token} from "../../src/Token.sol";

contract BurnTests is Test {
    //////////////////////////////////
    /////      Variables       //////
    ////////////////////////////////
    Token public token;
    address factory;
    address user1;

    uint256 public constant AMOUNT = 100;
    uint256 public constant TOTAL_SUPPLY = 100000e18;
    uint256 public constant EXCESS_AMOUNT = TOTAL_SUPPLY + AMOUNT;



    ///////////////////////////////
    /////      Set Up       //////
    /////////////////////////////
    function setUp() public {
        factory = makeAddr("owner");
        vm.deal(factory, 10 ether);

        vm.startPrank(factory);
        token = new Token("Token", "TKN", TOTAL_SUPPLY);
        vm.stopPrank();

        user1 = makeAddr("user1");
        vm.deal(user1, 10 ether);
    }



    ///////////////////////////////////
    /////      Burn Tests       //////
    /////////////////////////////////
    function testBurn() public {
        uint256 previousTotalSupply = token.totalSupply();
        uint256 previousUserBalance = token.balanceOf(factory);

        vm.prank(factory);
        token.burn(AMOUNT);

        uint256 currentTotalSupply = token.totalSupply();
        uint256 currentUserBalance = token.balanceOf(factory);

        assertEq(previousTotalSupply, currentTotalSupply + AMOUNT);
        assertEq(previousUserBalance, currentUserBalance + AMOUNT);
    }


    function testRevertIfBurnerIsNotFactory() public {
        vm.prank(user1);
        vm.expectRevert("Must Be Factory");
        token.burn(AMOUNT);
    }


    function testRevertIfBurnedFactoryBurnsMoreThanTheRemainingTokens() public {
        vm.prank(factory);
        vm.expectRevert("You Do Not Have Enough Tokens");
        token.burn(EXCESS_AMOUNT);
    }
}