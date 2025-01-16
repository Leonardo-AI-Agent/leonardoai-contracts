// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Utils} from "./Utils.s.sol";

import {RewardsUpgradeable} from "../src/RewardsUpgradeable.sol";

contract RevokeRoleRewards is Utils {
    address public rewards;
    bytes32 public role;
    address public account;

    function setUp() public {
        rewards = getAddressFromConfigJson(".rewards");
        role = bytes32(0);
        account = 0xdde1Ee9Fd2a83E7C5454D68Db4d61c89ec4Cb131;
    }

    function run() external {
        vm.startBroadcast();

        RewardsUpgradeable rewardsContract = RewardsUpgradeable(rewards);
        rewardsContract.revokeRole(role, account);

        vm.stopBroadcast();
    }
}
