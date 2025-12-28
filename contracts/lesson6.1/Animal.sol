// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Animal {
    string public species;

    constructor(string memory _species) {
        species = _species;
    }

    // 抽象函数：子合约必须实现
    function makeSound() public virtual returns (string memory);

    // 普通函数：所有动物共用
    function eat() public pure returns (string memory) {
        return "Eating...";
    }

    function sleep() public pure returns (string memory) {
        return "Sleeping...";
    }
}

contract Dog is Animal {
    constructor() Animal("Dog") {}

    function makeSound() public pure override returns (string memory) {
        return "Woof! Woof!";
    }
}

contract Cat is Animal {
    constructor() Animal("Cat") {}

    function makeSound() public pure override returns (string memory) {
        return "Meow! Meow!";
    }
}
