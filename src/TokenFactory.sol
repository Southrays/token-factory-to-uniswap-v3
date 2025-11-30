//SPDX-License-Identifier: MIT

pragma abicoder v2;
pragma solidity 0.7.6;

import {Token} from "./Token.sol";

import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {SafeMath} from "../lib/openzeppelin-contracts/contracts/math/SafeMath.sol";

import {INonfungiblePositionManager} from "../lib/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import {FullMath} from "../lib/v3-core/contracts/libraries/FullMath.sol";
import {IWETH9} from "../lib/v3-periphery/contracts/interfaces/external/IWETH9.sol";



/**
 * This is a Token Factory contract that enables users to create tokens.
 * The user inputs the required details to create the token, and then
 transfers a fee (i_fee) to the deployer (TokenFactory) of the token contract.
 * Only the owner of the TokenFactory contract (s_owner) can withdraw the fees (i_fee).
 * The deployment is done, recorded and the user is then updated as the
 creator of the token.
 * Other users can buy these tokens, and pay Eth, towards an Eth goal (REQUIRED_ETH).
 * There is an increament in the price of a token by 0.001 Eth, after 5000 tokens are bought.
 * When the Eth goal (REQUIRED_ETH) is met, a calculated amount of the particular token and
 and all the Eth raised for that specific token would be added to a Liquidity pool.
 *The Remaining tokens not added to the Liquidity pool would be burnt, this is done to
 regulate the price after it has been added to the liquidity pool. Ensuring the price is not more
 than 5 times higher hen it has been added to the Liquidity pool.
 * Users can also sell their tokens to receive Eth but once an Eth goal (REQUIRED_ETH) is
 met, there is no more buying or selling of that token because the token would have
 already been deployed to the Liquidity pool.
 *
 *
 * All tokens created have a Token Data, which are the basic details of
 the token.
 * All tokens are added to a pool of created tokens (s_tokenData), where
 the data of each token can be accessed by inputing the address of the
 token.
 * Users can create multiple tokens, each token is unique.
 * Users can buy and sell tokens of their choice, from the pool of deployed tokens.
 * @title Token Factory
 * @author Southrays
 * @notice This contract allows users to create ERC-20 standard tokens.
 */
