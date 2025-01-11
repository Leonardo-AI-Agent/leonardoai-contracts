// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Utils} from "./Utils.s.sol";

import {Staking} from "../src/Staking.sol";

contract DeployStaking is Utils {
    address public asset;
    address public staking;

    function setUp() public {
        asset = getAddressFromConfigJson(".asset");
    }

    function run() external {
        vm.startBroadcast();

        staking = address(new Staking(asset, "Staked LEONARDO by Virtuals", "sLEONAI"));

        writeAddressToConfigJson(".staking", staking);

        vm.stopBroadcast();
    }
}
