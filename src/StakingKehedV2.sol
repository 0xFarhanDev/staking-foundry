// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./StakingKehed.sol";

contract StakingKehedV2 is StakingKehed {
    constructor() {
        _disableInitializers();
    }
    uint256 public constant APY_PERCENT = 15;

    function calculateRewards(address account) public view override returns (uint256) {
        uint256 timeElapsed = block.timestamp - lastClaimTimestamp[account];
        uint256 stakedAmount = stakedBalances[account];

        if (stakedAmount == 0 || timeElapsed == 0) return 0;
        return (stakedAmount * APY_PERCENT * timeElapsed) / (100 * 365 days);
    }

    function getVersion() external pure returns (string memory) {
        return "v2.0.0";
    }
}
