//SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import {Script} from "../lib/forge-std/src/Script.sol";
import {console} from "../lib/forge-std/src/console.sol";
import {TokenFactory} from "../src/TokenFactory.sol";

contract DeployTokenFactory is Script {
    function run() external {
        address WETH = 0xdd13E55209Fd76AfE204dBda4007C227904f0a81;
        address POSITION_MANAGER = 0x655C406eBfA14eE2006250925e54a1DC297b4de5;
        
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        TokenFactory tokenFactory = new TokenFactory(WETH, POSITION_MANAGER);
        vm.stopBroadcast();

        console.log("Contract address: ", address(tokenFactory));
    }
}