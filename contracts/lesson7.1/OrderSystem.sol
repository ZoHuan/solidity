// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract OrderSystem {
    enum OrderStatus { Created, Paid, Shipped, Completed, Cancelled }
    
    struct Order {
        address buyer;
        uint256 amount;
        OrderStatus status;
        uint256 createdAt;
    }
    
    mapping(uint256 => Order) public orders;
    uint256 public orderCount;
    
    // 订单创建事件
    event OrderCreated(
        uint256 indexed orderId,
        address indexed buyer,
        uint256 amount,
        uint256 timestamp
    );
    
    // 订单支付事件
    event OrderPaid(
        uint256 indexed orderId,
        address indexed buyer,
        uint256 amount,
        uint256 timestamp
    );
    
    // 订单发货事件
    event OrderShipped(
        uint256 indexed orderId,
        uint256 timestamp
    );
    
    // 订单完成事件
    event OrderCompleted(
        uint256 indexed orderId,
        address indexed buyer,
        uint256 timestamp
    );
    
    // 订单取消事件
    event OrderCancelled(
        uint256 indexed orderId,
        address indexed cancelledBy,
        string reason,
        uint256 timestamp
    );
    
    // 创建订单
    function createOrder() public payable returns (uint256) {
        require(msg.value > 0, "Amount must be greater than zero");
        
        uint256 orderId = orderCount++;
        
        orders[orderId] = Order({
            buyer: msg.sender,
            amount: msg.value,
            status: OrderStatus.Created,
            createdAt: block.timestamp
        });
        
        // 触发订单创建事件
        emit OrderCreated(orderId, msg.sender, msg.value, block.timestamp);
        
        return orderId;
    }
    
    // 支付订单
    function payOrder(uint256 orderId) public {
        Order storage order = orders[orderId];
        
        require(order.buyer == msg.sender, "Not the buyer");
        require(order.status == OrderStatus.Created, "Invalid order status");
        
        // 更新状态
        order.status = OrderStatus.Paid;
        
        // 触发支付事件
        emit OrderPaid(orderId, msg.sender, order.amount, block.timestamp);
    }
    
    // 发货（仅为演示，实际应该有权限控制）
    function shipOrder(uint256 orderId) public {
        Order storage order = orders[orderId];
        
        require(order.status == OrderStatus.Paid, "Order not paid");
        
        // 更新状态
        order.status = OrderStatus.Shipped;
        
        // 触发发货事件
        emit OrderShipped(orderId, block.timestamp);
    }
    
    // 确认收货
    function completeOrder(uint256 orderId) public {
        Order storage order = orders[orderId];
        
        require(order.buyer == msg.sender, "Not the buyer");
        require(order.status == OrderStatus.Shipped, "Order not shipped");
        
        // 更新状态
        order.status = OrderStatus.Completed;
        
        // 触发完成事件
        emit OrderCompleted(orderId, msg.sender, block.timestamp);
    }
    
    // 取消订单
    function cancelOrder(uint256 orderId, string memory reason) public {
        Order storage order = orders[orderId];
        
        require(order.buyer == msg.sender, "Not the buyer");
        require(
            order.status == OrderStatus.Created || order.status == OrderStatus.Paid,
            "Cannot cancel order"
        );
        
        // 更新状态
        order.status = OrderStatus.Cancelled;
        
        // 退款
        if (order.status == OrderStatus.Paid) {
            payable(order.buyer).transfer(order.amount);
        }
        
        // 触发取消事件
        emit OrderCancelled(orderId, msg.sender, reason, block.timestamp);
    }
}