contract TokenFactory {
    using SafeMath for uint256;


    /////////////////////////////////////
    /////     Type Declaration     /////
    ///////////////////////////////////
    struct  TokenData {
        address token;
        string name;
        string symbol;
        address creator;
        uint256 tokensSold;
        uint256 ethRaised;
        bool isSaleOpen; 
    }



    //////////////////////////////
    /////     Variables     /////
    ////////////////////////////
    address public s_owner;
    uint256 public s_ownerFees;
    uint256 public s_totalTokens;
    address[] public s_tokens;
    mapping (address => TokenData) public s_tokenData;

    // Token
    uint256 public constant TOTAL_SUPPLY = 100000e18;
    uint256 public immutable i_fee;
    uint256 public constant REQUIRED_ETH = 10 ether;

    // Uniswap V3
    address public immutable i_wEth;
    INonfungiblePositionManager public immutable i_positionManager;
    uint24 public constant POOL_FEE = 3000;
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;



    ///////////////////////////////
    /////      Events       //////
    /////////////////////////////
    event TokenCreated(
        address indexed creator,
        string indexed tokenName,
        address indexed tokenAddress
    );
    
    event BuyToken(
        address indexed buyer,
        address indexed tokenAddress,
        uint256 indexed amount
    );
    
    event SellToken(
        address indexed seller,
        address indexed tokenAddress,
        uint256 indexed amount
    );
    
    event CreateLiquidity(
        address indexed creator,
        address indexed tokenAddress
    );



    ////////////////////////////////
    /////     Constructor     /////
    //////////////////////////////
    constructor(address _wEth, address _positionManager) {
        s_owner = msg.sender;
        i_fee = 0.001 ether;
        i_wEth = _wEth;
        i_positionManager = INonfungiblePositionManager(_positionManager);
    }


    /////////////////////////////
    /////     Modifier     /////
    ///////////////////////////
    modifier onlyOwner() {
        require (msg.sender == s_owner, "Must Be Owner");
        _;
    }



    ///////////////////////////////////////
    /////     External Functions     /////
    /////////////////////////////////////
    /**
     * This function allows users to create new tokens.
     * The user who wants to create a token is required to input the
     name and symbol of the token being created, then pay a deployment fee.
     * It checks if the user has the deployment fee (i_fee) amount.
     * The deployment fee is then transferred to the contract, then the
     contract pays the fee to the owner (s_owner).
     * If the user has the fee amout and the transaction is successful,
     the new token is then deployed, with the user as the creator of
     the token.
     * Changes are recorded and the total tokens (s_totalTokens) is
     increamented.
     * @param _name This is the name of the new token being created.
     * @param _symbol This is the symbol of the new token being created.
     */
    function createToken( string memory _name, string memory _symbol) external payable returns (address) {
        require(msg.value == i_fee, "Invalid fee amount");
        
        //Create a new token
        Token newToken = new Token(_name, _symbol, TOTAL_SUPPLY);
        s_tokens.push(address(newToken));
        s_totalTokens++;
        emit TokenCreated(msg.sender, _name, address(newToken));

        //Setup the Token Data and add it to the pool of Token Datas
        TokenData memory tokenData = TokenData (
            address(newToken),
            _name,
            _symbol,
            msg.sender,
            0,
            0,
            true
        );

        s_tokenData[address(newToken)] = tokenData;
        s_ownerFees += i_fee;

        return address(newToken);
    }


    /**
     * This function allows user to buy a specific token.
     * It works by the user inputing the address of the token and the Eth
     amount they want to buy.
     * From the token address, it gets the current cost of the token via
     the getCost() function.
     * In order to get the actual price of the amount of tokens the
     user wants to buy, The cost is then multiplied by the amount of tokens
     the user wants to buy.
     * It ensures the user is not sending less eth than the price of the
     tokens they want to buy.
     *It Increaments the amount of token sold and the amount of eth raised of
     the token.
     *Finally, the Buy token event is recorded.
     * @param _token The address of the token the user wants to buy.
     */
    function buyTokens(address _token) external payable returns (uint256) {
        uint256 tokenCost = getCost(_token);
        uint256 tokenAmount = (msg.value * 1e18) / tokenCost;
        uint256 tokenPrice = (tokenCost * tokenAmount) / 1e18;

        TokenData storage tokenData = s_tokenData[_token];
        require(tokenData.isSaleOpen, "Token sale is closed");
        require(tokenData.tokensSold + tokenAmount <= Token(_token).totalSupply(), "Not enough tokens left");
        require(msg.value == tokenPrice, "Insufficient ETH for purchase");

        tokenData.tokensSold = tokenData.tokensSold.add(tokenAmount);
        tokenData.ethRaised = tokenData.ethRaised.add(msg.value);
        Token(_token).transfer(msg.sender, tokenAmount);

        if (tokenData.ethRaised >= REQUIRED_ETH) {
            tokenData.isSaleOpen = false;
            _createLiquidity(_token);
        }
        
        emit BuyToken(msg.sender, _token, tokenAmount);
        return tokenAmount;
    }


    /**
     * This function allows user to sell a specific token.
     * It works by the user inputing the address of the token and the
     amount they want to sell.
     * From the token address, it gets the current cost of the token via
     the getCost() function.
     * In order to get the actual price of the amount of tokens the
     user wants to sell, The cost is then multiplied by the amount of tokens
     the user wants to sell.
     * It ensures the user is not receiving more eth than the price of the
     tokens they want to sell.
     *It reduces the amount of token sold and the amount of eth raised of
     the token.
     *Finally, the Sell token event is recorded.
     * @param _token The address of the token the user wants to buy.
     * @param _amount The amount of tokens the user wants to buy.
     */
    function sellTokens(address _token, uint256 _amount) external returns (uint256){
        TokenData storage tokenData = s_tokenData[_token];

        require(tokenData.isSaleOpen, "Token sale is closed");
        require(Token(_token).balanceOf(msg.sender) >= _amount, "Not enough token balance");

        uint256 tokenCost = getCost(_token);
        uint256 tokenPrice = (tokenCost * _amount) / 1e18;

        require(tokenData.ethRaised >= tokenPrice, "Not enough ETH in pool");

        tokenData.tokensSold = tokenData.tokensSold.sub(_amount);
        tokenData.ethRaised = tokenData.ethRaised.sub(tokenPrice);
        
        require(Token(_token).transferFrom(msg.sender, address(this), _amount), "Token transferFrom failed");
        (bool success, ) = payable(msg.sender).call{value: tokenPrice}("");
        require(success, "ETH transfer failed");

        emit SellToken(msg.sender, _token, _amount);
        return tokenPrice;
    }

    /**
     * This is the function that enables the owner of the Token Factory
     contract to withdraw all the accumulated eth from token creation fees
     */
    function withdraw() external onlyOwner returns (bool){
        require (s_ownerFees > 0, "There are no Fees to withdraw");

        (bool success, ) = payable(s_owner).call{value: s_ownerFees}("");
        if (success) {
            s_ownerFees = 0;
        }
        require (success, "Transaction Unsuccessful");
        return success;
    }



    ///////////////////////////////////////
    /////     Internal Functions     /////
    /////////////////////////////////////
    /// @dev integer sqrt (Babylonian)
    function _createLiquidity(address _token) internal returns (bool) {
        TokenData storage tokenData = s_tokenData[_token];
        uint256 ethRaised = tokenData.ethRaised;
        require(ethRaised >= REQUIRED_ETH, "Not enough ETH raised");

        uint256 totalTokenSupply = Token(_token).totalSupply();
        uint256 tokensSold = tokenData.tokensSold;
        require(totalTokenSupply > tokensSold, "No remaining tokens");

        uint256 remainingTokens = totalTokenSupply.sub(tokensSold);

        // Regulating the desired LP price
        uint256 currentPrice = getCost(_token);
        uint256 requiredTokens = ethRaised * 1e18 / currentPrice;
        uint256 tokensForLP = requiredTokens * 5; // 5× deeper liquidity
        uint256 tokensToBurn = remainingTokens - tokensForLP;

        // Burning the unused tokens
        Token(_token).burn(tokensToBurn);

        // Wrap ETH -> WETH (contract must hold the ETH in balance)
        IWETH9(i_wEth).deposit{value: ethRaised}();

        // Approve the position manager to pull the tokens and WETH
        require(IERC20(_token).approve(address(i_positionManager), tokensForLP), "approve token failed");
        require(IERC20(i_wEth).approve(address(i_positionManager), ethRaised), "approve weth failed");

        // Compute sqrtPriceX96 for pool initialization
        address token0;
        address token1;
        uint160 sqrtPriceX96;

        if (i_wEth < _token) {
            token0 = i_wEth;
            token1 = _token;
            uint256 ratioX192 = FullMath.mulDiv(tokensForLP, (1 << 192), ethRaised);
            sqrtPriceX96 = uint160(_sqrt(ratioX192));
        } else {
            token0 = _token;
            token1 = i_wEth;
            uint256 ratioX192 = FullMath.mulDiv(ethRaised, (1 << 192), tokensForLP);
            sqrtPriceX96 = uint160(_sqrt(ratioX192));
        }

        // Create & initialize pool if necessary
        i_positionManager.createAndInitializePoolIfNecessary(token0, token1, POOL_FEE, sqrtPriceX96);

        // Mint a full-range position (acts like V2)
        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: token0,
            token1: token1,
            fee: POOL_FEE,
            tickLower: -887272,
            tickUpper: 887272,
            amount0Desired: token0 == i_wEth ? ethRaised : tokensForLP,
            amount1Desired: token0 == i_wEth ? tokensForLP : ethRaised,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp
        });

        (uint256 tokenId, , , ) = i_positionManager.mint(params);

        // Transfer the position NFT to burn address (locks liquidity)
        IERC721(address(i_positionManager)).safeTransferFrom(address(this), BURN_ADDRESS, tokenId);

        // Reset ethRaised accounting and return any dust to creator
        tokenData.ethRaised = 0;

        emit CreateLiquidity(tokenData.creator, _token);
        return true;
    }


    function _sqrt(uint256 x) internal pure returns (uint256 z) {
        if (x == 0) return 0;
        uint256 r = (x + 1) >> 1;
        z = x;
        while (r < z) {
            z = r;
            r = (x / r + r) >> 1;
        }
    }



    //////////////////////////////////////////
    /////     Pure & View Functions     /////
    ////////////////////////////////////////
    /**
     * This function returns the data of a particular token
     * Data such as; name, symbol, creator, tokens sold, eth raised and
     if the token is available to be bought.
     * @param _tokenAddress The address of the token.
     */
    function getTokenData(address _tokenAddress) public view returns (TokenData memory) {
        return s_tokenData[_tokenAddress];
    }


    /**
     * This function returns the current cost of 1 unit of a token.
     * @param _tokenAddress The address of the token.
     */
    function getCost(address _tokenAddress) public view returns (uint256) {
        uint256 sold = s_tokenData[_tokenAddress].tokensSold;
        uint256 floor = 0.001 ether;
        uint256 step = 0.001 ether;
        uint256 increment = 5_000 * 1e18;

        uint256 steps = sold.div(increment);
        uint256 cost = floor.add(step.mul(steps));

        return cost;
    }
}