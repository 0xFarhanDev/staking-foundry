// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/StakingKehedV2.sol";

interface UUPSProxy {
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}

contract UpgradeStakingScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address proxyAddress = vm.envAddress("PROXY_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        StakingKehedV2 newImplementation = new StakingKehedV2();

        UUPSProxy(proxyAddress).upgradeToAndCall(address(newImplementation), "");

        vm.stopBroadcast();

        console.log("Implementation New V2 Si kehed:", address(newImplementation));
        console.log("Proxy Upgraded Succes bro:", proxyAddress);
    }
}
