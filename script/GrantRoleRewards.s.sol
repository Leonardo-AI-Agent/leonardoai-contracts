// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Utils} from "./Utils.s.sol";

import {RewardsUpgradeable} from "../src/RewardsUpgradeable.sol";

contract GrantRoleRewards is Utils {
    address public rewards;
    bytes32 public role;
    address public account;

    function setUp() public {
        rewards = getAddressFromConfigJson(".rewards");
        // role = bytes32(0);
        role = keccak256("SIGNER_ROLE");
        account = 0x0DB4bcD6ce5fABf443B37d1A1BF3dbB71EF19613;
    }

    function run() external {
        vm.startBroadcast();

        RewardsUpgradeable rewardsContract = RewardsUpgradeable(rewards);
        rewardsContract.grantRole(role, account);

        vm.stopBroadcast();
    }
}
