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
        account = 0x7F281C80D1C00db36D3c555BB3175c78aB04FBd9;
    }

    function run() external {
        vm.startBroadcast();

        RewardsUpgradeable rewardsContract = RewardsUpgradeable(rewards);
        rewardsContract.grantRole(role, account);

        vm.stopBroadcast();
    }
}
