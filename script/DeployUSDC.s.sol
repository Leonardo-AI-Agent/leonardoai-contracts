// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Utils} from "./Utils.s.sol";

import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";

contract USDC is ERC20 {
    constructor() ERC20("USDC", "USDC") {
        _mint(msg.sender, 1_000_000_000 * 10 ** 18);
    }
}

contract DeployUSDC is Utils {
    address public asset;

    function setUp() public {}

    function run() external {
        vm.startBroadcast();

        asset = address(new USDC());

        writeAddressToConfigJson(".usdc", asset);

        vm.stopBroadcast();
    }
}
