# ExampleGameAssetsContractERC1155
Example game asset contract with in game currency, buy function, rartity based status values and fragments to mint the game asset.

## Requirements
### Require 00
A contract workspace according to previous examples.

### Require 01
Hosted metadata according to previous examples.

## The contract / Implemented tokenomics
### Items
There are 11 predefined items. The currency, 5 rarities of game asset and 5 rarities of token. 

### Pricing
The values defined are just an example to represent some ideas of mechanics in the game asset. Further the resulting price adjustment functions are not implemented yet. These steps will follow after game contract creation.

| Variable | About | Value |
| --- | --- | --- |
| _FeePerAsset | The price in native curreny to pay mint a single asset. | 0.001 ether |
| _FragmentsPerAsset | The number of fragments to burn, to mint a defined rarity with default charge. | 100 |
| _CashPerAsset | The number of cash to pay (and/or burn), to mint a random asset. | 100 |
| _CashPerAssetFee | The number of cash to pay to the owner, to mint a random asset. | 10 |
| _FusionAssetDefaultCharge | The number of assets to mint when fusioning an asset. | 10 |

### Modifier
The following modifiers are implemented:

| Name | Calls | Requirements | 
| --- | --- | --- |
| mintNativeCompliance | mintWithNative | Message value lower than sender balance |
|   |   | Mint amount must match |
|   |   | Message value higher than fee per asset * mint amount |
| mintCashCompliance | mintWithCash | Message value lower than sender balance |
|   |   | Mint amount must match |
|   |   | Cash balance higher than (cash per asset to burn + cash per asset fee) * mint amount |
| mintFragmentCompliance | mintWithFragment | Message value lower than sender balance |
|   |   | Rarity in range ( >= 0) |
|   |   | Rarity in range ( <= 4) |
|   |   | Message value higher that fee per asset * mint amount |
|   |   | Balance of fragments enough to fusion |
| isAsset | getStatsURI | Id in range ( > 0) |
|   |  mintWithFragment | Id in range ( < 6) |
| isCash |  | Id in range ( == 0) |
| isFragment |  | Id in range ( < 11) |
| isFragment |  | Id in range ( > 5) |

### Maintenance functions
