// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {
    ERC4626Upgradeable,
    ERC20Upgradeable,
    IERC20
} from "openzeppelin-contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol";
import {AccessControlUpgradeable} from "openzeppelin-contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Math} from "openzeppelin-contracts/utils/math/Math.sol";

contract StakingUpgradeable is ERC4626Upgradeable, AccessControlUpgradeable, UUPSUpgradeable {
    // Event emitted when a user initiates a cooldown period for withdrawing shares
    event StakingCoolingDown(address indexed owner, uint256 shares, uint256 releaseTime);
    event StakingNewCooldownTime(uint256 cooldownTime);

    // Storage structure for managing cooldown periods and associated data
    struct StakingStorage {
        uint256 cooldownTime; // Duration of the cooldown period
        mapping(address => uint256) coolingdown; // Tracks shares in cooldown per address
        mapping(address => uint256) releaseTime; // Tracks the release time for each address
    }

    // Storage location identifier for staking data
    // This value is derived from keccak256("leonardoai.storage.staking")
    bytes32 private constant StakingStorageLocation = 0x3957d709c956e88416d49496a75429b0ef7b7368365cf6b77684c88715513cfd;

    // Retrieve the staking storage using the predefined location
    function _getStakingStorage() private pure returns (StakingStorage storage $) {
        assembly {
            $.slot := StakingStorageLocation
        }
    }

    // Constructor disables initializers to prevent misuse
    constructor() {
        _disableInitializers();
    }

    // Initializes the contract with the specified asset, name, and symbol
    function initialize(address asset, string memory name, string memory symbol, uint256 cooldownTime_)
        public
        initializer
    {
        __ERC4626_init(IERC20(asset));
        __ERC20_init(name, symbol);
        __AccessControl_init();
        __UUPSUpgradeable_init();

        // Grant admin role to the deployer
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setCooldownTime(cooldownTime_);
    }

    // Ensures only admin can authorize contract upgrades
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}

    // Sets the cooldown time for withdrawals, only callable by admin
    function setCooldown(uint256 cooldownTime_) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setCooldownTime(cooldownTime_);
    }

    function _setCooldownTime(uint256 cooldownTime_) private {
        _getStakingStorage().cooldownTime = cooldownTime_;
        emit StakingNewCooldownTime(cooldownTime_);
    }

    // Allows a user to request a withdrawal, checks max allowed assets
    function requestWithdraw(uint256 assets) public {
        address owner = _msgSender();
        uint256 shares = previewWithdraw(assets);
        _setRequest(owner, shares);
    }

    // Allows a user to request a redemption, checks max allowed shares
    function requestRedeem(uint256 shares) public {
        address owner = _msgSender();
        _setRequest(owner, shares);
    }

    // Sets the cooldown request for a user with the specified shares (Resets cooldown)
    function _setRequest(address owner, uint256 shares) private {
        StakingStorage storage s = _getStakingStorage();
        uint256 releaseTime_ = block.timestamp + s.cooldownTime;
        uint256 balance = balanceOf(owner);

        if (shares > balance) {
            revert ERC20InsufficientBalance(owner, balance, shares);
        }

        s.coolingdown[owner] = shares;
        s.releaseTime[owner] = releaseTime_;

        // Emit event to notify of the cooldown initiation
        emit StakingCoolingDown(owner, shares, releaseTime_);
    }

    // Handles asset withdrawal after checking max limits
    function withdraw(uint256 assets, address receiver, address owner) public override returns (uint256) {
        uint256 shares = previewWithdraw(assets);
        _withdraw(_msgSender(), receiver, owner, assets, shares);
        return shares;
    }

    // Handles share redemption after checking max limits
    function redeem(uint256 shares, address receiver, address owner) public override returns (uint256) {
        uint256 assets = previewRedeem(shares);
        _withdraw(_msgSender(), receiver, owner, assets, shares);
        return assets;
    }

    // Calculates the maximum assets a user can withdraw based on cooldown
    function maxWithdraw(address owner) public view override returns (uint256) {
        if (block.timestamp < _getStakingStorage().releaseTime[owner]) {
            return 0;
        }
        return _convertToAssets(_getStakingStorage().coolingdown[owner], Math.Rounding.Floor);
    }

    // Calculates the maximum shares a user can redeem based on cooldown
    function maxRedeem(address owner) public view override returns (uint256) {
        if (block.timestamp < _getStakingStorage().releaseTime[owner]) {
            return 0;
        }
        return _getStakingStorage().coolingdown[owner];
    }

    // Calculates the maximum assets a user can request to withdraw
    function maxRequestWithdraw(address owner) public view returns (uint256) {
        return _convertToAssets(balanceOf(owner), Math.Rounding.Floor);
    }

    // Calculates the maximum shares a user can request to redeem
    function maxRequestRedeem(address owner) public view returns (uint256) {
        return balanceOf(owner);
    }

    function coolingDown(address owner) public view returns (uint256) {
        return _getStakingStorage().coolingdown[owner];
    }

    function releaseTime(address owner) public view returns (uint256) {
        return _getStakingStorage().releaseTime[owner];
    }

    function cooldownTime() public view returns (uint256) {
        return _getStakingStorage().cooldownTime;
    }

    function _update(address from, address to, uint256 value) internal override {
        if (from != address(0)) {
            // If the transfer is from an address
            StakingStorage storage s = _getStakingStorage();

            if (to != address(0)) {
                // If the transfer is to an address, user can only transfer the staked funds (not in cooldown)
                uint256 fromBalance = balanceOf(from);
                if (value > fromBalance - s.coolingdown[from]) {
                    revert ERC20InsufficientBalance(from, fromBalance - s.coolingdown[from], value);
                }
            } else {
                // If the transfer is to the zero address (redeem/withdraw)
                uint256 available = s.releaseTime[from] < block.timestamp ? s.coolingdown[from] : 0;
                if (value > available) {
                    revert ERC20InsufficientBalance(from, available, value);
                }
                s.coolingdown[from] -= value;
            }
        }
        super._update(from, to, value);
    }
}
