// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplyChain {
    uint public nextItemId = 0;
    uint public nextStepId = 0;

    struct Item {
        uint id;
        string name;
        string description;
        uint[] history;
        bool isShipped;
    }

    struct Step {
        uint id;
        uint itemId;
        address handler;
        string location;
        string description;
        uint timestamp;
    }

    mapping(uint => Item) public items;
    mapping(uint => Step) public steps;

    event ItemCreated(uint itemId);
    event StepAdded(uint itemId, uint stepId, address handler);

    function createItem(string memory _name, string memory _description) public {
        uint[] memory history;
        items[nextItemId] = Item(nextItemId, _name, _description, history, false);
        emit ItemCreated(nextItemId);
        nextItemId++;
    }

    function addItemStep(uint _itemId, string memory _location, string memory _description) public {
        require(_itemId < nextItemId, "Item does not exist.");
        require(!items[_itemId].isShipped, "Item has already been shipped.");

        steps[nextStepId] = Step(nextStepId, _itemId, msg.sender, _location, _description, block.timestamp);
        items[_itemId].history.push(nextStepId);
        emit StepAdded(_itemId, nextStepId, msg.sender);
        nextStepId++;
    }

    function shipItem(uint _itemId) public {
        require(_itemId < nextItemId, "Item does not exist.");
        require(!items[_itemId].isShipped, "Item has already been shipped.");
        
        items[_itemId].isShipped = true;
    }

    function getItemHistory(uint _itemId) public view returns (Step[] memory) {
        Item storage item = items[_itemId];
        Step[] memory history = new Step[](item.history.length);
        for (uint i = 0; i < item.history.length; i++) {
            history[i] = steps[item.history[i]];
        }
        return history;
    }
}
