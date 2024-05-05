// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplyChain {
    address public owner;

    uint public nextItemId = 0;
    uint public nextStepId = 0;

    struct Item {
        uint id;
        string name;
        string description;
        uint[] history;
        bool isShipped;
        address owner;
        uint quantity;
        uint expirationDate;
    }

    struct Step {
        uint id;
        uint itemId;
        address handler;
        string location;
        string description;
        uint timestamp;
        uint amountPaid;
    }

    mapping(uint => Item) public items;
    mapping(uint => Step) public steps;

    event ItemCreated(uint itemId, address indexed owner);
    event StepAdded(uint itemId, uint stepId, address indexed handler);
    event ItemShipped(uint itemId);
    event PaymentReceived(uint stepId, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function.");
        _;
    }

    constructor() {
        owner = msg.sender ;
    }

    function createItem(string memory _name, string memory _description, uint _quantity, uint _expirationDate) public {
        uint[] memory history;
        items[nextItemId] = Item(nextItemId, _name, _description, history, false, msg.sender, _quantity, _expirationDate);
        emit ItemCreated(nextItemId, msg.sender) ;
        nextItemId++;
    }

    function addItemStep(uint _itemId, string memory _location, string memory _description) public {
        require(_itemId < nextItemId, "Item does not exist.");
        require(!items[_itemId].isShipped, "Item has already been shipped. ");

        steps[nextStepId] = Step(nextStepId, _itemId, msg.sender, _location, _description, block.timestamp, 0);
        items[_itemId].history.push(nextStepId);
        emit StepAdded(_itemId, nextStepId, msg.sender);
        nextStepId++;
    }

    function shipItem(uint _itemId) public {
        require(_itemId < nextItemId, "Item does not exist.");
        require(!items[_itemId].isShipped, "Item has already been shipped.");
        
        items[_itemId].isShipped = true;
        emit ItemShipped(_itemId);
    }

    function getItemHistory(uint _itemId) public view returns (Step[] memory) {
        Item storage item = items[_itemId];
        Step[] memory history = new Step[](item.history.length);
        for (uint i = 0; i < item.history.length; i++) {
            history[i] = steps[item.history[i]];
        }
        return history;
    }

    function makePayment(uint _stepId) public payable {
        require(_stepId < nextStepId, "Step does not exist.");
        require(!steps[_stepId].handler == msg.sender, "You cannot pay yourself.");
        
        steps[_stepId].amountPaid += msg.value;
        emit PaymentReceived(_stepId, msg.value);
    }

    function withdrawFunds() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        owner  = _newOwner;
    }
}
