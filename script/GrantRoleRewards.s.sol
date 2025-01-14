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
        account = 0xf6e9DF94B9B0388d71B6Aa35651630D7Ed935349;
    }

    function run() external {
        vm.startBroadcast();

        RewardsUpgradeable rewardsContract = RewardsUpgradeable(rewards);
        rewardsContract.grantRole(role, account);

        vm.stopBroadcast();
    }
}
