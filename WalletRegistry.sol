// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.7.0;

import "./Token.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract WalletRegistry is Ownable {
    mapping(address => bool) private wallets;

    function addWallet(address _wallet) public onlyOwner {
        wallets[_wallet] = true;
    }

    function exists(address _wallet) public view returns (bool) {
        return wallets[_wallet];
    }
}
