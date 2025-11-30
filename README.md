# **Token Factory – ERC-20 Launchpad with Automated Uniswap V3 Liquidity Deployment**

### 🚀 **Live on Sepolia Testnet**  
**TokenFactory Contract Address:** `0x09bc11FC327012D76E856E5Ce9a2080E6024F16F`

---

## 📌 **Overview**

**Token Factory** is an Ethereum-based smart contract protocol that allows **any user to deploy their own ERC-20 token**, participate in a **fair token launch**, and automatically create **deep Uniswap V3 liquidity** once a required ETH goal is reached.

Each created token:

- Has a **fixed total supply (100,000 tokens)**  
- Is deployed using a minimal ERC-20 implementation  
- Can be **bought or sold** during its sale phase  
- Experiences **price increments every 5,000 tokens**  
- Automatically creates **Uniswap V3 liquidity** once it reaches **10 ETH raised**  
- Burns unused supply to stabilize price after liquidity creation  
- Locks all liquidity permanently (LP NFT sent to a burn address)  

This creates a **fair, trustless launchpad** for ERC-20 tokens where liquidity cannot be rugged.

---

## ✨ **Features**

### 🧱 **1. Create ERC-20 Tokens**
Users can deploy a new ERC-20 token by providing:
- Token name  
- Token symbol  
- A small deployment fee (`0.001 ETH`)

Each deployed token receives:
- Total supply = `100,000 * 10^18`  
- Ownership assigned to the TokenFactory  
- Automatic tracking in the factory contract  

---

### 💸 **2. Buy & Sell Tokens**
Users can:
- Purchase tokens using ETH  
- Sell tokens back to the factory  
- All pricing is dynamic using:

> **Price increases every 5,000 tokens sold**  
> ensuring an organic bonding curve-like price rise.

---

### 🧮 **3. ETH Goal → Auto Liquidity**
Once a token reaches **10 ETH**, the contract:

1. **Closes token sale**
2. Calculates:
   - tokens required for LP  
   - tokens to burn  
3. Burns excess supply  
4. Converts ETH → WETH  
5. Creates a **Uniswap V3 pool**  
6. Provides **full-range liquidity**  
7. Sends the **LP NFT to the burn address**  
   (liquidity becomes locked forever)

This ensures:
- No possibility of rug pulls  
- Liquidity is deep and stable  
- Price impact stays healthy  

---

### 🔥 **4. Token Burn Mechanism**

The factory burns leftover tokens not added to LP, ensuring:
- A reasonable post-launch market price  
- Prevention of extreme pumps  
- Sustainable tokenomics  
- Maximum 5x launch price vs bonding curve price  

---

### 🧰 **5. Owner Fee Withdrawal**
The factory owner can withdraw only the collected deployment fees.  
All ETH used to buy tokens or provide liquidity is **locked to the token**, not withdrawable by the owner.

---

## 🧩 **Contract Architecture**

### 📍 **1. Token.sol**
A lightweight ERC-20 token:
- Custom minting in constructor  
- Transfer, transferFrom, approval  
- Burn function (factory-only)  
- Total supply tracking  
- Full event emission (Transfer, Approval, Burn, Mint)

### 📍 **2. TokenFactory.sol**
Handles:
- Token creation  
- Price calculation  
- Buy/sell logic  
- ETH goal tracking  
- Liquidity deployment  
- Uniswap V3 integrations  
- LP NFT burn  
- Fees + withdrawals  
- Token registry and metadata (`TokenData` struct)

### 📍 **External Integrations**
- **Uniswap V3 Position Manager**
- **WETH9**
- **OpenZeppelin ERC-20 / ERC-721 interfaces**
- **SafeMath**
- **FullMath (Uniswap)**

---

## 🧠 **How Liquidity Creation Works**

When a token reaches **10 ETH raised**:

1. Compute current token price  
2. Compute required liquidity depth  
3. Burn excess tokens  
4. Convert ETH → WETH  
5. Compute **sqrtPriceX96** for pool initialization  
6. Create pool (if needed)  
7. Mint **full-range UniV3 position**  
8. Send LP NFT → dead address  
9. Reset internal ETH accounting

This creates:
- Fully locked LP  
- Permanent liquidity  
- Trustless market foundation  

---

## 📊 **Token Data Structure**

Each deployed token has:

```solidity
struct TokenData {
    address token;
    string name;
    string symbol;
    address creator;
    uint256 tokensSold;
    uint256 ethRaised;
    bool isSaleOpen;
}
