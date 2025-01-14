// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Utils} from "./Utils.s.sol";

import {RewardsUpgradeable} from "../src/RewardsUpgradeable.sol";

contract UpgradeRewards is Utils {
    address public rewards;

    function setUp() public {
        rewards = getAddressFromConfigJson(".rewards");
    }

    function run() external {
        vm.startBroadcast();

        address implementation = address(new RewardsUpgradeable());

        RewardsUpgradeable(rewards).upgradeToAndCall(implementation, "");

        vm.stopBroadcast();
    }
}
