pragma solidity 0.5.10;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/DecentralizedStore.sol";
import "../contracts/Proxy.sol";


contract TestDecentralizedStore {

    uint public initialBalance = 1 ether;

    DecentralizedStore decentralizedStore;

    Proxy firstOwner;

    constructor() public payable {}

    event LogOwnerAddress(address firstOwner, address owner);

    function beforeAll() public {
        decentralizedStore = DecentralizedStore(DeployedAddresses.DecentralizedStore());
        firstOwner = new Proxy(decentralizedStore);
    }

    function testOwnerAdressIsAdministrator() public {
        Assert.equal(decentralizedStore.isAdministrator(address(firstOwner)), false, "not one administrator");
    }

    function testOwnerIsAlsoAdministrator() public {
        address owner = msg.sender;
		Assert.equal(decentralizedStore.isAdministrator(owner), true, "Owner should be an administrator");
	}

    function() external {}

}