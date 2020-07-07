// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.7.0;

import "../Wallet.sol";

contract WalletTest is Wallet {
    uint256 public currentTime;

    constructor(Token _token, address manager) public Wallet(_token, manager) {}

    function time() public override view returns (uint256) {
        return currentTime;
    }

    function setCurrentTime(uint256 _currentTime) public {
        currentTime = _currentTime;
    }
}
