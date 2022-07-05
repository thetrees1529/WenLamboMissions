
//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TempVault is AccessControl {
    using SafeERC20 for IERC20;

    bytes32 public constant WITHDRAWER_ROLE = keccak256("WITHDRAWER_ROLE");

    constructor(IERC20 hville) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _hville = hville;
    }

    IERC20 private _hville;

    function withdrawAmount(address to, uint value) external onlyRole(WITHDRAWER_ROLE) {
        _hville.safeTransfer(to, value);
    }

    function hVilleAddress() external view returns(address) {
        return address(_hville);
    }

}