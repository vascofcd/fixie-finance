# Fixie 💹 On-Chain Interest Rate Swap Protocol

**Fixie** is a lightweight DeFi protocol for swapping fixed and floating interest rates between two users. It lets users hedge or speculate on interest rate changes over a defined period, using real-time DeFi rate feeds and automated smart contract settlement powered by **Chainlink**.

🚀 Built for the **Chromion × Chainlink Hackathon 2025 – On-Chain Finance Track**

---

## 🌐 Live Demo

> Coming soon – deployed on [Base Testnet]  
> Frontend: https://fixie-swap.vercel.app  
> Smart Contracts: `/contracts/RateSwap.sol`

---

## 🔍 What It Does

Fixie allows two users to enter a **simple on-chain interest rate swap**:
- One agrees to pay a **fixed interest rate**
- The other pays the **floating rate** from protocols like Aave or Compound
- After a predefined time (e.g. 30 days), the protocol:
  - Uses **Chainlink Price Feeds** to compute the average floating rate
  - Uses **Chainlink Automation** to trigger settlement
  - Transfers funds to the user whose side performed better

---

## 💡 Use Cases

- **DAOs** seeking predictable yield
- **Lenders** who want fixed returns
- **Speculators** who want exposure to DeFi rate movements
- Anyone who wants to **hedge against rate volatility**

---

## 🔗 Chainlink Integrations

| Service                 | Use Case                                      |
|-------------------------|-----------------------------------------------|
| 🟢 Chainlink Price Feeds | Fetch real-time lending rates (e.g., Aave)    |
| 🟢 Chainlink Automation  | Trigger periodic rate recording & settlement  |

✅ **Meets the Chainlink requirement for on-chain state changes.**  
Bonus points earned for using **multiple Chainlink services**.

---

## 🧠 How It Works

### Swap Lifecycle:
1. **Create Swap**: User A proposes a fixed-vs-floating swap
2. **Accept Swap**: User B joins and deposits matching funds
3. **Rate Recording**: Chainlink Automation records floating rate over time
4. **Settlement**: After maturity, contract calculates payouts and distributes funds

---

## 🛠 Tech Stack

- **Smart Contracts**: Solidity (Foundry)
- **Frontend**: React + Ethers.js + Wagmi
- **Chainlink**: Feeds, Automation
- **Network**: Base Testnet

---

## 🤝 Team
Vasco Domingues – Smart contracts, Chainlink integration

