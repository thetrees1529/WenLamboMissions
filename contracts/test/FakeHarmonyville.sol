//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.14;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
interface IMissionsWallet {
    function withdrawAmount(address _to, uint256 _amount) external;
}
contract FakeHarmonyville is IMissionsWallet, ERC20("Fake Harmonyville", "FHVILLE") {
    function withdrawAmount(address _to, uint256 _amount) external {
        _mint(_to, _amount);
    }
}