//SPDX-License-Identifier: MIT

pragma abicoder v2;
pragma solidity 0.7.6;

import {Test} from "../../lib/forge-std/src/Test.sol";
import {Token} from "../../src/Token.sol";

contract TokenConstructorTests is Test {
    //////////////////////////////////
    /////      Variables       //////
    ////////////////////////////////
    Token public token;
    address owner;

    uint256 public constant TOTAL_SUPPLY = 100000e18;
    uint256 public constant DECIMALS = 18;



    // ///////////////////////////////
    // /////      Set Up       //////
    // /////////////////////////////
    function setUp() public {
        owner = makeAddr("owner");
        vm.deal(owner, 10 ether);

        vm.prank(owner);
        token = new Token("Token", "TKN", TOTAL_SUPPLY);
    }

    // /////////////////////////////////////////
    // /////      Constructor Test       //////
    // ///////////////////////////////////////
    function testInitialSetUp() public view {
        assertEq(token.name(), "Token");
        assertEq(token.symbol(), "TKN");
        assertEq(token.totalSupply(), TOTAL_SUPPLY);
        assertEq(token.decimals(), DECIMALS);
        assertEq(token.balanceOf(owner), TOTAL_SUPPLY);
    }
}