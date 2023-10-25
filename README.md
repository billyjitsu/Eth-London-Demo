# QRNG Example

> An example project that demonstrates the usage of the Airnode request–response protocol to receive API3 QRNG services

This README documents this specific QRNG example implementation. For more general information, refer to the
[API3 QRNG docs](https://docs.api3.org/qrng/).

## Instructions

1. Install the dependencies

```sh
yarn install
```

## What does the contract do

The contract allows a user to mint an NFT/s and then have a random NFT minted to them.  Due to the volatility of cryptocurrency we keep our price consistent use dAPI price feeds for every mint.  The randomness can be used to add stats or sell items based on stats with a similar setup.

## QrngExample contract documentation

### Request parameters

The contract uses the following parameters to make requests:

- `airnode`: Airnode address that belongs to the API provider
- `endpointId`: Airnode endpoint ID that will be used. Different endpoints are used to request a `uint256` or
  `uint256[]`
- `sponsorWallet`: Sponsor wallet address derived from the Airnode extended public key and the sponsor address

For further
information, see the [docs on Airnode RRP concepts](https://docs.api3.org/airnode/latest/concepts/).

### Sponsor wallet
 You can derive the sponsor wallet using the following command (you can find `<XPUB>` and `<AIRNODE>` in
`scripts/apis.js`):

```sh
npx @api3/airnode-admin derive-sponsor-wallet-address \
  --airnode-xpub <XPUB> \
  --airnode-address <AIRNODE> \
  --sponsor-address <QRNG_EXAMPLE_ADDRESS>
```

The Airnode will use this sponsor wallet to respond to the requests made by QrngExample. This means that you need to
keep this wallet funded.

The sponsorship scheme can be used in different ways, for example, by having the users of your contract use their own
individual sponsor wallets. Furthermore, sponsors can request withdrawals of funds from their sponsor wallets. For more
information about the sponsorship scheme, see the
[sponsorship docs](https://docs.api3.org/airnode/latest/concepts/sponsor.html).

## dAPI contract documentation

## Table of Contents
- [Imports](#imports)
- [State Variables](#state-variables)
- [Functions](#functions)

## Imports

1. **API3's IProxy Interface**
   * Used for interactions with the proxy data feed.
2. **OpenZeppelin's Ownable**
   * Provides mechanisms to manage single ownership over the contract.

## State Variables

### `proxyAddress`
* **Description**: Holds the address of the API3 proxy data feed.

## Functions

### `setProxyAddress`
* **Parameters**: 
  - `_proxyAddress`: Address of the API3 proxy data feed.
* **Description**: 
  * Allows the contract owner to set or update the address of the proxy data feed.

### `readDataFeed`
* **Returns**: 
  * `price`: Current value from the data feed.
  * `timestamp`: Timestamp of the last update.
* **Description**: 
  * Reads the latest data from the specified proxy data feed, then converts and returns the value and timestamp.

