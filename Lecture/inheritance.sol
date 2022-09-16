// SPDX-License-Identifier: Non-License
pragma solidity 0.8.15;

contract Storage {
    uint256 number;

    function store(uint256 num) public {
        number = num;
    }

    function retrieve() public view returns (uint256) {
        return number;
    }
}

contract AdvancedStorage is Storage {
    address owner;

    constructor() {
        owner = msg.sender;
    }

    function double() public {
        number = number * 2;
    }
}
