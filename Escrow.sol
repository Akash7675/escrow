pragma solidity ^0.5.7;

contract Escrow {
    
/**
 * @title Escrow
 * @dev 
 * judge - stores the address of judge
 * judgeFees - stores the judge fees set by the judge
 * judgeFeesPaid - stores the current fees sent by the buyer and seller
 * disputeTime - duration before which a dispute, if any should be raised by the buyer 
 * buyer - stores address of buyer
 * seller - stores address of seller
 * isDisputed - set to true if a dispute has been raised and false once the dispute has been resolved
 * buyerPaidFees - true if buyer has paid the judge fee
 * sellerPaidFees - true if seller has paid the judge fee
 * amountDeposited - stores the amount deposited by buyer for a given transaction
 * balance - a mapping to keep track of the balance of  individuals
 
 */

    address payable public judge;
    uint256 judgeFees;
    uint256 judgeFeesPaid;
    uint256 disputeTime;
    address payable public buyer;
    address payable public seller;
    bool public isDisputed;
    bool buyerPaidFees;
    bool sellerPaidFees;
    uint256 amountDeposited;
    mapping (address => uint256) balance;
    
    

    modifier onlyBuyer() {
        require(msg.sender == buyer, 'Only buyer can call this method');
        _;
    }


    // Event to log the status of dispute
    event IsDisputed(bool indexed isDisputed);

    // Event to log the dispute time
    event DisputeTime(uint256 indexed disputeTime);
    
    constructor(uint256 _judgeFees) public {
        judge = msg.sender;
        judgeFees = _judgeFees;
    }
    
    // To send the money to the escrow smart contract and set the dispute time
    function depositFunds(address payable _seller, uint256 _setSeconds) external payable {
        disputeTime = now + _setSeconds * 1 seconds;
        buyer = msg.sender;
        seller = _seller;
        amountDeposited = msg.value;
        emit DisputeTime(disputeTime);  
    }
    
    function viewFundsInEscrow() external view returns (uint256) {
        return address(this).balance;
    }

    // Buyer raises the issue through this function. 
    function raiseDispute() onlyBuyer external payable {
        require(now < disputeTime, 'Time exceeded disputeTime');
        require(msg.value == judgeFees, 'Paid fees is not equal to judgeFees');
        judgeFeesPaid = msg.value;
        balance[judge] = judgeFeesPaid;
        buyerPaidFees = true;
        isDisputed = true;
        emit IsDisputed(isDisputed);
    }

    // Seller pays the judge fees
    function payFeesBySeller() external payable {
        require(now < disputeTime, 'Time exceeded disputeTime');
        require(isDisputed, 'No need to pay fees, because there is no dispute');
        require(msg.value == judgeFees, 'Paid fees is not equal to judgeFees');
        judgeFeesPaid += msg.value;
        balance[judge] = judgeFeesPaid;
        sellerPaidFees = true;
    }
    
    // Individuals can withdraw the fund after the dipute if any, has been resolved
    function withdrawFund() external {
        require(now > disputeTime, 'Wait for dispute time to complete');
        require(!isDisputed, 'It is disputed, first resolve the dispute');
        if(msg.sender == seller) {
            balance[msg.sender] = amountDeposited;
            uint256 disperseAmount = balance[msg.sender];
            balance[msg.sender] = 0;
            (bool success, ) = msg.sender.call.value(disperseAmount)("");
            require(success);
        }
        else if(msg.sender == judge) {
            uint256 disperseAmount = balance[msg.sender];
            balance[msg.sender] = 0;
            (bool success, ) = msg.sender.call.value(disperseAmount)("");
            require(success);
        }
        else if(msg.sender == buyer) {
            uint256 disperseAmount = balance[msg.sender];
            balance[msg.sender] = 0;
            (bool success, ) = msg.sender.call.value(disperseAmount)("");
            require(success);
        }
        else {
            revert('Invalid address');
        }
            
    }
        
    // Judge settles the dispute after dispute time has passed
    function settleDispute() external {

        require(now > disputeTime,'Wait for dispute time to complete');
        require(msg.sender == judge,'Only Judge can resolve dispute');

        if(!sellerPaidFees && buyerPaidFees) {
            balance[buyer] =  amountDeposited + judgeFeesPaid;
            balance[judge] -= judgeFeesPaid;
            isDisputed = false;
            sellerPaidFees = false;
            buyerPaidFees = false;
            emit IsDisputed(isDisputed);
        }
        //judge settles in favor of seller in this case
        else if(buyerPaidFees && sellerPaidFees) {
            balance[seller] = amountDeposited;
            isDisputed = false;
            sellerPaidFees = false;
            buyerPaidFees = false;
            emit IsDisputed(isDisputed);
        }
        else {
            revert('No judge fees paid by buyer and seller hence no dispute resolution or dispute already resolved');
        }
    }
    
}
