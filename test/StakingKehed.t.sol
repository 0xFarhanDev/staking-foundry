//SPDX-license-Identifier: MIT

pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {StakingKehed} from "../src/StakingKehed.sol";
import {KehedCoin} from "../src/kehed.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

contract StakingKehedTest is Test {
    StakingKehed public staking;
    KehedCoin public token;

    address admin = makeAddr("admin");
    address user1 = makeAddr("user1");

    function setUp() public {
        // Deploy token
        token = new KehedCoin();

        // Deploy implementation contract
        StakingKehed implementation = new StakingKehed();

        // Prepare data for initialize function
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address)",
            address(token),
            admin
        );

        // Deploy proxy contract pointing to implementation and call initialize
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            data
        );

        staking = StakingKehed(address(proxy));

        token.transfer(user1, 1000 * 10**18);
    }
    function test_DeploymentSuccess() public view {
        assertEq(address(staking.khdToken()), address(token));
        assertEq(staking.hasRole(staking.DEFAULT_ADMIN_ROLE(), admin), true);
    }
    function test_StakeTokens() public {
        uint256 stakeAmount = 100 * 10**18;

        vm.startPrank(user1);
        token.approve(address(staking), stakeAmount);

        staking.stake(stakeAmount);
        vm.stopPrank();

        assertEq(staking.stakedBalances(user1), stakeAmount);
    }
    function test_UpgradeProxy() public {
        // Deploy new implementation
        StakingKehed newImplementation = new StakingKehed();

        vm.prank(admin);
        UUPSUpgradeable(address(staking)).upgradeToAndCall(address(newImplementation), "");
       
        assertEq(staking.stakedBalances(user1), 0); 

        uint256 stakeAmount = 50 * 10**18;
        vm.startPrank(user1);
        token.approve(address(staking), stakeAmount);
        staking.stake(stakeAmount);
        vm.stopPrank();

        assertEq(staking.stakedBalances(user1), stakeAmount);
    }
    function testFuzz_Stake(uint256 amount) public {
        amount = bound(amount, 1 * 10**18, 500 * 10**18);
        
        token.transfer(user1, amount);

        vm.startPrank(user1);
        token.approve(address(staking), amount);
        staking.stake(amount);
        vm.stopPrank();

        assertEq(staking.stakedBalances(user1), amount);
    }
}