https://consensys.github.io/smart-contract-best-practices/

## External Calls
Only betwwen deployed contract, so they are trusted and immutable. 

## Send() vs transfer()
`transfer()` preferred.

## Mark payable functions
Done.

## Mark visibility in functions 
Done.

## Lock compiler version
`solidity 0.5.10`

## Use new constructs 
- `keccak256`

## events
Events used to log data in the blockchain. 

## Functions and events
Naming convenction used to distinguish them.  

## Avoid tx origin
Not used. 

## Timestamp
Timestamps used for not-security-related ids. 

## Multiple Inheritance
Inheritance securitly used with openzeppelin.