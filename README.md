# escrow
escrow smart contract with dispute resolution

The Escrow smart contract acts as an escrow account between a buyer and a seller. In case of a dispute a judge can resolve the issue, provided his fees has been paid by both the parties. 
Few assumptions have been made while writing the smart contract, which however do not limit the functionalites of the escrow account and can be easily altered as per the new instructions. 

Below are some assumptions made:
- block.timestamp has been used to perform operation regarding disput time. It has been used assuming the contract can handle a few seconds of variation.
- The amount of fees (judgeFees) a judge can take has been kept fixed in order to ensure that both the parties - buyer and seller pay the same amount to the judge.
- The buyer has been given the role to set the dispute time with the help of the function depositFunds().
- The address of seller is set during funds deposition by the buyer. This has been done to ensure a seller can only withdraw the funds deposited by buyer in a given transaction.
- Dispute can only be raised by the buyer.
- When a dispute occurs, the seller is selected as the winner by default. A better approach to select the winner can be implmented- the buyer can select a random number and generate a hash of the number and can make it public. Only when the buyer gives this random number to the seller, the seller can successfully prove he is the winner of the dispute.


# Function and its role
- constructor() - sets the address and fees of the judge.
- depositFunds() - Allows the buyer to send the money to the escrow smart contract. Dispute time is also establised by the buyer.
- raiseDispute() - Buyer raises the issue through this function. This function can only be called before the dispute time. In order to successfully raise the dispute the buyer needs to pay the fees to the judge.
- payFeesbySeller() - After a dispute has been raised by the buyer, a seller can decide to go to the judge by paying the fees.
- withdrawFund() - The parties can withdraw their funds only after the dispute time has passed and the dispute, if any, has been resolved.
- settleDispute() - Only judge can call this function after the dispute time has passed. This function resolves the dispute between the buyer and the seller.



