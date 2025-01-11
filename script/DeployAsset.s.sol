// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Utils} from "./Utils.s.sol";

import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";

contract LEONAI is ERC20 {
    constructor() ERC20("LEONARDO by Virtuals", "LEONAI") {
        _mint(msg.sender, 1_000_000_000 * 10 ** 18);
    }
}

contract DeployAsset is Utils {
    address public asset;

    function setUp() public {}

    function run() external {
        vm.startBroadcast();

        asset = address(new LEONAI());

        writeAddressToConfigJson(".asset", asset);

        vm.stopBroadcast();
    }
}
