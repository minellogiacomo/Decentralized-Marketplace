pragma solidity 0.5.10;

import '../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol';
import '../node_modules/openzeppelin-solidity/contracts/lifecycle/Pausable.sol';

/*
* @title DecentralizedStore
*
* @dev @notice contract for role administration
*
*/
contract DecentralizedStore is Ownable, Pausable{


    address[] private pendingOwner;
    address[] private approvedOwner;
    mapping(address => uint) private approvedOwnerId;
    mapping(address => uint) private pendingOwnerid;
    mapping(address => bool) private administrators;
    mapping(address => bool) private approvedOwnersMap;
    event LogOwnerApproved(address ownerAdress);
    event LogOwnerRemoved(address ownerAdress);
    event LogOwnerAdded(address ownerAdress);
    event LogAdminAdded(address administratorAddress);
    event LogAdminRemoved(address administratorAddress);

    // Modifier for administrative features
    modifier onlyAdmin(){
        require(administrators[msg.sender] == true,"Error");
        _;
    }

    /**
    * @dev @notice deployer role update (constructor)
	*/
    constructor() public{
        administrators[msg.sender] = true;
    }

   /**
    * @dev @notice Create a new admin
	* @param administratorAddress address
	*/
    function createNewAdministrator(address administratorAddress) public onlyAdmin whenNotPaused{
        administrators[administratorAddress] = true;
        emit LogAdminAdded(administratorAddress);
    }

    /**
    * @dev @notice delete admin (revoke privilege)
	* @param administratorAddress adress
	*/
    function deleteAdministrator(address administratorAddress) public onlyOwner whenNotPaused{
        require(administrators[administratorAddress] == true,"Error");
        administrators[administratorAddress] = false;
        emit LogAdminRemoved(administratorAddress);
    }

    /**
    * @dev @notice is an administator of the dapp?
	* @param administratorAddress adress
    * @return true if true
	*/
    function isAdministrator(address administratorAddress) public view returns(bool){
        return administrators[administratorAddress];
    }

    /**
    * @dev @notice create new owner of a store
    * @param ownerAdress address
	*/
    function addOwner(address ownerAdress) public onlyAdmin whenNotPaused{
        approvedOwnersMap[ownerAdress] = true;
        removeOwnerRequest(ownerAdress);
        approvedOwner.push(ownerAdress);
        approvedOwnerId[ownerAdress] = approvedOwner.length-1;
        emit LogOwnerApproved(ownerAdress);
    }

    /**
    * @dev @notice how many owners
    * @return number
	*/
    function getOwnersNumber() public view returns(uint){
        return pendingOwner.length;
    }

    /**
    * @dev @notice is the owner aproved?
    * @param ownerAdress address
    * @return true if true
	*/
    function isOwnerApproved(address ownerAdress) public view returns(bool){
        return approvedOwnersMap[ownerAdress];
    }

    /**
    * @dev @notice Function is to add store owner
    * @return true on success
	*/
    function createOwner() public whenNotPaused returns(bool){
        require(approvedOwnersMap[msg.sender] == false,"Error");
        pendingOwner.push(msg.sender);
        pendingOwnerid[msg.sender] = pendingOwner.length-1;
        emit LogOwnerAdded(msg.sender);
        return true;
    }

    /**
    * @dev @notice remove pending request from map
    * @param ownerAdress address
	*/
    function removeOwnerRequest(address ownerAdress) private onlyAdmin whenNotPaused {
        uint i = pendingOwnerid[ownerAdress];
        if (pendingOwner.length > 1) {
            pendingOwner[i] = pendingOwner[pendingOwner.length-1];
        }
        pendingOwner.length--;
    }
}