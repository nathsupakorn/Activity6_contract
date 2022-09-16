// SPDX-License-Identifier: Non-License
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "./ownable.sol";

struct Stock {
    bytes32 productId;
    string productName;
    uint256 price;
    uint256 minTemperature;
    uint256 maxTemperature;
    uint256 quantity;
}

contract FishMarket is Ownable {
    mapping(bytes32 => Stock) public stocks;

    constructor() {}

    function addNewProduct(
        uint256 _price,
        uint256 _minTemperature,
        uint256 _maxTemperature,
        string memory _productName
    ) public onlyOwner returns (bytes32 _productId) {
        require(_price > 0, "price too low");
        require(_minTemperature <= _maxTemperature, "invalid maxTemperature");

        _productId = keccak256(abi.encodePacked(_productName));

        Stock storage stock = stocks[_productId];
        require(stock.price == 0, "product is already exist.");

        stock.productId = _productId;
        stock.productName = _productName;
        stock.price = _price;
        stock.minTemperature = _minTemperature;
        stock.maxTemperature = _maxTemperature;
    }

    function getStock(string memory _productName)
        public
        view
        returns (Stock memory stock)
    {
        bytes32 _productId = keccak256(abi.encodePacked(_productName));

        stock = stocks[_productId];
        require(stock.price != 0, "product is not exist.");
    }

    function addStockQuantity(uint256 _quantity, string memory _productName)
        public
        onlyOwner
    {
        require(_quantity > 0, "invalid quantity");

        bytes32 _productId = keccak256(abi.encodePacked(_productName));
        Stock storage stock = stocks[_productId];

        require(stock.price != 0, "product is not exist.");

        stock.quantity += _quantity;
    }

    function removeStockQuantity(uint256 _quantity, string memory _productName)
        public
    {
        require(tx.origin == getOwner(), "unauthorized");
        require(_quantity > 0, "invalid quantity");

        bytes32 _productId = keccak256(abi.encodePacked(_productName));
        Stock storage stock = stocks[_productId];

        require(stock.price != 0, "product is not exist.");

        stock.quantity -= _quantity;
    }

    function updateStockPrice(uint256 _price, string memory _productName)
        public
        onlyOwner
    {
        require(_price > 0, "invalid price");

        bytes32 _productId = keccak256(abi.encodePacked(_productName));
        Stock storage stock = stocks[_productId];

        require(stock.price != 0, "product is not exist.");

        stock.price = _price;
    }

    function updateStockTemperature(
        uint256 _minTemperature,
        uint256 _maxTemperature,
        string memory _productName
    ) public onlyOwner {
        require(_minTemperature <= _maxTemperature, "invalid maxTemperature");

        bytes32 _productId = keccak256(abi.encodePacked(_productName));
        Stock storage stock = stocks[_productId];

        require(stock.price != 0, "product is not exist.");

        stock.maxTemperature = _maxTemperature;
        stock.minTemperature = _minTemperature;
    }
}
