//SPDX-License-Identifier: MIT

pragma abicoder v2;
pragma solidity 0.7.6;

import {Test} from "../../lib/forge-std/src/Test.sol";
import {TokenFactory} from "../../src/TokenFactory.sol";
import {Token} from "../../src/Token.sol";

contract WithdrawEthTests is Test {
    //////////////////////////////
    /////     Variables     /////
    ////////////////////////////
    // Token public token;
    TokenFactory public tokenFactory;
    uint256 public constant TOTAL_SUPPLY = 100000e18;
    uint256 public constant INVALID_FEE = 0.0001 ether;
    address owner;
    address user1;
    address user2;



    ///////////////////////////
    /////     Set Up     /////
    /////////////////////////
    function setUp() public {
        owner = makeAddr("owner");
        vm.deal(owner, 10 ether);
        user1 = makeAddr("user1");
        vm.deal(user1, 10 ether);
        user2 = makeAddr("user2");
        vm.deal(user2, 10 ether);

        address WETH = 0xdd13E55209Fd76AfE204dBda4007C227904f0a81;
        address POSITION_MANAGER = 0x655C406eBfA14eE2006250925e54a1DC297b4de5;

        vm.startPrank(owner);
        tokenFactory = new TokenFactory(WETH, POSITION_MANAGER);
        vm.stopPrank();

        vm.startPrank(user1);
        tokenFactory.createToken{value: tokenFactory.i_fee()}("UserToken", "UTK");
        vm.stopPrank();
    }



    ///////////////////////////////////////
    /////     Withdraw Eth Tests     /////
    /////////////////////////////////////
    function testWithdrawEth() public {
        uint256 fee = tokenFactory.i_fee();
        uint256 previousOwnerBalance = owner.balance;

        vm.prank(owner);
        tokenFactory.withdraw();

        uint256 currentOwnerBalance = owner.balance;

        assertEq(currentOwnerBalance, previousOwnerBalance + fee);
    }


    function testWithdrawResetsOwnerWithdrawalFees() public {
        uint256 fee = tokenFactory.i_fee();
        uint256 previousWithdrawalFees = tokenFactory.s_ownerFees();

        vm.prank(owner);
        tokenFactory.withdraw();

        uint256 currentWithdrawalFees = tokenFactory.s_ownerFees();

        assertEq(currentWithdrawalFees, previousWithdrawalFees - fee);
    }


    function testMultipleFeeWithdrawal() public {
        uint256 fee = tokenFactory.i_fee();
        uint256 previousOwnerBalance = owner.balance;

        vm.startPrank(user2);
        tokenFactory.createToken{value: tokenFactory.i_fee()}("User2Token", "UTT");
        vm.stopPrank();

        vm.prank(owner);
        tokenFactory.withdraw();

        uint256 currentOwnerBalance = owner.balance;

        assertEq(currentOwnerBalance, previousOwnerBalance + (fee + fee));
    }


    function testMultipleWithdrawals() public {
        uint256 fee = tokenFactory.i_fee();
        uint256 previousOwnerBalance = owner.balance;

        vm.prank(owner);
        tokenFactory.withdraw();

        vm.startPrank(user2);
        tokenFactory.createToken{value: tokenFactory.i_fee()}("User2Token", "UTT");
        vm.stopPrank();

        vm.prank(owner);
        tokenFactory.withdraw();

        uint256 currentOwnerBalance = owner.balance;

        assertEq(currentOwnerBalance, previousOwnerBalance + (fee + fee));
    }


    function testRevertIfNonOwnersWithdraws() public {
        vm.prank(user1);
        vm.expectRevert("Must Be Owner");
        tokenFactory.withdraw();
    }


    function testRevertIfThereAreNoFeesToWithdraw() public {
        vm.prank(owner);
        tokenFactory.withdraw();

        vm.prank(owner);
        vm.expectRevert("There are no Fees to withdraw");
        tokenFactory.withdraw();
    }
}