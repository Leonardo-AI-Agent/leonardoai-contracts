// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Utils} from "./Utils.s.sol";

import {StakingUpgradeable} from "../src/StakingUpgradeable.sol";

contract GrantRoleStaking is Utils {
    address public staking;
    bytes32 public role;
    address public account;

    function setUp() public {
        staking = getAddressFromConfigJson(".staking");
        role = bytes32(0);
        account = 0x70f754aFEaA9E15081BFE622734e1935141e8223;
    }

    function run() external {
        vm.startBroadcast();

        StakingUpgradeable stakingContract = StakingUpgradeable(staking);
        stakingContract.grantRole(role, account);

        vm.stopBroadcast();
    }
}
