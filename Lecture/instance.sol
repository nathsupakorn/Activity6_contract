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

contract CallStorage {
    Storage storageContract;

    constructor(address _storage) {
        storageContract = Storage(_storage);
    }

    function retrieveX2() public view returns (uint256) {
        return storageContract.retrieve() * 2;
    }
}
