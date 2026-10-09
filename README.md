# 🚀 StakingKehed DApp

A full-stack decentralized application (dApp) for staking custom ERC-20 tokens (`KHD`) with dynamic reward calculations, upgradeable smart contracts, and a modern Web3 frontend interface.

---

## 🛠️ Tech Stack

### Smart Contract
* **Framework:** [Foundry](https://getfoundry.sh/) (Solidity)
* **Design Pattern:** UUPS Proxy Pattern (OpenZeppelin Upgradeable)
* **Testing:** Foundry Unit & Fuzz Testing

### Frontend
* **Framework:** [Next.js](https://nextjs.org/) (App Router, Turbopack, TypeScript)
* **Styling:** Tailwind CSS
* **Web3 Integration:** Ethers.js & Viem / Wagmi

---

## ✨ Features

1. **ERC-20 Staking Mechanism:** Users can approve and stake their `KHD` tokens securely.
2. **UUPS Upgradability:** Smart contracts can be upgraded seamlessly without losing user state or balances.
3. **Reward & Fee System:** Dynamic reward calculation with built-in withdrawal fees and automated distribution.
4. **Real-time Dashboard:** Live tracking of Wallet Balance, Total Staked Balance, and Pending Rewards directly from local or testnet blockchain nodes.

---

## ⚙️ Getting Started Locally

### Prerequisites
* [Node.js](https://nodejs.org/) & npm installed
* [Foundry](https://getfoundry.sh/) installed

### 1. Run Local Blockchain (Anvil)
Open a terminal and start a local EVM node:
```bash
anvil
