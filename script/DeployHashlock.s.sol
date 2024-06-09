// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { Script } from "forge-std/Script.sol";
import { Hashlock } from "../src/Hashlock.sol";
import { console2 } from "forge-std/console2.sol";

contract DeployHashlock is Script {
    function run() external {
        vm.startBroadcast();
        Hashlock hashlock = new Hashlock(); // deployer is the citrea address
        vm.stopBroadcast();
        console2.log("Hashlock contract deployed at:", address(hashlock));
    }
}
