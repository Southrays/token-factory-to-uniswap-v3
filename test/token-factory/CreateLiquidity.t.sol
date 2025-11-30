//SPDX-License-Identifier: MIT

pragma abicoder v2;
pragma solidity 0.7.6;

import {Test} from "../../lib/forge-std/src/Test.sol";
import {TokenFactory} from "../../src/TokenFactory.sol";
import {MockWETH9} from "../mocks/MockWETH9.sol";
import {MockPositionManager} from "../mocks/MockPositionManager.sol";

contract CreateLiquidityTest is Test {
    //////////////////////////////
    /////     Variables     /////
    ////////////////////////////
    TokenFactory public tokenFactory;
    uint256 public constant TOTAL_SUPPLY = 100000e18;
    address owner;
    address user1;
    address user2;
    address user3;
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
        vm.deal(user2, 50 ether);
        user3 = makeAddr("user3");
        vm.deal(user3, 50 ether);

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



    ///////////////////////////////////////////
    /////     Create Liquidity Tests     /////
    /////////////////////////////////////////
    function testCreateLiquidity() public {
        vm.prank(user2);
        tokenFactory.buyTokens{value: 10 ether}(newToken);
        
        assertGt(mockWETH9.balanceOf(address(tokenFactory)), 0, "No WETH deposited");
        assertTrue(mockPositionManager.poolCreated(), "Pool was not created");
        assertTrue(mockPositionManager.mintCalled(), "Mint not called");
        assertTrue(mockPositionManager.transferredToBurn(), "NFT not burned");
    }
}