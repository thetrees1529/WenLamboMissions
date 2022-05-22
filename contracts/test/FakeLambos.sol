//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.14;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract FakeLambos is ERC721("Fake Lambos", "FLS") {
    constructor() {
        for(uint i; i < 10; i ++) {
            _mint(msg.sender, i);
        }
    }
    struct StatisticView {
        string statistic;
        uint256 value;
    }
    function getAttributes(uint256) external pure returns (StatisticView[] memory stats) {
        stats = new StatisticView[](2);
        for(uint i; i < stats.length; i ++) {
            stats[i] = StatisticView(string(abi.encodePacked(i)), 5);
        }
    }
}