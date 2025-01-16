// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Utils} from "./Utils.s.sol";

import {StakingUpgradeable} from "../src/StakingUpgradeable.sol";

contract RevokeRoleStaking is Utils {
    address public staking;
    bytes32 public role;
    address public account;

    function setUp() public {
        staking = getAddressFromConfigJson(".staking");
        role = bytes32(0);
        account = 0xdde1Ee9Fd2a83E7C5454D68Db4d61c89ec4Cb131;
    }

    function run() external {
        vm.startBroadcast();

        StakingUpgradeable stakingContract = StakingUpgradeable(staking);
        stakingContract.revokeRole(role, account);

        vm.stopBroadcast();
    }
}
