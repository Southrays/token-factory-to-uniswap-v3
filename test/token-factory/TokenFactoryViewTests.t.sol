//SPDX-License-Identifier: MIT

pragma abicoder v2;
pragma solidity 0.7.6;

import {Test} from "../../lib/forge-std/src/Test.sol";
import {Token} from "../../src/Token.sol";
import {TokenFactory} from "../../src/TokenFactory.sol";
import {MockWETH9} from "../mocks/MockWETH9.sol";
import {MockPositionManager} from "../mocks/MockPositionManager.sol";


contract TokenFactoryViewTest is Test {
    //////////////////////////////
    /////     Variables     /////
    ////////////////////////////
    TokenFactory public tokenFactory;
    uint256 public constant AMOUNT = 1 ether;
    uint256 public constant REQUIRED_PURCHASE = 5 ether;
    uint256 constant FLOOR = 0.001 ether;
    uint256 constant STEPPED_UP = 0.002 ether;
    address owner;
    address user1;
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



    /////////////////////////////////////////
    /////     Get Token Data Tests     /////
    ///////////////////////////////////////
    function testGetTokenData() public view {
        TokenFactory.TokenData memory tokenData = tokenFactory.getTokenData(newToken);

        assertEq(user1, tokenData.creator);
        assertEq("UserToken", tokenData.name);
        assertEq("UTK", tokenData.symbol);
        assertEq(address(newToken), tokenData.token);
    }



    //////////////////////////////////////
    /////     Get Cost Tests     /////
    ////////////////////////////////////
    function testGetInitialCost() public view {
        uint256 cost = tokenFactory.getCost(newToken);

        assertEq(cost, FLOOR);
    }


    function testGetCostIncreament() public {
        vm.startPrank(user1);
        tokenFactory.buyTokens{value: REQUIRED_PURCHASE}(newToken);
        vm.stopPrank();
        uint256 cost = tokenFactory.getCost(newToken);

        assertEq(cost, STEPPED_UP);
    }
}