//SPDX-License-Identifier: MIT

pragma abicoder v2;
pragma solidity 0.7.6;

import {Test} from "../../lib/forge-std/src/Test.sol";
import {TokenFactory} from "../../src/TokenFactory.sol";
import {Token} from "../../src/Token.sol";

contract CreateTokenTest is Test {
    //////////////////////////////
    /////     Variables     /////
    ////////////////////////////
    // Token public token;
    TokenFactory public tokenFactory;
    uint256 public constant TOTAL_SUPPLY = 100000e18;
    uint256 public constant INVALID_FEE = 0.0001 ether;
    address owner;
    address user1;



    ///////////////////////////
    /////     Set Up     /////
    /////////////////////////
    function setUp() public {
        owner = makeAddr("owner");
        vm.deal(owner, 10 ether);
        user1 = makeAddr("user1");
        vm.deal(user1, 10 ether);

        address WETH = 0xdd13E55209Fd76AfE204dBda4007C227904f0a81;
        address POSITION_MANAGER = 0x655C406eBfA14eE2006250925e54a1DC297b4de5;

        vm.prank(owner);
        tokenFactory = new TokenFactory(WETH, POSITION_MANAGER);
    }



    ///////////////////////////////////////
    /////     Create Token Tests     /////
    /////////////////////////////////////
    function testCreateToken() public {
        vm.startPrank(user1);
        address newToken = tokenFactory.createToken{value: tokenFactory.i_fee()}("UserToken", "UTK");
        vm.stopPrank();
        
        uint256 size;
        assembly {
            size := extcodesize(newToken)
        }

        assertGt(size, 0, "Token was not deployed");
    }


    function testTokenCreatorIsRecorded() public {
        vm.startPrank(user1);
        address newToken = tokenFactory.createToken{value: tokenFactory.i_fee()}("UserToken", "UTK");
        vm.stopPrank();
        
        TokenFactory.TokenData memory tokenData = tokenFactory.getTokenData(newToken);

        assertEq(user1, tokenData.creator);
        assertEq(tokenFactory.s_totalTokens(), 1);
    }


    function testTokenDataIsAccurate() public {
        vm.startPrank(user1);
        address newToken = tokenFactory.createToken{value: tokenFactory.i_fee()}("UserToken", "UTK");
        vm.stopPrank();
        
        TokenFactory.TokenData memory tokenData = tokenFactory.getTokenData(newToken);

        assertEq(user1, tokenData.creator);
        assertEq("UserToken", tokenData.name);
        assertEq("UTK", tokenData.symbol);
        assertEq(address(newToken), tokenData.token);
    }


    function testTokenCreationFeeIsPaid() public {
        uint256 fee = tokenFactory.i_fee();
        uint256 previousCreatorBalance = user1.balance;
        uint256 previousDeployerBalance = address(tokenFactory).balance;

        vm.startPrank(user1);
        tokenFactory.createToken{value: fee}("UserToken", "UTK");
        vm.stopPrank();

        uint256 currentCreatorBalance = user1.balance;
        uint256 currentDeployerBalance = address(tokenFactory).balance;

        assertEq(currentCreatorBalance, previousCreatorBalance - fee);
        assertEq(currentDeployerBalance, previousDeployerBalance + fee);
    }


    function testOwnerFeesUpdateAfterTokenIsCreated() public {
        uint256 fee = tokenFactory.i_fee();
        uint256 previoussOwnerFees = tokenFactory.s_ownerFees();

        vm.startPrank(user1);
        tokenFactory.createToken{value: fee}("UserToken", "UTK");
        vm.stopPrank();

        uint256 currentOwnerFees = tokenFactory.s_ownerFees();

        assertEq(currentOwnerFees, previoussOwnerFees + fee);
    }


    function testTotalSupplyOfTokensAreSentToDeployer() public {
        vm.startPrank(user1);
        address newToken = tokenFactory.createToken{value: tokenFactory.i_fee()}("UserToken", "UTK");
        vm.stopPrank();

        uint256 deployerTokenBalance = Token(newToken).balanceOf(address(tokenFactory));

        assertEq(deployerTokenBalance, TOTAL_SUPPLY);
    }


    function testRevertIfFeeIsNotPaid() public {
        vm.prank(user1);
        vm.expectRevert("Invalid fee amount");
        tokenFactory.createToken{value: INVALID_FEE}("UserToken", "UTK");
    }
}