// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.7.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20 {
    address burnerAddress;

    constructor(uint256 totalSupply, address _burnerAddress)
        public
        ERC20("Blue Hill", "BHF")
    {
        _mint(_msgSender(), totalSupply);
        burnerAddress = _burnerAddress;
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        require(
            _msgSender() != burnerAddress,
            "Cannot transfer from burner address"
        );
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function totalAvailable() public view returns (uint256) {
        return super.totalSupply() - balanceOf(burnerAddress);
    }
}
