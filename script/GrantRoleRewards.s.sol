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
        role = keccak256("SIGNER_ROLE");
        account = 0x0856D141C3C400a7922E0ece4fC9b458bf1b07FC;
    }

    function run() external {
        vm.startBroadcast();

        RewardsUpgradeable rewardsContract = RewardsUpgradeable(rewards);
        rewardsContract.grantRole(role, account);

        vm.stopBroadcast();
    }
}
