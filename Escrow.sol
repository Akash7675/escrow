pragma solidity ^0.5.7;

contract Escrow {
    
    address payable public judge;
    uint256 public judgeFees;
    uint256 public judgeFeesPaid;
    uint256 public disputeTime;
    address payable buyer;
    address payable seller;
    bool public isDisputed;
    bool public buyerPaidFees;
    bool public sellerPaidFees;
    mapping (address => uint256) balance;
    uint256 public buyerBalance;
    

    modifier onlyBuyer() {
        require(msg.sender == buyer, 'Only buyer can call this method');
        _;
    }
    event IsDisputed(bool indexed isDisputed);
    
    constructor(uint256 _judgeFees) public {
        judge = msg.sender;
        judgeFees = _judgeFees;
    }
    
    
    function depositFunds(address payable _seller, uint256 _setSeconds) external payable {
        disputeTime = now + _setSeconds * 1 seconds;
        buyer = msg.sender;
        seller = _seller;  
    }
    
    function viewFunds() external view returns (uint256) {
        return address(this).balance;
    }
    
    function raiseDispute() onlyBuyer external payable {
        require(now < disputeTime,'Time exceeded disputeTime');
        require(msg.value == judgeFees,'Paid fees is not equal to judgeFees');
        judgeFeesPaid += msg.value;
        Balance[judge] = judgeFeesPaid;
        buyerPaidFees = true;
        isDisputed = true;
        emit IsDisputed(isDisputed);
    }
    
    function payFeesBySeller() external payable {
        require(now < disputeTime, 'Time exceeded disputeTime');
        require(isDisputed,'No need to pay fees, because there is no dispute');
        require(msg.value == judgeFees, 'Paid fees is not equal to judgeFees');
        judgeFeesPaid += msg.value;
        Balance[judge] = judgeFeesPaid;
        sellerPaidFees = true;
    }
    
    function withdrawFund() external {
        require(now > disputeTime,'wait for dispute time to complete');
        require(!isDisputed,'It is disputed, first resolve the dispute');
        if(msg.sender == seller) {
            Balance[msg.sender] = address(this).balance;
            uint256 disperseAmount = Balance[msg.sender];
            Balance[msg.sender] = 0;
            (bool success, ) = msg.sender.call.value(disperseAmount)("");
            require(success);
        }
        else if(msg.sender == judge) {
            uint256 disperseAmount = Balance[msg.sender];
            Balance[msg.sender] = 0;
            (bool success, ) = msg.sender.call.value(disperseAmount)("");
            require(success);
        }
        else if(msg.sender == buyer) {
            uint256 disperseAmount = Balance[msg.sender];
            Balance[msg.sender] = 0;
            (bool success, ) = msg.sender.call.value(disperseAmount)("");
            require(success);
        }
        else {
            revert('Invalid address');
        }
            
        }
        
    function getBuyerBalance() external  {
        buyerBalance = Balance[buyer];
        }
    
    function settleDispute() external {

        require(now > disputeTime,'Wait for dispute time to complete');
        require(msg.sender == judge,'Only Judge can resolve dispute');
        
        if(!sellerPaidFees && buyerPaidFees) {
            Balance[buyer] =  address(this).balance;
            Balance[judge] -= judgeFeesPaid;
            isDisputed = false;
            emit IsDisputed(isDisputed);
        }
        //judge settles in favor of seller in this case
        else if(buyerPaidFees && sellerPaidFees) {
            Balance[seller] = address(this).balance;
            isDisputed = false;
            emit IsDisputed(isDisputed);
        }
        else {
            revert('No judge fees paid by buyer and seller, hence no dispute resolution');
        }
    }
    
}
