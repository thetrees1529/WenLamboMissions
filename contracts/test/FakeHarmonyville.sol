//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.14;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FakeHarmonyville is ERC20("Fake Harmonyville", "FHVILLE") {
    constructor() {
        _mint(msg.sender, ~uint(0));
    }
}