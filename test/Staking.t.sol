// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {Test} from "forge-std/Test.sol";
import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";
import {StakingUpgradeable} from "src/StakingUpgradeable.sol";
import {Utils} from "../script/Utils.s.sol";

contract Asset is ERC20 {
    constructor() ERC20("Asset", "ASSET") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}

contract Staking is Test, Utils {
    address public immutable alice = vm.addr(1);
    address public immutable bob = vm.addr(2);
    uint256 public cooldownTime = 1 days;

    ERC20 public asset;
    StakingUpgradeable public staking;

    function setUp() public {
        vm.startPrank(alice);
        asset = new Asset();

        address stakingImplementation = address(new StakingUpgradeable());
        bytes memory stakingInitData = abi.encodeWithSelector(
            StakingUpgradeable.initialize.selector, address(asset), "Staking", "STK", cooldownTime
        );

        staking = StakingUpgradeable(_createProxy(stakingImplementation, stakingInitData));
        assertEq(staking.asset(), address(asset));
        assertEq(staking.name(), "Staking");
        assertEq(staking.symbol(), "STK");
        assertEq(staking.cooldownTime(), cooldownTime);

        vm.stopPrank();
    }

    function testDeposit() public {
        vm.startPrank(alice);

        uint256 assets = 1000;
        uint256 shares = staking.convertToShares(assets);

        asset.approve(address(staking), assets);
        staking.deposit(assets, alice);

        assertEq(staking.balanceOf(alice), shares);
        assertEq(staking.maxRequestWithdraw(alice), assets);
        assertEq(staking.maxRequestRedeem(alice), shares);
        assertEq(asset.balanceOf(address(staking)), assets);

        vm.stopPrank();
    }

    function testWithdraw() public {
        vm.startPrank(alice);

        uint256 originalBalance = asset.balanceOf(alice);
        uint256 assets = 1000;
        uint256 shares = staking.convertToShares(assets);

        asset.approve(address(staking), assets);
        staking.deposit(assets, alice);

        assertEq(asset.balanceOf(alice), originalBalance - assets);

        staking.requestWithdraw(assets);

        uint256 expRelease = block.timestamp + cooldownTime;

        assertEq(staking.coolingDown(alice), shares);
        assertEq(staking.releaseTime(alice), expRelease);
        assertEq(staking.maxWithdraw(alice), 0);
        assertEq(staking.maxRedeem(alice), 0);

        vm.expectRevert();
        staking.withdraw(assets, alice, alice);

        vm.warp(expRelease + 1);

        assertEq(staking.maxWithdraw(alice), assets);
        assertEq(staking.maxRedeem(alice), shares);

        staking.withdraw(assets, alice, alice);

        assertEq(staking.balanceOf(alice), 0);
        assertEq(staking.maxRequestWithdraw(alice), 0);
        assertEq(staking.maxRequestRedeem(alice), 0);
        assertEq(asset.balanceOf(alice), originalBalance);

        vm.stopPrank();
    }

    function testWithdrawMoreThanCoolingDown() public {
        vm.startPrank(alice);

        uint256 originalBalance = asset.balanceOf(alice);
        uint256 assets = 1000;

        asset.approve(address(staking), assets);
        staking.deposit(assets, alice);

        assertEq(asset.balanceOf(alice), originalBalance - assets);

        staking.requestWithdraw(assets / 2);

        uint256 expRelease = block.timestamp + cooldownTime;

        vm.warp(expRelease + 1);

        vm.expectRevert();
        staking.withdraw(assets, alice, alice);

        staking.withdraw(assets / 2, alice, alice);

        assertEq(staking.balanceOf(alice), staking.convertToShares(assets / 2));
        assertEq(staking.maxRequestWithdraw(alice), assets / 2);
        assertEq(staking.maxRequestRedeem(alice), staking.convertToShares(assets / 2));
        assertEq(asset.balanceOf(alice), originalBalance - assets / 2);

        vm.stopPrank();
    }

    function testRedeem() public {
        vm.startPrank(alice);

        uint256 originalBalance = asset.balanceOf(alice);
        uint256 assets = 1000;
        uint256 shares = staking.convertToShares(assets);

        asset.approve(address(staking), assets);
        staking.deposit(assets, alice);

        assertEq(staking.balanceOf(alice), shares);

        staking.requestRedeem(shares);

        uint256 expRelease = block.timestamp + cooldownTime;

        assertEq(staking.coolingDown(alice), shares);
        assertEq(staking.releaseTime(alice), expRelease);
        assertEq(staking.maxWithdraw(alice), 0);
        assertEq(staking.maxRedeem(alice), 0);

        vm.expectRevert();
        // Tries transferring the shares before the cooldown ends
        staking.redeem(shares, alice, alice);

        vm.warp(expRelease + 1);

        assertEq(staking.maxWithdraw(alice), assets);
        assertEq(staking.maxRedeem(alice), shares);

        staking.redeem(shares, alice, alice);

        assertEq(staking.balanceOf(alice), 0);
        assertEq(staking.maxRequestWithdraw(alice), 0);
        assertEq(staking.maxRequestRedeem(alice), 0);
        assertEq(asset.balanceOf(alice), originalBalance);

        vm.stopPrank();
    }

    function testRedeemMoreThanCoolingDown() public {
        vm.startPrank(alice);

        uint256 originalBalance = asset.balanceOf(alice);
        uint256 assets = 1000;
        uint256 shares = staking.convertToShares(assets);

        asset.approve(address(staking), assets);
        staking.deposit(assets, alice);

        assertEq(staking.balanceOf(alice), shares);

        staking.requestRedeem(shares / 2);

        uint256 expRelease = block.timestamp + cooldownTime;

        vm.warp(expRelease + 1);

        vm.expectRevert();
        staking.redeem(shares, alice, alice);

        staking.redeem(shares / 2, alice, alice);

        assertEq(staking.balanceOf(alice), staking.convertToShares(assets / 2));
        assertEq(staking.maxRequestWithdraw(alice), assets / 2);
        assertEq(staking.maxRequestRedeem(alice), staking.convertToShares(assets / 2));
        assertEq(asset.balanceOf(alice), originalBalance - assets / 2);

        vm.stopPrank();
    }

    function testTransfers() public {
        vm.startPrank(alice);

        uint256 assets = 1000;
        uint256 shares = staking.convertToShares(assets);

        asset.approve(address(staking), assets);
        staking.deposit(assets, alice);

        assertEq(staking.balanceOf(alice), shares);

        staking.requestRedeem(shares / 2);

        uint256 expRelease = block.timestamp + cooldownTime;

        vm.expectRevert();
        staking.transfer(bob, shares / 2);

        vm.warp(expRelease + 1);

        staking.transfer(bob, shares / 2);

        assertEq(staking.balanceOf(alice), shares / 2);
        assertEq(staking.balanceOf(bob), shares / 2);
        assertEq(staking.maxRedeem(alice), 0);
        assertEq(staking.maxRequestRedeem(alice), shares / 2);

        vm.stopPrank();
    }
}
