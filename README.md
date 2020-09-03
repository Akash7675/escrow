# escrow
escrow smart contract with dispute resolution

The Escrow smart contract acts as an escrow account between a buyer and a seller. In case of a dispute a judge can resolve the issue, provided his fees has been paid by both the parties. 
Few assumptions have been made while writing the smart contract, which however do not limit the functionalites of the escrow account and can be easily altered as per the new instructions. 

Below are some assumptions made:
- block.timestamp has been used to perform operation regarding disput time. It has been used assuming the contract can handle a few seconds of variation.
-
