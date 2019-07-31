pragma solidity 0.5.10;

import './DecentralizedStore.sol';
import '../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol';
import '../node_modules/openzeppelin-solidity/contracts/lifecycle/Pausable.sol';

/*
* @title Marketplace
*
* @dev @notice This contract allows the users to operate different functions based on their roles
*
*/
contract Marketplace is Ownable, Pausable{

    //DecentralizedStore Instance
    DecentralizedStore public decentralizedStoreInstance;


    /**
    * @dev Constructor
	* @param DecentralizedStoreAddress adress of DecentralizedStore contract
	*/
    constructor(address DecentralizedStoreAddress) public {
        decentralizedStoreInstance = DecentralizedStore(DecentralizedStoreAddress);
    }

    /**
    * @dev Struct
	* @param idMarketplace Market Id
	* @param marketName Market name
	* @param marketOwner address of the market Owner
	* @param credit Market credit
	*/
    struct Market {
        bytes32 idMarketplace;
        string marketName;
        address marketOwner;
        uint credit;
    }

    /**
    * @dev Struct
	* @param productId Product Id
	* @param productName Product name
	* @param description description of the Product
    * @param price price of the Product
	* @param stock stock of the product in a market
    * @param idMarketplace Market Id
	*/
    struct Product {
        bytes32 productId;
        string productName;
        string description;
        uint price;
        uint stock;
        bytes32 idMarketplace;
    }

    //All markets
    bytes32[] private  marketList;

    //Map of Markets with an index
    mapping(bytes32 => uint) private marketMap;

    //Map of markets
    mapping(bytes32 => Market) private marketIdList;

    // Map of owners
    mapping(address =>  bytes32[]) private marketOwnerMapping;

    //Map of products
    mapping(bytes32 => Product) private productMap;

    //Map of procucts by their market
    mapping(bytes32 => bytes32[]) private productsMarketMap;

    //Events
    event LogNewMarket(bytes32 idMarketplace);
    event LogdeleteMarket(bytes32 idMarketplace);
    event LogProductAdded(bytes32 productId);
    event LogProductRemoved (bytes32 productId,bytes32 storefrontId);
    event LogCredit(bytes32 idMarketplace, uint balance);
    event LogSold(bytes32 productId, bytes32 idMarketplace, uint price, uint quantity, uint amount, address customer, uint updatetStock);

    // Modifier to restrict features usage to owners previously approved
    modifier onlyApprovedStoreOwner() {
        require(decentralizedStoreInstance.isOwnerApproved(msg.sender) == true,"Error");
        _;
    }

    // Modifier to restrict features usage to the owner which create the marketplace
    modifier ownerRestricted(bytes32 idMarketplace) {
        require(marketIdList[idMarketplace].marketOwner == msg.sender,"Error");
        _;
    }

    /**
    * @dev @notice create new marketplace
	* @param marketName Name of the marketplace
    * @return idMarketplace
	*/
    function addMarket(string memory marketName) public onlyApprovedStoreOwner whenNotPaused returns(bytes32){
        bytes32 idMarketplace = keccak256(abi.encodePacked(msg.sender, marketName, now));
        Market memory market = Market(idMarketplace, marketName, msg.sender, 0);
        marketIdList[idMarketplace] = market;
        marketOwnerMapping[msg.sender].push(market.idMarketplace);
        marketList.push(market.idMarketplace);
        marketMap[market.idMarketplace] = marketList.length-1;
        emit LogNewMarket(market.idMarketplace);
        return market.idMarketplace;
    }

    /**
    * @dev @notice obtain the id knowning the Owner
	* @param marketOwner address of the market owner
    * @param index Market owner index
    * @return idMarketplace
	*/
    function getIdGivenOwner(address marketOwner, uint index) public view returns(bytes32) {
        return marketOwnerMapping[marketOwner][index];
    }

    /**
    * @dev @notice return the number of markets an owner have
	* @param marketOwner address of the owner
    * @return number of market
	*/
    function getNumberGivenOwner(address marketOwner) public view returns(uint){
        return marketOwnerMapping[marketOwner].length;
    }

    /**
    * @dev @notice Delete a Marketplace, input id
	* @param idMarketplace Id of the market
	*/
    function deleteMarketplace(bytes32 idMarketplace) public onlyApprovedStoreOwner ownerRestricted(idMarketplace) whenNotPaused {
        deleteAllProducts(idMarketplace);
        uint index = marketMap[idMarketplace];
        if (marketList.length > 1) {
            marketList[index] = marketList[marketList.length-1];
        }
        marketList.length--;
        uint length = marketOwnerMapping[msg.sender].length;
        for (uint i = 0; i < length; i++) {
            if(marketOwnerMapping[msg.sender][i] == idMarketplace){
                if(i!=length-1){
                    marketOwnerMapping[msg.sender][i] = marketOwnerMapping[msg.sender][length-1];
                }
                delete marketOwnerMapping[msg.sender][length-1];
                marketOwnerMapping[msg.sender].length--;
                break;
            }
        }
        uint balance = marketIdList[idMarketplace].credit;
		if (balance > 0) {
			msg.sender.transfer(balance);
			marketIdList[idMarketplace].credit = 0;
			emit LogCredit(idMarketplace, balance);
		}
        delete marketIdList[idMarketplace];
        emit LogdeleteMarket(idMarketplace);
    }

    /**
    * @dev @notice return the owner of a known marketblapce identified by an id
	* @param idMarketplace Id of the market
    * @return marketOwner address
	*/
    function getOwnerGivenMarketplaceId(bytes32 idMarketplace) public view returns(address){
        return marketIdList[idMarketplace].marketOwner;
    }

    /**
    * @dev @notice return the name of a known marketplapce identified by an id
	* @param idMarketplace Id of the market
    * @return marketName
	*/
    function getMarketplaceName(bytes32 idMarketplace) public view returns(string memory){
        return marketIdList[idMarketplace].marketName;
    }

    /**
    * @dev @notice return the number of markets created
    * @return number
	*/
    function getMarketNumber() public view returns (uint) {
		return marketList.length;
	}

    /**
    * @dev @notice create a new product in the marketplace identified by the id
    * @param idMarketplace Id of the market
    * @param productName Name of the product
    * @param description Description of the product
    * @param price price of the product
    * @param stock stock of the product
    * @return productId
	*/
    function addProductToMarket(bytes32 idMarketplace, string memory productName, string memory description, uint price, uint stock)
    public onlyApprovedStoreOwner ownerRestricted(idMarketplace) whenNotPaused returns(bytes32){
        bytes32 productId = keccak256(abi.encodePacked(idMarketplace, productName, now));
        Product memory product = Product(productId, productName, description, price, stock, idMarketplace);
        productMap[productId] = product;
        productsMarketMap[idMarketplace].push(product.productId);
        emit LogProductAdded(product.productId);
        return product.productId;
    }

    /**
    * @dev @notice return the products in a marketplace
    * @param idMarketplace Id of the market
    * @return list of id
	*/
    function getProductOfMarketplace(bytes32 idMarketplace) public view returns(bytes32[] memory){
        return productsMarketMap[idMarketplace];
    }

    /**
    * @dev @notice return the id of the products of a marketplace
    * @param idMarketplace Id of the market
    * @param index product in a market
    * @return productid
	*/
    function getProductOfMarket(bytes32 idMarketplace, uint index) public view returns(bytes32){
        return productsMarketMap[idMarketplace][index];
    }

    /**
    * @dev @notice return the numer of products
    * @param idMarketplace Id
    * @return number
	*/
    function getProductNumberGivenMarketId(bytes32 idMarketplace) public view returns(uint){
        return productsMarketMap[idMarketplace].length;
    }

    /**
    * @dev @notice return all the informations of a product knowing its id
    * @param productId id of the product
    * @return productData
	*/
    function getProductData(bytes32 productId) public view returns (string memory, string memory, uint, uint, bytes32){
        return (productMap[productId].productName, productMap[productId].description, productMap[productId].price,
        productMap[productId].stock, productMap[productId].idMarketplace);
    }

    /**
    * @dev @notice empty the marketplace
    * @param idMarketplace Id
	*/
    function deleteAllProducts(bytes32 idMarketplace) public onlyApprovedStoreOwner ownerRestricted(idMarketplace) whenNotPaused{
        for (uint i = 0; i < productsMarketMap[idMarketplace].length; i++) {
                bytes32 productId = productsMarketMap[idMarketplace][i];
                delete productsMarketMap[idMarketplace][i];
                delete productMap[productId];
        }
    }

    /**
    * @dev @notice delete a product
    * @param idMarketplace Id of the market
    * @param productId Id of the Product
	*/
    function deleteProductGivenMarketId(bytes32 idMarketplace, bytes32 productId) public onlyApprovedStoreOwner ownerRestricted(idMarketplace) whenNotPaused{
        bytes32[] memory productIds = productsMarketMap[idMarketplace];
		uint productsCount = productIds.length;
        for(uint i = 0; i < productsCount; i++) {
			if (productIds[i] == productId) {
				productIds[i] = productIds[productsCount-1];
				delete productIds[productsCount-1];
                productsMarketMap[idMarketplace] = productIds;
				delete productMap[productId];
				emit LogProductRemoved(productId, idMarketplace);
				break;
			}
		}
    }

    /**
    * @dev @notice buy a product in a marketplace
    * @param idMarketplace Id of the market
    * @param productId Id of the Product
    * @param stock how much to buy
    * @return true if success
	*/
    function buy(bytes32 idMarketplace, bytes32 productId, uint stock) public payable whenNotPaused returns(bool){
        Product storage productBuy = productMap[productId];
        Market storage market = marketIdList[idMarketplace];
        require(market.marketOwner != msg.sender,"Error");
        uint amount = productBuy.price*stock;
        require(msg.value >= amount,"Error");
        require (stock <= productBuy.stock,"Error");
        uint remainingValue = msg.value-amount;
        msg.sender.transfer(remainingValue);
        productBuy.stock -= stock;
        market.credit += amount;
        emit LogSold(productId, idMarketplace, productBuy.price, stock, amount, msg.sender, productBuy.stock);
		return true;
    }

}