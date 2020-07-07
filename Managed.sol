// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.7.0;

import "@openzeppelin/contracts/GSN/Context.sol";

contract Managed is Context {
    address _manager;

    constructor() internal {
        _manager = _msgSender();
    }

    function manager() public view returns (address) {
        return _manager;
    }

    modifier onlyManager() {
        require(_manager == _msgSender(), "Managed: caller is not the manager");
        _;
    }
}
