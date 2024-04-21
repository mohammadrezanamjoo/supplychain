// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplyChain {
    struct Item {
        uint id;
        string name;
        string description;
        address currentOwner;
        bool isShipped;
    }

    Item[] public items;
    uint public nextItemId;

    event ItemAdded(uint itemId, string name, address indexed owner);
    event ItemShipped(uint itemId, address indexed shippedBy);

    function addItem(string memory _name, string memory _description) public {
        items.push(Item({
            id: nextItemId,
            name: _name,
            description: _description,
            currentOwner: msg.sender,
            isShipped: false
        }));
        emit ItemAdded(nextItemId, _name, msg.sender);
        nextItemId++;
    }

    function shipItem(uint _itemId) public {
        Item storage item = items[_itemId];
        require(msg.sender == item.currentOwner, "Only the item owner can ship it.");
        require(!item.isShipped, "Item is already shipped.");

        item.isShipped = true;
        emit ItemShipped(_itemId, msg.sender);
    }

    // Add more functions here as needed
}
