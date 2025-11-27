//SPDX-License-Identifier: MIT

pragma abicoder v2;
pragma solidity 0.7.6;

import {Test} from "../../lib/forge-std/src/Test.sol";
import {Token} from "../../src/Token.sol";

contract TransferTests is Test {
    //////////////////////////////////
    /////      Variables       //////
    ////////////////////////////////
    Token public token;
    address owner;
    address user1;
    address user2;

    uint256 public constant AMOUNT = 100;
    uint256 public constant TOTAL_SUPPLY = 100000e18;
    uint256 public constant DOUBLE_AMOUNT = 200;



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
        user2 = makeAddr("user2");
        vm.deal(user2, 10 ether);
    }



    // ///////////////////////////////////////
    // /////      Transfer Tests       //////
    // /////////////////////////////////////
    function testTransfer() public {
        vm.prank(owner);
        token.transfer(user1, AMOUNT);

        uint256 receiverTokenBalance = token.balanceOf(user1);

        assertEq(receiverTokenBalance, AMOUNT);
    }


    function testTransferUpdatesUsersBalances() public {
        uint256 initialSenderBalance = token.s_balances(owner);
        uint256 initialRecieverBalance = token.s_balances(user1);
        vm.prank(owner);
        token.transfer(user1, AMOUNT);

        uint256 finalSenderBalance = token.s_balances(owner);
        uint256 finalReceiverBalance = token.s_balances(user1);

        assertEq(finalSenderBalance, initialSenderBalance - AMOUNT);
        assertEq(finalReceiverBalance, initialRecieverBalance + AMOUNT);
    }


    function testRevertIfUserDoesNotHaveEnoughTokens() public {
        vm.prank(user2);
        vm.expectRevert("You do not have enough tokens");
        token.transfer(user1, AMOUNT);
    }


    function testRevertIfTransferredToContract() public {
        vm.prank(owner);
        vm.expectRevert("invalid address");
        token.transfer(address(0), AMOUNT);
    }



    // ///////////////////////////////////////////
    // /////      TransferFrom Tests       //////
    // /////////////////////////////////////////
    function testTransferFrom() public {
        vm.prank(owner);
        token.approve(user1, AMOUNT);

        vm.prank(user1);
        token.transferFrom(owner, user2, AMOUNT);

        uint256 user2Balance = token.balanceOf(user2);

        assertEq(user2Balance, AMOUNT);
    }


    function testTransferFromUpdatesBalances() public {
        uint256 initialSenderBalance = token.s_balances(owner);
        uint256 initialRecieverBalance = token.s_balances(user2);
        vm.prank(owner);
        token.approve(user1, AMOUNT);

        vm.prank(user1);
        token.transferFrom(owner, user2, AMOUNT);

        uint256 finalSenderBalance = token.s_balances(owner);
        uint256 finalReceiverBalance = token.s_balances(user2);

        assertEq(finalSenderBalance, initialSenderBalance - AMOUNT);
        assertEq(finalReceiverBalance, initialRecieverBalance + AMOUNT);
    }


    function testRevertIfZeroAddressIsPut() public {
        vm.prank(owner);
        token.approve(user1, AMOUNT);

        vm.prank(user1);
        vm.expectRevert("invalid address");
        token.transferFrom(owner, address(0), AMOUNT);
    }


    function testRevertIfSpenderIsNotApproved() public {
        vm.prank(user1);
        vm.expectRevert("insufficient allowance");
        token.transferFrom(owner, user2, AMOUNT);
    }


    function testRevertIfSpenderSpendsMoreThanTheyAreAllowed() public {
        vm.prank(owner);
        token.approve(user1, AMOUNT);

        vm.prank(user1);
        vm.expectRevert("insufficient allowance");
        token.transferFrom(owner, user2, DOUBLE_AMOUNT);
    }
}