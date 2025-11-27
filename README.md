# Token Factory

A decentralized token creation and trading platform that allows users to create their own ERC-20 standard tokens on the **Sepolia Ethereum testnet** and trade them until an ETH goal is reached. Once the goal is met, the tokens can be added to a **Uniswap v3 liquidity pool**.

---

## Table of Contents

- [Overview](#overview)  
- [Features](#features)  
- [Architecture](#architecture)  
- [Contracts](#contracts)  
  - [Token Contract](#token-contract)  
  - [Token Factory Contract](#token-factory-contract)  
- [How It Works](#how-it-works)  
- [Deployment](#deployment)  
- [Usage](#usage)  
- [License](#license)  

---

## Overview

Token Factory is a smart contract platform that enables users to:

1. **Create ERC-20 tokens** without writing code.  
2. **Buy and sell tokens** in a marketplace until a target ETH goal is reached.  
3. **Automatically provide liquidity** on Uniswap v3 once the ETH goal is met.  

It’s designed for testnet experimentation, education, and rapid token prototyping.

---

## Features

- **ERC-20 token creation**: Users can define token name, symbol, and initial supply.  
- **Token marketplace**: Other users can buy/sell tokens, contributing ETH toward a target.  
- **ETH goal tracking**: Once a token reaches the required ETH, trading closes.  
- **Uniswap v3 liquidity integration**: Remaining tokens and raised ETH are deposited into a liquidity pool.  
- **Fee-based deployment**: Token creators pay a small fee for token deployment.  

---

## Architecture

The platform consists of two primary contracts:

1. **Token Contract**: Implements the ERC-20 standard for custom tokens.  
2. **Token Factory Contract**: Handles token creation, buying, selling, and liquidity provisioning.  

Additional integrations:  

- **Uniswap v3**: For liquidity pool creation.  
- **WETH (Wrapped ETH)**: Used to deposit ETH into Uniswap pools.  

---

## Contracts

### Token Contract

The `Token` contract is a boilerplate ERC-20 token that allows users to:  

- Transfer tokens (`transfer` / `transferFrom`)  
- Approve other users to spend tokens (`approve`)  
- View balances and allowances (`balanceOf`, `allowance`)  

**Key Points:**

- All initial tokens are minted to the creator.  
- A small portion can be sent to the deployer as a fee.  
- Implements minting and burning events for transparency.  

---

### Token Factory Contract

The `TokenFactory` contract manages token creation, trading, and liquidity:  

- **Token Creation**: Users pay a deployment fee and deploy a new ERC-20 token.  
- **Buying Tokens**: Users pay ETH to purchase tokens until the ETH goal is reached.  
- **Selling Tokens**: Users can sell tokens back for ETH if the goal has not been reached.  
- **Liquidity Provisioning**: Once the ETH goal is reached:  
  - Remaining tokens + raised ETH are wrapped in WETH  
  - A Uniswap v3 pool is created and initialized  
  - The liquidity NFT is sent to a burn address to lock it  

**Important Constants:**

- `TOTAL_SUPPLY`: 100,000 tokens per new token  
- `REQUIRED_ETH`: 10 ETH required for liquidity creation  
- `POOL_FEE`: 0.3% Uniswap fee tier  

---

## How It Works

1. **Create a Token**  
   - Call `createToken(name, symbol)` with the deployment fee.  
   - Token is deployed and added to the pool of available tokens.  

2. **Buy Tokens**  
   - Call `buyTokens(tokenAddress, amount)` and pay ETH based on the current price.  
   - Price increases as more tokens are sold.  
   - Tokens are transferred to the buyer.  

3. **Sell Tokens**  
   - Call `sellTokens(tokenAddress, amount)` to redeem ETH for tokens if the sale is still open.  

4. **Liquidity Creation**  
   - Automatically triggered when a token reaches the `REQUIRED_ETH` goal.  
   - Remaining tokens and raised ETH are added to a Uniswap v3 pool.  
   - Pool NFT is locked to prevent withdrawal.  

---

## Deployment

The project is designed for **Sepolia Ethereum testnet**:

1. Compile contracts using **Solidity 0.7.6**.  
2. Deploy `TokenFactory` first.  
3. Use the factory to create new tokens.  

**Dependencies:**

- OpenZeppelin Contracts (IERC20, IERC721, SafeMath)  
- Uniswap v3 Core & Periphery libraries  

---

## Usage

1. **Connect a wallet** (e.g., MetaMask) to Sepolia testnet.  
2. **Deploy TokenFactory** and note its address.  
3. **Create a token**: `createToken("MyToken", "MTK")`.  
4. **Buy tokens** using `buyTokens(tokenAddress, amount)`.  
5. **Monitor ETH raised**; once `REQUIRED_ETH` is reached, liquidity is automatically added.  
6. **Sell tokens** (before ETH goal is reached) using `sellTokens(tokenAddress, amount)`.  

---

## License

This project is licensed under the **MIT License**.  

---

**Author:** Southrays   
**Ethereum Testnet:** Sepolia 