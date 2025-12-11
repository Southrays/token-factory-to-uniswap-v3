// SPDX-License-Identifier: MIT

pragma abicoder v2;
pragma solidity 0.7.6;

contract MockPositionManager {

    bool public poolCreated;
    bool public mintCalled;
    bool public transferredToBurn;

    uint256 public nextTokenId = 1;

    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    function createAndInitializePoolIfNecessary(
        address,
        address,
        uint24,
        uint160
    ) external returns (address) {
        poolCreated = true;
        return address(0xBEEF); // mock pool
    }

    function mint(MintParams calldata)
        external
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        )
    {
        mintCalled = true;
        tokenId = nextTokenId++;
        liquidity = 1e18;
        amount0 = 1e18;
        amount1 = 1e18;
    }

    function safeTransferFrom(address, address to, uint256) external {
        if (to == address(0xdead)) {
            transferredToBurn = true;
        }
    }
}
