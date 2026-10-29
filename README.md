# StakingKehed — UUPS staking prototype

An experimental ERC-20 staking dApp built with Solidity and Foundry. The contracts demonstrate an upgradeable proxy, role-based administration, pause controls, staking, reward claims, compounding, and withdrawal fees.

> **Status:** learning/portfolio prototype. It has not been independently audited and is not suitable for production or real funds. Read [Known limitations](#known-limitations) before interacting with it.

## What this repository demonstrates

- UUPS implementation and proxy initialization with OpenZeppelin Upgradeable.
- Role-gated pause, emergency token withdrawal, and upgrade authorization.
- ERC-20 staking and withdrawal flows with a configurable per-user stake cap.
- A Foundry unit/fuzz test suite and GitHub Actions checks for formatting, compilation, and tests.
- A V2 implementation illustrating a storage-preserving upgrade exercise.

## Contract behavior

`StakingKehed` currently caps each user's stake at 5,000 KHD and sets a 1% withdrawal fee. A reward claim is available after 60 seconds and pays a fixed 10% of the current stake; this is **not an annual percentage yield**. `StakingKehedV2` overrides reward calculation with a time-based 15% annual rate, but its upgrade and reward behavior should be treated as an experiment until covered by additional tests and reviewed.

The contracts use Solidity `^0.8.28`. Dependencies are recorded as Foundry submodules and in `foundry.lock`.

## Requirements

- [Foundry](https://getfoundry.sh/)
- Git with submodule support

## Build and inspect

```sh
git clone --recurse-submodules https://github.com/0xFarhanDev/staking-foundry.git
cd staking-foundry
forge build
forge test
forge fmt --check
```

To run a local node in another terminal:

```sh
anvil
```

## Deploy to a test network

Copy `.env.example` to `.env`, fill in a **test-only** private key and RPC URL, then load the environment variables into your shell. Never commit `.env` or use a wallet holding valuable assets.

```sh
forge script script/DeployStaking.s.sol:DeployStaking \
  --rpc-url "$SEPOLIA_RPC_URL" \
  --broadcast
```

The deployment script creates the KHD token, implementation, and ERC-1967 proxy, then initializes the proxy with the deployer as admin. It prints each deployed address. Save the proxy address for the frontend and upgrade script.

To run the experimental V2 upgrade, set `PROXY_ADDRESS` in the environment and run:

```sh
forge script script/UpgradeStaking.s.sol:UpgradeStakingScript \
  --rpc-url "$SEPOLIA_RPC_URL" \
  --broadcast
```

Only use a disposable local or testnet deployment. The V2 implementation and upgrade path need more coverage before use.

## Project layout

```text
src/       Staking, token, and V2 implementation contracts
script/    Deployment and upgrade scripts
test/      Foundry tests
lib/       Foundry dependency submodules
.github/   CI workflow
```

## Known limitations

- This is an unaudited prototype; tests are small and do not establish security.
- `LOCK_DURATION` is declared but is not enforced by `stake` or `withdraw`.
- `claimReward` pays a fixed 10% per eligible claim, not a time-weighted yield. The V2 calculation is separate and needs dedicated tests.
- Emergency token withdrawal can affect assets backing user deposits. It needs a clear accounting and incident policy before production use.
- ERC-20 calls should be reviewed for return-value and non-standard-token behavior.
- There are no invariant, deployment, or upgrade-storage compatibility tests yet.

## License

The project contracts declare the MIT license. See source headers and dependency licenses for details.
