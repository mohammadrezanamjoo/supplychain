const SupplyChain = artifacts.require("SupplyChain");

contract("SupplyChain", (accounts) => {
    let contract;

    before(async () => {
        contract = await SupplyChain.deployed();
    });

    it("should deploy successfully", async () => {
        assert(contract.address !== '');
    });

    it("should create an item correctly", async () => {
        await contract.createItem(" Widget", "A standard widget ");
        const item = await contract.items(0);
        assert.equal(item.name, "Widget", " Name should be 'Widget'");
    });

    it("should add steps to an item's history", async () => {
        await contract.createItem(" Gadget", "A special gadget");
        
        await contract.addItemStep(1, "Warehouse A", "Received at location");
        await contract.addItemStep(1, "Warehouse B", "Dispatched to next location");
        const itemHistory = await contract.getItemHistory(1);
        assert.equal(itemHistory.length, 2, "There should be two steps recorded in the item's history");
    });

    it("should allow marking an item as shipped", async () => {
        await contract.createItem("Machine", "A complex machine");
        await contract.shipItem(3);
        const item = await contract.items(3);
        assert.equal(item.isShipped, true, "Item should be marked as shipped");
    });
});
