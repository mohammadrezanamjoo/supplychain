const SupplyChain = artifacts.require("SupplyChain");

contract("SupplyChain", (accounts) => {
  let contract;

  before(async () => {
    contract = await SupplyChain.deployed();
  });

  it("should deploy successfully", async () => {
    assert(contract.address !== '');
  });

  it("should add an item correctly", async () => {
    await contract.addItem("Widget", "A standard widget", { from: accounts[0] });
    const item = await contract.items(0);
    assert(item.name === "Widget", "Item name should be 'Widget'");
  });

  it("should allow shipping of an item", async () => {
    await contract.addItem("Gadget", "A special gadget", { from: accounts[0] });
    await contract.shipItem(0, { from: accounts[0] });
    const item = await contract.items(0);
    assert(item.isShipped === true, "Item should be marked as shipped");
  });
});
