let catchRevert = require("./exceptionsHelpers.js").catchRevert

var DecentralizedStore = artifacts.require("DecentralizedStore");

contract("DecentralizedStore", accounts => {

    const owner = accounts[0];
    const firstAdministrator = accounts[1];
    const secondAdministrator = accounts[2];
    const owner1 = accounts[3];
    const owner2 = accounts[4];
    
    before(async() => {
        decentralizedStoreInstance = await DecentralizedStore.deployed();
    });

    it("Check if the owner is an administrator", async() => {
        const registered = await decentralizedStoreInstance.isAdministrator(owner, {from:owner});
        assert.equal(registered, true, "Owner should be enrolled");

    });
    it("Add an adminitrator", async() => {
        await decentralizedStoreInstance.createNewAdministrator(firstAdministrator, {from:owner});
        const registered = await decentralizedStoreInstance.isAdministrator(firstAdministrator, {from:owner});
        assert.equal(registered, true, "Administrator should be added ");

    });

    it("An administrator add a second administrator", async() => {
        await decentralizedStoreInstance.createNewAdministrator(secondAdministrator, {from:firstAdministrator});
        const registered = await decentralizedStoreInstance.isAdministrator(secondAdministrator, {from:firstAdministrator});
        assert.equal(registered, true, "the administator should add another administrator");

    });

    it("One administrator can be removed only by the owner", async() => {
        await catchRevert(decentralizedStoreInstance.deleteAdministrator(secondAdministrator, {from:firstAdministrator}));
    });

    it("administrator removed by the owner", async() => {
        await decentralizedStoreInstance.deleteAdministrator(secondAdministrator, {from:owner});
        const registered = await decentralizedStoreInstance.isAdministrator(secondAdministrator, {from:owner});
        assert.equal(registered, false, "the second admin from the owner");

    });

    it("create unapproved owner", async() => {
        await decentralizedStoreInstance.createOwner({from:owner1});
        const registered = await decentralizedStoreInstance.isOwnerApproved(owner1, {from:owner1});
        const lenght = await decentralizedStoreInstance.getOwnersNumber.call();
        assert.equal(registered, false, "owner added but not approved");
        assert.equal(lenght, 1, "one owner requested");
    });

    it("administrator approve owner", async() => {
        await decentralizedStoreInstance.addOwner(owner1, {from:firstAdministrator});
        const registered = await decentralizedStoreInstance.isOwnerApproved(owner1, {from:owner1});
        assert.equal(registered, true, "admin need to approve");
    });

    it("test owner reimmision", async() => {
        await catchRevert(decentralizedStoreInstance.createOwner({from:owner1}));
    });

    it("The owner pause the contract", async() => {
        await decentralizedStoreInstance.pause({from:owner});
        assert.equal(await decentralizedStoreInstance.paused(), true, "Contract paused");
    });

});