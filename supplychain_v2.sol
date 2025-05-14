pragma solidity ^0.8.0;

contract SupplyChain {

    enum State { Created, Manufactured, ForSale, Sold, Shipped, Received }

    struct Product {

        uint id;

        string name;

        uint price;

        State state;

        address payable owner;
    }
    mapping(uint => Product) public products;

    uint public productCounter;

    event ProductCreated(uint id, string name, uint price, address owner);

    event ProductManufactured(uint id);
    event ProductForSale(uint id, uint price);
    event ProductSold(uint id, address buyer);
    event ProductShipped(uint id);
    event ProductReceived(uint id);

    // Modifier to check if caller is the owner of the product
    modifier onlyOwner(uint _id) {
        require(products[_id].owner == msg.sender, "Caller is not the owner");
        _;
    }

    // Modifier to check if product is in a specific state
    modifier inState(uint _id, State _state) {
        require(products[_id].state == _state, "Invalid state");
        _;
    }

    // Function to create a product
    function createProduct(string memory _name, uint _price) public {
        productCounter++;
        products[productCounter] = Product(productCounter, _name, _price, State.Created, payable(msg.sender));
        emit ProductCreated(productCounter, _name, _price, msg.sender);
    }

    // Function to manufacture a product

    function manufactureProduct(uint _id) public onlyOwner(_id) inState(_id, State.Created) {
        products[_id].state = State.Manufactured;
        emit ProductManufactured(_id);
    }

    // Function to put a product for sale
    function putProductForSale(uint _id, uint _price) public onlyOwner(_id) inState(_id, State.Manufactured) {
        products[_id].price = _price;
        products[_id].state = State.ForSale;
        emit ProductForSale(_id, _price);
    }

    // Function to buy a product
    function buyProduct(uint _id) public payable inState(_id, State.ForSale) {

        Product storage product = products[_id];
        require(msg.value == product.price, "Incorrect price");

        product.owner.transfer(msg.value);
        product.owner = payable(msg.sender);
        product.state = State.Sold;
        emit ProductSold(_id, msg.sender);
    }

    function shipProduct(uint _id) public onlyOwner(_id) inState(_id, State.Sold) {

        products[_id].state = State.Shipped;
        emit ProductShipped(_id);
    }

    function receiveProduct(uint _id) public onlyOwner(_id) inState(_id, State.Shipped) {

        products[_id].state = State.Received;
        emit ProductReceived(_id);
    }
}
