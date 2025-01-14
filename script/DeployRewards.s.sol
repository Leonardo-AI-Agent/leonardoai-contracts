// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Utils} from "./Utils.s.sol";

import {RewardsUpgradeable} from "../src/RewardsUpgradeable.sol";

contract DeployRewards is Utils {
    address public staking;
    address public rewards;

    function setUp() public {
        staking = getAddressFromConfigJson(".staking");
    }

    function run() external {
        vm.startBroadcast();

        address implementation = address(new RewardsUpgradeable());
        bytes memory data = abi.encodeWithSelector(RewardsUpgradeable.initialize.selector, staking, "Rewards", "1");

        rewards = _createProxy(implementation, data);

        writeAddressToConfigJson(".rewards", rewards);
        writeAddressToConfigJson(".implementations.rewards", implementation);

        vm.stopBroadcast();
    }
}
