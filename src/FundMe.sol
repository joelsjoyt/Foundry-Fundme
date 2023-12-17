// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5 * 1e18;
    address private immutable i_owner;

    address[] private s_funders;
    mapping(address funder => uint256 amountFunded)
        private s_addressToAmountFunded;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable returns (uint256) {
        // Allow users to send money
        // Allow minimun dollar emount in ETH
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Insufficient Ether sent"
        );
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
        return msg.value.getConversionRate(s_priceFeed);
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;

        for (
            uint256 funderIndex = 0;
            funderIndex < fundersLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // Reset the funder array
        s_funders = new address[](0);
        // Transfer funds to the owner
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Transaction failed");
    }

    function withdraw() public onlyOwner {
        // Loop through funder list and make the balance to zero
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // Reset the funder array
        s_funders = new address[](0);
        // Transfer funds to the owner
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Transaction failed");
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     * View / Pure functions (Getters)
     */

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
