//SPDX-License-Identifier: MIT

pragma abicoder v2;
pragma solidity 0.7.6;

import {Test} from "../../lib/forge-std/src/Test.sol";
import {Token} from "../../src/Token.sol";

contract TokenViewTests is Test {
    //////////////////////////////////
    /////      Variables       //////
    ////////////////////////////////
    Token public token;
    address owner;
    address user1;
    
    uint256 public constant TOTAL_SUPPLY = 100000e18;
    uint256 public constant AMOUNT = 100;



    // ///////////////////////////////
    // /////      Set Up       //////
    // /////////////////////////////
    function setUp() public {
        owner = makeAddr("owner");
        vm.deal(owner, 10 ether);

        vm.prank(owner);
        token = new Token("Token", "TKN", TOTAL_SUPPLY);

        user1 = makeAddr("user1");
        vm.deal(user1, 10 ether);
    }



    // ///////////////////////////////////////////
    // /////      Total Supply Tests       //////
    // /////////////////////////////////////////
    function testTotalSupply() public view {
        uint256 totalSupply = token.totalSupply();

        assertEq(totalSupply, TOTAL_SUPPLY);
    }



    // /////////////////////////////////////////
    // /////      BalanceOf Tests       //////
    // ///////////////////////////////////////
    function testBalanceOf() public {
        vm.prank(owner);
        token.transfer(user1, AMOUNT);

        uint256 user1Balance = token.balanceOf(user1);

        assertEq(user1Balance, AMOUNT);
    }



    // ////////////////////////////////////////
    // /////      Allowance Tests       //////
    // //////////////////////////////////////
    function testAllowance() public {
        vm.prank(owner);
        token.approve(user1, AMOUNT);

        uint256 allowance = token.allowance(owner, user1);

        assertEq(allowance, AMOUNT);
    }
}