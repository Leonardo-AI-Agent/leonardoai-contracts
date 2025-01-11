// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {Test} from "forge-std/Test.sol";

contract Staking is Test, Script {
    address public immutable alice = vm.addr(1);
    address public immutable bob = vm.addr(2);

    function setUp() public {}

    function testStaking() public {
        vm.startPrank(alice);

        vm.stopPrank();
    }
}
