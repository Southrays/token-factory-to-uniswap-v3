//SPDX-License-Identifier: MIT

pragma abicoder v2;
pragma solidity 0.7.6;

import {Test} from "../../lib/forge-std/src/Test.sol";
import {Token} from "../../src/Token.sol";

contract AllowanceAndApprovalTests is Test {
    //////////////////////////////////
    /////      Variables       //////
    ////////////////////////////////
    Token public token;
    address owner;
    address user1;

    uint256 public constant TOTAL_SUPPLY = 100000e18;
    uint256 public constant AMOUNT = 100;
    uint256 public constant DOUBLE_AMOUNT = 200;
    uint256 public constant EXCESS_AMOUNT = TOTAL_SUPPLY + AMOUNT;



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



    //////////////////////////////////////
    /////      Approve Tests       //////
    ////////////////////////////////////
    function testApprove() public {
        vm.prank(owner);
        token.approve(user1, AMOUNT);

        uint256 allowedSpend = token.allowance(owner, user1);

        assertEq(allowedSpend, AMOUNT);
    }


    function testApproveUpdatesAllowances() public {
        vm.prank(owner);
        token.approve(user1, AMOUNT);

        uint256 spenderAllowance = token.allowance(owner, user1);

        assertEq(spenderAllowance, AMOUNT);
    }
    

    function testRevertIfTokenHolderApprovesMoreEthThanTheyHave() public {
        vm.prank(owner);
        vm.expectRevert("You do not have enough tokens");
        token.approve(user1, EXCESS_AMOUNT);
    }
}