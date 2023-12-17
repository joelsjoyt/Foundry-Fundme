// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // Address ETH/USD 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // Remove unnecessary returns from the function
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // Price of ETH in USD
        // 200000000 * 10000000000 => 20000000000000000
        return uint256(price * 1e10);
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        // 1000000000000000000 * 2000000000000000000 => 2000000000000000000000000000000000000 / 1000000000000000000
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUSD;
    }
}
