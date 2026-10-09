//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {StakingKehed} from "../src/StakingKehed.sol";
import {KehedCoin} from "../src/kehed.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployStaking is Script {
    function run() external {
        // 1. Deploy token
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY"); 
        address admin = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        KehedCoin token = new KehedCoin();
        console.log("Token deployed at:", address(token));

        StakingKehed implementation = new StakingKehed();
        console.log("Implementation deployed at:", address(implementation));

        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address)",
            address(token),
            admin
        );

        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation), 
            data
        );
        console.log("Proxy deployed at:", address(proxy));

        vm.stopBroadcast();
    }
} 