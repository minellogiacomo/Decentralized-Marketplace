let catchRevert = require("./exceptionsHelpers.js").catchRevert
var DecentralizedStore = artifacts.require("DecentralizedStore");
var Marketplace = artifacts.require("Marketplace");
const BN = web3.utils.BN;

contract ("Marketplace", accounts => {
    const owner = accounts[0];
    const firstOwner = accounts[3];
    const secondOwner = accounts[4];
    const thirdOwner = accounts[5];

    let decentralizedStoreInstance;
    let marketplaceInstance;

    const firstMarketplace = {
        id: "firstMarketplace"
    }

    const firstProduct = {
        idP: "firstProduct",
        description: "firstProduct",
        price:25,
        stock:14
    }

    const secondMarketplace = {
        id: "secondMarketplace"
    }

    const secondProduct = {
        idP: "secondProduct",
        description: "secondProduct",
        price:35,
        stock:17
    }

    const thirdMarketplace = {
        id: "thirdMarketplace"
    }
    
    const thirdProduct = {
        idP: "thirdProduct",
        description: "thirdProduct",
        price:42,
        stock:24
    }

    const fourthMarketplace = {
        id: "fourthMarketplace"
    }

    const fourthProduct = {
        idP: "fourthProduct",
        description: "fourthProduct",
        price:20,
        stock:57
    }

    beforeEach(async() => {
        decentralizedStoreInstance = await DecentralizedStore.new();
        marketplaceInstance = await Marketplace.new(decentralizedStoreInstance.address);
    });

    describe("Creation ", () => {
        describe("Create Marketplace", async() =>{
            it("new approved marketplace", async() => {
                await decentralizedStoreInstance.addOwner(firstOwner, {from:owner});
                const transaction = await marketplaceInstance.addMarket(firstMarketplace.id, {from:firstOwner});
                const marketId = transaction.logs[0].args.idMarketplace;
                const id = await marketplaceInstance.getIdGivenOwner(firstOwner, 0, {from:firstOwner});
                assert.equal(marketId, id, "Market should be created");
                const namemarketowner = await marketplaceInstance.getNumberGivenOwner(firstOwner, {from:firstOwner});
                assert.equal(namemarketowner, 1, "Market count should match");
            });

            it("add new approved marketplaces", async() => {
                await decentralizedStoreInstance.addOwner(firstOwner, {from:owner});
                await marketplaceInstance.addMarket(firstMarketplace.id, {from:firstOwner});
                await marketplaceInstance.addMarket(secondMarketplace.id, {from:firstOwner});
                await marketplaceInstance.addMarket(thirdMarketplace.id, {from:firstOwner});
                const namemarketowner = await marketplaceInstance.getNumberGivenOwner(firstOwner, {from:firstOwner});
                assert.equal(namemarketowner, 3, "right number of markets created (3)");
            });
        
            it("add new Market anch check correct informations", async() => {
                await decentralizedStoreInstance.addOwner(thirdOwner, {from:owner});
                const transaction = await marketplaceInstance.addMarket(fourthMarketplace.id, {from:thirdOwner});
                const idMarketplace = transaction.logs[0].args.idMarketplace;
                const namemarketowner = await marketplaceInstance.getOwnerGivenMarketplaceId(idMarketplace, {from:thirdOwner});
                assert.equal(namemarketowner, thirdOwner, "owner");
                const name = await marketplaceInstance.getMarketplaceName(idMarketplace, {from:thirdOwner});
                assert.equal(name, fourthMarketplace.id, "name");     
            });
        })

        describe("Add products", async() =>{
            it("Add product", async() => {
                await decentralizedStoreInstance.addOwner(firstOwner, {from:owner});
                const transaction = await marketplaceInstance.addMarket(firstMarketplace.id, {from:firstOwner});
                const idMarketplace = transaction.logs[0].args.idMarketplace; 
                const productOperation = await marketplaceInstance.addProductToMarket(idMarketplace,firstProduct.idP, firstProduct.description, 
                    firstProduct.price, firstProduct.stock,{from:firstOwner}); 
                const idProduct = productOperation.logs[0].args.productId;
                const id = await marketplaceInstance.getProductOfMarket(idMarketplace, 0, {from:firstOwner});
                assert.equal(idProduct, id, "new product should have been created");
                const productsData = await marketplaceInstance.getProductData(idProduct, {from:firstOwner});
                assert.equal(productsData[0].toString(), firstProduct.idP, "name");
                assert.equal(productsData[1].toString(), firstProduct.description, "desc");
                assert.equal(productsData[2].toNumber(), firstProduct.price, "price");
                assert.equal(productsData[3].toNumber(), firstProduct.stock, "qt");
            })
            it("Add products", async() => {
                await decentralizedStoreInstance.addOwner(firstOwner, {from:owner});
                const transaction = await marketplaceInstance.addMarket(firstMarketplace.id, {from:firstOwner});
                const idMarketplace = transaction.logs[0].args.idMarketplace;
                const productOperation1 = await marketplaceInstance.addProductToMarket(idMarketplace,firstProduct.idP, firstProduct.description, 
                    firstProduct.price, firstProduct.stock,{from:firstOwner});
                const id1 = productOperation1.logs[0].args.productId;
                const productOperation2 = await marketplaceInstance.addProductToMarket(idMarketplace,secondProduct.idP, secondProduct.description, 
                    secondProduct.price, secondProduct.stock,{from:firstOwner});
                const id2 = productOperation2.logs[0].args.productId;
                const productOperation3 = await marketplaceInstance.addProductToMarket(idMarketplace,thirdProduct.idP, thirdProduct.description, 
                    thirdProduct.price, thirdProduct.stock,{from:firstOwner});
                const id3 = productOperation3.logs[0].args.productId;
                const products = await marketplaceInstance.getProductOfMarketplace(idMarketplace, {from:firstOwner});
                assert.equal(id1, products[0], "Product should be equal");
                assert.equal(id2, products[1], "Product should be equal");
                assert.equal(id3, products[2], "Product should be equal");
            })   
        })

        describe("Pausable Contract", async() =>{
            it("adress can't pause ", async() => {
                await catchRevert(marketplaceInstance.pause({from:firstOwner}));
            })

            it("Owner pause", async() => {
                await marketplaceInstance.pause({from:owner});
                assert.equal(await marketplaceInstance.paused(), true, "Owner can pause");
            })

            it("assert pause working correctly", async() => {
                await decentralizedStoreInstance.addOwner(firstOwner, {from:owner});
                await marketplaceInstance.pause({from:owner});
                await catchRevert(marketplaceInstance.addMarket(firstMarketplace.id, {from:firstOwner}));
            })

            it("unpause test", async() => {
                await marketplaceInstance.pause({from:owner});
                await marketplaceInstance.unpause({from:owner});
                assert.equal(await marketplaceInstance.paused(), false, "Contract can be unpaused by the owener");
            })
        })

        describe("Edge cases", async() =>{
            it("market can only be created by approved owner", async() => {
                await catchRevert(marketplaceInstance.addMarket(secondMarketplace.id, {from:secondOwner}));
            });

            it("Revert if product wrong market", async() => {
                await decentralizedStoreInstance.addOwner(firstOwner, {from:owner});
                await decentralizedStoreInstance.addOwner(secondOwner, {from:owner});
                const transaction = await marketplaceInstance.addMarket(firstMarketplace.id, {from:firstOwner});
                const idMarketplace = transaction.logs[0].args.idMarketplace; 
                const productOperation = await marketplaceInstance.addProductToMarket(idMarketplace,firstProduct.idP, firstProduct.description, 
                    firstProduct.price, firstProduct.stock,{from:firstOwner});
                const productId = productOperation.logs[0].args.productId;
                await catchRevert(marketplaceInstance.deleteProductGivenMarketId(idMarketplace, productId, {from:secondOwner}));
            })

            it("Revert if unauthorized cancellation", async() => {
                await decentralizedStoreInstance.addOwner(firstOwner, {from:owner});
                await decentralizedStoreInstance.addOwner(secondOwner, {from:owner});
                const transaction = await marketplaceInstance.addMarket(firstMarketplace.id, {from:firstOwner});
                const idMarketplace = transaction.logs[0].args.idMarketplace; 
                await catchRevert(marketplaceInstance.deleteMarketplace(idMarketplace,{from:secondOwner}));
            })
        })


    })
});