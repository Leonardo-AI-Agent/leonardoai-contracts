// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {AccessControlUpgradeable} from "openzeppelin-contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {SignatureChecker} from "openzeppelin-contracts/utils/cryptography/SignatureChecker.sol";
import {EIP712Upgradeable} from "openzeppelin-contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";

import {StakingUpgradeable} from "./StakingUpgradeable.sol";

contract RewardsUpgradeable is EIP712Upgradeable, AccessControlUpgradeable, UUPSUpgradeable {
    event Initialized(address indexed staking, string name, string version);
    event Claimed(
        address indexed staking, address indexed asset, address indexed account, address vault, uint256 amount
    );

    error NothingToClaim();

    StakingUpgradeable public staking;
    mapping(address => uint256) public claimed;
    bytes32 public constant SIGNER_ROLE = keccak256("SIGNER_ROLE");

    // solhint-disable-next-line
    bytes32 private constant _RewardsTypehash =
        keccak256("Rewards(address asset,address vault,address account,uint256 amount)");

    constructor() {
        _disableInitializers();
    }

    function initialize(StakingUpgradeable staking_, string memory name_, string memory version_) public initializer {
        __EIP712_init(name_, version_);
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

        staking = staking_;

        emit Initialized(address(staking_), name_, version_);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}

    function _authorizeSigner(address signer_) internal view {
        _checkRole(SIGNER_ROLE, signer_);
    }

    function available(
        address asset_,
        address vault_,
        address account_,
        uint256 amount_,
        address signer_,
        bytes calldata signature_
    ) public view returns (uint256) {
        bytes32 structHash = keccak256(abi.encode(_RewardsTypehash, asset_, vault_, account_, amount_));
        bytes32 hash = _hashTypedDataV4(structHash);
        bool validation = SignatureChecker.isValidSignatureNow(signer_, hash, signature_);

        if (!validation) {
            return 0;
        }

        return amount_ - claimed[account_];
    }

    function claim(
        address asset_,
        address vault_,
        address account_,
        uint256 amount_,
        address signer_,
        bytes calldata signature_
    ) public {
        _authorizeSigner(signer_);

        uint256 available_ = available(asset_, vault_, account_, amount_, signer_, signature_);

        if (available_ == 0) {
            revert NothingToClaim();
        }

        claimed[account_] += available_;

        if (vault_ != address(this)) {
            IERC20(asset_).transferFrom(vault_, address(this), available_);
        }
        IERC20(asset_).approve(address(staking), available_);
        staking.deposit(available_, account_);

        emit Claimed(address(staking), asset_, account_, vault_, available_);
    }
}
