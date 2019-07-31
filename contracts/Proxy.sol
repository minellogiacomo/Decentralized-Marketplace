pragma solidity 0.5.10;

import "../contracts/DecentralizedStore.sol";

contract Proxy {

    DecentralizedStore public _decentralizedStore;

    constructor(DecentralizedStore decentralizedStore) public { _decentralizedStore = decentralizedStore; }

    function() external payable {}

    function isAdministrator(address administrator) public returns(bool){
        (bool success,) = address(_decentralizedStore).call(abi.encodeWithSignature("isAdministrator(address)",administrator));
       return success;
    }

    function validateOwner(address owner) public returns(bool){
        (bool success,) = address(_decentralizedStore).call(abi.encodeWithSignature("validateOwner(address)",owner));
       return success;
    }
}
