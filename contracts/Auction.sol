
pragma solidity >=0.6.0 <0.8.0;
import './SafeMath.sol';



contract Auction {
    using SafeMath for uint256;
    
 
    // State variables
    address payable public _auctionOwner;  //person who deploys the contract A.K.A Auction Owner
    uint256 public lastHigh; // new bids should be higher than this
    uint256 public completeAt; //timestamp when the bid ends
    address public winner; //the person who wins the bid
    string public title;
    string public description;
    uint256 public auctionDeadline; //timestamp when the auction expires
   
    mapping (address => uint) public bids; //just to keep track of contributions
    bool stillRaising;
    bool expired;

    // Event that will be emitted whenever funding will be received
    event bidReceived(address contributor, uint amount);
    // Event that will be emitted whenever the project starter has received the funds
    event auctionerPaid(uint256 _totalPaid);


//checks that the caller is a creator
    modifier isCreator() {
        require(msg.sender == _auctionOwner,"yikes, you didn't create this auction");
        _;
    }
    
    //makes sure the cumulative bid by trhe sender is higher than the current highest bid
    modifier isHigher(uint256 amountSent){
        require (bids[msg.sender]+amountSent>lastHigh,"your bid should be higher than the current bid");
        _;
    }
    
        //requires that the auction can still receive bids
    modifier stillAcceptingBids{
       require(stillRaising=true);
       
        require (block.timestamp<=auctionDeadline);
        _;
    }

//make sure the auction has either expired or has been ended by the auction owner
    modifier auctionFinished{
        
     require (stillRaising==false);
   _;
    }

    constructor
    (
        string memory auctionTitle,
        string memory auctionDesc,
        uint256 _auctionDeadline,
        uint256 minStartingAmount
    ) public {
        _auctionOwner = msg.sender;
        title = auctionTitle;
        description = auctionDesc; 
        lastHigh = minStartingAmount; //maybe 0.1bnb
          stillRaising=true;
        auctionDeadline=_auctionDeadline; //in unix timestamp
    
    }
event currentWinners(address _winner,uint256 _amount);

//allows users to place a bid so far the total ampount of bids(plus this one) is lesser than the current highest bid
//it performs some arithmetic operations so , medium gas usage is inevitable
    function contribute() external stillAcceptingBids isHigher(msg.value) payable returns(bool){
        require(msg.sender != _auctionOwner);
        bids[msg.sender] = bids[msg.sender].add(msg.value);
        lastHigh=bids[msg.sender];
        winner=msg.sender;
        emit bidReceived(msg.sender, msg.value);
        return true;
    }
    
    function checkHighestBid() public view returns(uint256){
        return lastHigh;
    }

//uses a minimal amount of gas
 //to save gas it changes the state of two boolean values depending on different situations
    function acceptHighestBid() public isCreator{
        if ((block.timestamp<=auctionDeadline)) {
            expired=true;
            payOut();
        completeAt = block.timestamp;
    }
    else{
         expired=true;
        payOut();
    }}

    // Function to give the received funds to project starter.
   
    function payOut() internal returns (bool) {
        uint256 highestRaised = lastHigh;
        _auctionOwner.transfer(highestRaised);
        stillRaising=false;
        expired=true;
            emit auctionerPaid(lastHigh);
            return true;

    }

//uses a little amount of ga since it only refunds eth(default 2300 gas sent with txn)
    function getRefund() public auctionFinished returns (bool) {
        require(bids[msg.sender] > 0);

        uint256 amountToRefund = bids[msg.sender];
        bids[msg.sender] = 0;
        msg.sender.transfer(amountToRefund);
        return true;
    }
    
    //normally should be a view function but has to change state because of event emitted
    function getWinningBid() public returns(address,uint256){
        emit currentWinners(winner,lastHigh);
        return (winner,lastHigh);
    }

  
} 
