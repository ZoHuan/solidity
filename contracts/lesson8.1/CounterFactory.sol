// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Counter {
    uint256 public count;
    address public owner;

    constructor(address _owner) {
        owner = _owner;
        count = 0;
    }

    function increment() external {
        require(msg.sender == owner, "Not owner");
        count++;
    }
}

contract CounterFactory {
    event CounterCreated(address indexed counterAddress, bytes32 salt);

    function createWithCreate2(bytes32 salt) external returns (address) {
        Counter counter = new Counter{salt: salt}(msg.sender);
        address counterAddress = address(counter);
        emit CounterCreated(counterAddress, salt);
        return counterAddress;
    }

    function computeAddress(
        bytes32 salt,
        address deployer
    ) external view returns (address) {
        bytes memory bytecode = abi.encodePacked(
            type(Counter).creationCode,
            abi.encode(msg.sender)
        );

        bytes32 hash = keccak256(
            abi.encodePacked(bytes1(0xff), deployer, salt, keccak256(bytecode))
        );

        return address(uint160(uint256(hash)));
    }
}
