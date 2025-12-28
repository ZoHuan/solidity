// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library AddressSet {
    struct Set {
        address[] values;
        mapping(address => uint256) indexes;
    }

    function add(Set storage set, address value) internal returns (bool) {
        if (contains(set, value)) {
            return false;
        }

        set.values.push(value);
        set.indexes[value] = set.values.length;
        return true;
    }

    function remove(Set storage set, address value) internal returns (bool) {
        uint256 index = set.indexes[value];

        if (index == 0) {
            return false;
        }

        uint256 toDeleteIndex = index - 1;
        uint256 lastIndex = set.values.length - 1;

        if (toDeleteIndex != lastIndex) {
            address lastValue = set.values[lastIndex];
            set.values[toDeleteIndex] = lastValue;
            set.indexes[lastValue] = index;
        }

        set.values.pop();
        delete set.indexes[value];

        return true;
    }

    function contains(
        Set storage set,
        address value
    ) internal view returns (bool) {
        return set.indexes[value] != 0;
    }

    function length(Set storage set) internal view returns (uint256) {
        return set.values.length;
    }

    function at(
        Set storage set,
        uint256 index
    ) internal view returns (address) {
        require(index < set.values.length, "Index out of bounds");
        return set.values[index];
    }
}

contract Whitelist {
    using AddressSet for AddressSet.Set;

    AddressSet.Set private whitelist;

    function addToWhitelist(address account) public {
        require(whitelist.add(account), "Already in whitelist");
    }

    function removeFromWhitelist(address account) public {
        require(whitelist.remove(account), "Not in whitelist");
    }

    function isWhitelisted(address account) public view returns (bool) {
        return whitelist.contains(account);
    }

    function getWhitelistSize() public view returns (uint256) {
        return whitelist.length();
    }
}
