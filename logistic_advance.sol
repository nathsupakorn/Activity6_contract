// SPDX-License-Identifier: Non-License
pragma solidity 0.8.15;

import './fishMarket.sol'

enum StateType {
    Idle,
    Created,
    InTransit,
    Complete,
    Cancel,
    Done
}

struct Deal {
    bytes32 dealId;
    address transporter;
    address customer;
    string productName;
    uint256 minTemperature;
    uint256 maxTemperature;
    uint256 price;
    bool cancelable;
    StateType transportState;
}

contract Logistic {
    address owner;
    mapping(bytes32 => Deal) public deals;

    modifier onlyOwner() {
        require(msg.sender == owner, "unauthorized");
        _;
    }

    modifier onlyTransporter(bytes32 dealId) {
        require(msg.sender == deals[dealId].transporter, "unauthorized");
        _;
    }

    modifier onlyCustomer(bytes32 dealId) {
        require(msg.sender == deals[dealId].customer, "unauthorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /*
        Function to initalize a initDeal
        @param : customer's address, price (in Ether), minimum and maximum temperature allow, productName
    */
    function initDeal is FishMarket (
        address payable _customer,
        uint256 _quantity
    ) public onlyOwner returns (Deal memory) {
        require(stocks.minTemperature <= stocks.maxTemperature, "invalid maxTemperature");
        require((_quantity >= 1) && (stocks.quantity >= _quantity), "invalid quantity")

        bytes32 dealId = keccak256(
            abi.encodePacked(_customer, block.timestamp)
        );

        //update stocks
        stocks.quantity = stocks.quantity - _quantity

        Deal storage deal = deals[dealId];

        deal.dealId = dealId;
        deal.customer = _customer;
        deal.minTemperature = stocks.minTemperature;
        deal.maxTemperature = stocks.maxTemperature;
        deal.price = stocks.price * _quantity;
        deal.productName = stocks.productName;
        deal.cancelable = false;
        deal.transportState = StateType.Created;

        return deal;
    }

    /*
        Function to transport to customer
        @param : transporter's address
    */
    function transport(bytes32 dealId, address _transporter) public onlyOwner {
        Deal storage deal = deals[dealId];

        require(
            deal.transportState == StateType.Created,
            "invalid transportState"
        );

        deal.transporter = _transporter;
        deal.transportState = StateType.InTransit;
    }

    /*
        Function to update sensor from transporter
        @param : current temp
    */
    function updateTemp(bytes32 dealId, uint256 _temp)
        public
        onlyTransporter(dealId)
    {
        Deal storage deal = deals[dealId];

        require(
            deal.transportState == StateType.InTransit,
            "invalid transportState"
        );

        if (_temp > deal.maxTemperature || _temp < deal.minTemperature) {
            deal.cancelable = true;
        }
    }

    /*
        Function to cancel current deal if measured temperature is out of range
        @param: -
    */
    function cancelDeal(bytes32 dealId) public onlyCustomer(dealId) {
        Deal storage deal = deals[dealId];

        require(
            deal.transportState == StateType.InTransit,
            "invalid transportState"
        );
        require(deal.cancelable == true, "unmatched cancel condition");

        deal.transportState = StateType.Cancel;
    }

    /*
        Function to complete and pay for deal
        @param : -
        This function require ether to be transfered.
    */
    function pay(bytes32 dealId) public payable onlyCustomer(dealId) {
        Deal storage deal = deals[dealId];

        require(
            deal.transportState == StateType.InTransit,
            "invalid transportState"
        );
        require(msg.value == deal.price);

        deal.transportState = StateType.Complete;
    }

    /*
        Function for owner to get ether from contract 
        @param : -
    */
    function clearance(bytes32 dealId) public payable onlyOwner {
        Deal storage deal = deals[dealId];

        require(
            deal.transportState == StateType.Complete ||
                deal.transportState == StateType.Cancel,
            "invalid transportState"
        );

        uint256 amountToOwner = (deal.price * 9) / 10;
        if (deal.transportState == StateType.Complete) {
            _transfer(owner, amountToOwner);
            _transfer(deal.transporter, deal.price - amountToOwner);
        }

        deal.transportState = StateType.Done;
    }

    function _transfer(address to, uint256 amount) internal {
        (bool success, ) = to.call{value: amount}(new bytes(0));
        if (!success) {
            revert("transfer error");
        }
    }

    receive() external payable {
        revert("Not support sending Ethers to this contract directly.");
    }
}
