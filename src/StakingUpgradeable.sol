// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {
    ERC4626Upgradeable,
    ERC20Upgradeable,
    IERC20
} from "openzeppelin-contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol";
import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract StakingUpgradeable is ERC4626Upgradeable, OwnableUpgradeable, UUPSUpgradeable {
    constructor() {
        _disableInitializers();
    }

    function initialize(address asset, string memory name, string memory symbol) public initializer {
        __ERC4626_init(IERC20(asset));
        __ERC20_init(name, symbol);
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
