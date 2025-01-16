// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Utils} from "./Utils.s.sol";

import {IERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";

contract DecreaseAllowanceOnStaking is Utils {
    address public asset;
    address public staking;

    function setUp() public {
        asset = getAddressFromConfigJson(".asset");
        staking = getAddressFromConfigJson(".staking");
    }

    function run() external {
        vm.startBroadcast();

        IERC20(asset).approve(staking, 0);

        vm.stopBroadcast();
    }
}
