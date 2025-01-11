// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {ERC4626} from "openzeppelin-contracts/token/ERC20/extensions/ERC4626.sol";

contract Staking is ERC4626 {
    constructor(address asset, string memory name, string memory symbol) ERC4626(asset) ERC20(name, symbol) {}
}
