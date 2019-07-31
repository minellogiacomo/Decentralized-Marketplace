pragma solidity 0.5.10;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/DecentralizedStore.sol";
import "../contracts/Marketplace.sol";
import "../contracts/Proxy.sol";

contract TestMarketplace {
    uint public initialBalance = 1 ether;

    DecentralizedStore public decentralizedStore;
    Marketplace public marketplace;
    Proxy firstOwner;

    constructor() public payable {}

    event LogOwnerAddress(address firstOwner, address owner);

    function beforeAll() public {
        decentralizedStore = DecentralizedStore(DeployedAddresses.DecentralizedStore());
        marketplace = Marketplace(DeployedAddresses.Marketplace());
        firstOwner = new Proxy(decentralizedStore);
    }

    function testMarketplaceCreated() public {
        Assert.equal(marketplace.getMarketNumber(), 0, "no store");
    }

    function() external payable{}
}