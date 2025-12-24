// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleShop {
    address public immutable OWNER;
    uint public constant ITEM_PRICE = 0.1 ether;

    mapping(address => uint) public purchases;

    event ItemPurchased(address indexed buyer, uint quantity, uint totalPaid);
    event Withdrawal(address indexed owner, uint amount);

    constructor() {
        OWNER = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == OWNER, "Not the owner");
        _;
    }

    // 购买商品
    function buyItem(uint quantity) public payable {
        require(quantity > 0, "Invalid quantity");

        uint totalCost = ITEM_PRICE * quantity;
        require(msg.value == totalCost, "Incorrect payment");

        purchases[msg.sender] += quantity;

        emit ItemPurchased(msg.sender, quantity, msg.value);
    }

    // 查询购买数量
    function getPurchases(address buyer) public view returns (uint) {
        return purchases[buyer];
    }

    // 提现（仅owner）
    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");

        (bool sent, ) = OWNER.call{value: balance}("");
        require(sent, "Transfer failed");

        emit Withdrawal(OWNER, balance);
    }

    // 查询合约余额
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}
