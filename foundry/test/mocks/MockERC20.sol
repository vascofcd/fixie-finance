// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    uint8 private tokenDecimals;

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        tokenDecimals = 18;
    }

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external {
        _burn(account, amount);
    }

    function setDecimals(uint8 _decimals) external {
        if (totalSupply() > 0) {
            revert("Cannot set decimals after minting");
        }
        tokenDecimals = _decimals;
    }
}
