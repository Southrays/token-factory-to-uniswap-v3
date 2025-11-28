// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

contract MockPositionManager {
    //////////////////////////////
    /////     Variables     /////
    ////////////////////////////
    bool public poolCreatedCalled;
    bool public mintCalledFlag;
    bool public transferredToBurnFlag;

    uint256 public nextTokenId = 1;



    ///////////////////////////
    /////     Events     /////
    /////////////////////////
    event PoolCreated(address token0, address token1);
    event MintCalled(uint256 tokenId);
    event NFTTransferred(address from, address to, uint256 tokenId);



    ///////////////////////////////////////
    /////     External Functions     /////
    /////////////////////////////////////
    /**
     * CreateAndInitializePoolIfNecessary
     */
    function createAndInitializePoolIfNecessary(
        address token0,
        address token1,
        uint24,
        uint160
    ) external returns (address pool) {
        poolCreatedCalled = true;
        emit PoolCreated(token0, token1);

        // Return a fake pool address
        return address(uint160(uint256(keccak256("MOCK_POOL"))));
    }


    
    /**
     * Mint
     */
    function mint(
        /* INonfungiblePositionManager.MintParams calldata params */
        bytes calldata
    )
        external
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        )
    {
        mintCalledFlag = true;

        tokenId = nextTokenId;
        nextTokenId++;

        liquidity = 1e18;
        amount0 = 1e9;
        amount1 = 1e9;

        emit MintCalled(tokenId);
    }


    /**
     * SafeTransferFrom (ERC721 mock)
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external {
        transferredToBurnFlag = true;
        emit NFTTransferred(from, to, tokenId);
    }



    //////////////////////////////////////////
    /////     Pure & View Functions     /////
    ////////////////////////////////////////
    /**
     * Helper getters for tests
     */
    function poolCreated() external view returns (bool) {
        return poolCreatedCalled;
    }

    function mintCalled() external view returns (bool) {
        return mintCalledFlag;
    }

    function transferredToBurn() external view returns (bool) {
        return transferredToBurnFlag;
    }
}
