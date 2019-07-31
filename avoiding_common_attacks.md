https://consensys.github.io/smart-contract-best-practices/
https://consensys.github.io/smart-contract-best-practices/recommendations/
https://sunnya97.gitbooks.io/a-beginner-s-guide-to-ethereum-and-dapp-developme/smart-contract-best-practices.html
http://hackingdistributed.com/2017/08/28/submarine-sends/

### Use caution when making external calls ✔️ 
Calls to untrusted contracts can introduce several unexpected risks or errors. External calls may execute malicious code in that contract or any other contract that it depends upon. As such, every external call should be treated as a potential security risk. When it is not possible, or undesirable to remove external calls, use the recommendations in the rest of this section to minimize the danger."

Only betwwen deployed contract, so they are trusted and immutable (no fuction to change the contract adress is in place). 

### Mark untrusted contracts 
"When interacting with external contracts, name your variables, methods, and contract interfaces in a way that makes it clear that interacting with them is potentially unsafe. This applies to your own functions that call external contracts."

Not applicable since is not necessary because the contracts are trusted as long as you trust the deploy. 

### Avoid state changes after external calls ✔️ 
"Whether using raw calls (of the form someAddress.call()) or contract calls (of the form ExternalContract.someMethod()), assume that malicious code might execute. Even if ExternalContract is not malicious, malicious code can be executed by any contracts it calls.

One particular danger is malicious code may hijack the control flow, leading to vulnerabilities due to reentrancy. (See Reentrancy for a fuller discussion of this problem).

If you are making a call to an untrusted external contract, avoid state changes after the call. This pattern is also sometimes known as the checks-effects-interactions pattern."

The contract change state after external calls. However, the only external calls implemented are necessary and trusted.

### Be aware of the tradeoffs between send(), transfer(), and call.value()() ✔️ 
"When sending ether be aware of the relative tradeoffs between the use of someAddress.send(), someAddress.transfer(), and someAddress.call.value()(). 

-someAddress.send()and someAddress.transfer() are considered safe against reentrancy. While these methods still trigger code execution, the called contract is only given a stipend of 2,300 gas which is currently only enough to log an event.

-x.transfer(y) is equivalent to require(x.send(y));, it will automatically revert if the send fails.

-someAddress.call.value(y)() will send the provided ether and trigger code execution. The executed code is given all available gas for execution making this type of value transfer unsafe against reentrancy.

Using send() or transfer() will prevent reentrancy but it does so at the cost of being incompatible with any contract whose fallback function requires more than 2,300 gas. It is also possible to use someAddress.call.value(ethAmount).gas(gasAmount)() to forward a custom amount of gas. One pattern that attempts to balance this trade-off is to implement both a push and pull mechanism, using send() or transfer() for the push component and call.value()() for the pull component.

It is worth pointing out that exclusive use of send() or transfer() for value transfers does not itself make a contract safe against reentrancy but only makes those specific value transfers safe against reentrancy."

Since it's applicable I used transfer(), don't have the requirement of exceding gas limit.  

### Handle errors in external calls ✔️ 
"Solidity offers low-level call methods that work on raw addresses: address.call(), address.callcode(), address.delegatecall(), and address.send(). These low-level methods never throw an exception, but will return false if the call encounters an exception. On the other hand, contract calls (e.g., ExternalContract.doSomething()) will automatically propagate a throw (for example, ExternalContract.doSomething() will also throw if doSomething() throws).

If you choose to use the low-level call methods, make sure to handle the possibility that the call will fail, by checking the return value."

Low levels calls used to communiate safely.

### Favor pull over push for external calls ✔️ 

"External calls can fail accidentally or deliberately. To minimize the damage caused by such failures, it is often better to isolate each external call into its own transaction that can be initiated by the recipient of the call. This is especially relevant for payments, where it is better to let users withdraw funds rather than push funds to them automatically. (This also reduces the chance of problems with the gas limit.) Avoid combining multiple transfer() calls in a single transaction."

Principle respected.

### Don't delegatecall to untrusted code ✔️ 

"The delegatecall function is used to call functions from other contracts as if they belong to the caller contract. Thus the callee may change the state of the calling address. This may be insecure. An example below shows how using delegatecall can lead to the destruction of the contract and loss of its balance."

Case not applicable. 

### Remember that on-chain data is public ✔️ 

"Many applications require submitted data to be private up until some point in time in order to work. Games (eg. on-chain rock-paper-scissors) and auction mechanisms (eg. sealed-bid Vickrey auctions) are two major categories of examples. If you are building an application where privacy is an issue, make sure you avoid requiring users to publish information too early. The best strategy is to use commitment schemes with separate phases: first commit using the hash of the values and in a later phase revealing the values."

All registered public information are non sensitive. 

### Beware of the possibility that some participants may "drop offline" and not return ✔️ 

"Do not make refund or claim processes dependent on a specific party performing a particular action with no other way of getting the funds out. For example, in a rock-paper-scissors game, one common mistake is to not make a payout until both players submit their moves; however, a malicious player can "grief" the other by simply never submitting their move - in fact, if a player sees the other player's revealed move and determines that they lost, they have no reason to submit their own move at all. This issue may also arise in the context of state channel settlement. When such situations are an issue, (1) provide a way of circumventing non-participating participants, perhaps through a time limit, and (2) consider adding an additional economic incentive for participants to submit information in all of the situations in which they are supposed to do so."

As per the architecture design of the dapp this doesn't represent a problem. 

### Beware of negation of the most negative signed integer
N/A

### Use assert(), require(), revert() properly ✔️ 

### Use modifiers only for assertions ✔️

### Beware rounding with integer division ✔️

### Explicitly mark payable functions and state variables ✔️
Done.

### Explicitly mark visibility in functions and state variables ✔️
Done.

### Lock pragmas to specific compiler version ✔️
`solidity 0.5.10` last version avaiable used

### Be aware that 'Built-ins' can be shadowed ✔️
Well aware, this caused me a bug in the early stage of development of the contracts.

## Deprecated/historical recommendations ✔️
- `keccak256`

## Beware division by zero ✔️

## Use events to monitor contract activity ✔️
Events used to log data in the blockchain.  

## Differentiate functions and events ✔️
Naming convenction used to distinguish them even if not strictly needed.  

## Avoid using tx.origin ✔️
Not used. 

## Timestamp Dependence ✔️
Timestamps used for not-security-related ids. 

## Multiple Inheritance Caution ✔️
Inheritance securitly used with openzeppelin.
