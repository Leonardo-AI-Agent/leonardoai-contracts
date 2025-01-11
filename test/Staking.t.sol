// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {Test} from "forge-std/Test.sol";

import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

contract Staking is Test, Script {
    address public immutable alice = vm.addr(1);
    address public immutable bob = vm.addr(2);

    function setUp() public {}

    function testSetRoleAdmin() public {
        vm.startPrank(alice);

        vm.stopPrank();
    }
}
