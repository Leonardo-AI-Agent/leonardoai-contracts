// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Utils} from "./Utils.s.sol";

import {StakingUpgradeable} from "../src/StakingUpgradeable.sol";

contract UpgradeStaking is Utils {
    address public staking;

    function setUp() public {
        staking = getAddressFromConfigJson(".staking");
    }

    function run() external {
        vm.startBroadcast();

        address implementation = address(new StakingUpgradeable());

        StakingUpgradeable(staking).upgradeToAndCall(implementation, "");

        writeAddressToConfigJson(".implementations.staking", implementation);

        vm.stopBroadcast();
    }
}
