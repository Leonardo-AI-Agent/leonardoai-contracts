// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Utils} from "./Utils.s.sol";

import {StakingUpgradeable} from "../src/StakingUpgradeable.sol";

contract DeployStaking is Utils {
    address public asset;
    address public staking;

    function setUp() public {
        asset = getAddressFromConfigJson(".asset");
    }

    function run() external {
        vm.startBroadcast();

        uint256 cooldownTime = 1 days;
        address implementation = address(new StakingUpgradeable());
        bytes memory data = abi.encodeWithSelector(
            StakingUpgradeable.initialize.selector, asset, "Staked LEONARDO by Virtuals", "sLEONAI", cooldownTime
        );

        staking = _createProxy(implementation, data);

        writeAddressToConfigJson(".staking", staking);
        writeAddressToConfigJson(".implementations.staking", implementation);

        vm.stopBroadcast();
    }
}
