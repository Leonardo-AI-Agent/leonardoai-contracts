// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Utils} from "./Utils.s.sol";

import {StakingUpgradeable} from "../src/StakingUpgradeable.sol";

contract SetCooldownTime is Utils {
    address public staking;

    function setUp() public {
        staking = getAddressFromConfigJson(".staking");
    }

    function run() external {
        vm.startBroadcast();

        StakingUpgradeable(staking).setCooldown(300); // 5 minutes

        vm.stopBroadcast();
    }
}
