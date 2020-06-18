pragma solidity ^0.5.0;


contract copyright{
    
    
    uint value;
    address[] buyers;
    address payable firstOwnerCandidate;
    address payable firstOwner;
    uint desiredAmount = 50;
    
    
    struct Proposal{
        uint id;
        uint voteCount;
    }
    
    struct ObjectionProposal{
        string reason;
        address payable addressOfObjector;
        uint voteCount;
        uint positiveVotes;
    }
    
    struct Voter{
        bool firstVoted;
        bool secondVoted;
        uint vote;
    }
    
    /*struct Owners{
        address ownerAddress;
        //string status;
    }*/
    
    modifier onlyFirstOwner() {
        require(
            msg.sender == firstOwner,
            "You are not allowed to do this"
        );
        _;
    }
    
    
    
    Proposal proposal;
    uint firstVoteCount = 0;
    uint calculatedCost;
    bool canFirstVote = false;
    bool canSecondVote = false;
    uint sessionTime =60;
    uint createTime =0;
    uint voteLimit =100;
    
    
    
   constructor(address payable owner,uint id, uint itemValue) public payable  {
        value = itemValue * 1e18;
        proposal.id = id;
        firstOwnerCandidate = owner;
        
    }
    
    
    function() external payable{}
    
    
    ObjectionProposal objection;
    
    mapping(address => Voter) voters;
    
    function giveFirstVote(uint vote, string memory reason) public {
        Voter storage sender = voters[msg.sender];
        
        require(
            (block.timestamp - createTime) < sessionTime,
            "Time is over!"
        );
        
        require(
           canFirstVote,
           "First voting is not available!" 
        );
        
        require(
           !sender.firstVoted,
           "Already voted!" 
        );
       
        if(vote == 0){
           sender.firstVoted = true;
           canFirstVote=false;
           canSecondVote = true;
           createTime = block.timestamp;
           
           objection.reason = reason; 
           objection.addressOfObjector = msg.sender;
           firstVoteCount++;
        }
        else if(vote == 1){
           sender.firstVoted = true;
           proposal.voteCount++;
           firstVoteCount++;
        }
        else{
           revert("You can only vote 0 and 1!");
        }
        
    }
    
    function calculateCost()private returns(uint){
        return 1;
    }
    
    //
    //returns the calculated cost for copyright
    //
    function getCost()public returns(uint) {
        require(
            msg.sender == firstOwnerCandidate,
            "You are not allowed to do this"
        );
        calculatedCost = calculateCost();
        return calculatedCost;
    }
    
    //
    //owner calls this function to pay money
    //
    function payCost()public payable {
        require(
            msg.sender == firstOwnerCandidate,
            "You are not allowed to do this"
        );
        address(this).transfer(msg.value);
        createTime = block.timestamp;
        canFirstVote = true;
    }
   
   function giveSecondVote(uint vote) public {
       Voter storage sender = voters[msg.sender];
       
       require(
           canSecondVote,
           "Second voting is not available!" 
       );
       
       require(
            (block.timestamp - createTime) < sessionTime,
            "Time is over!"
       );
       
       require(
           sender.firstVoted,
           "Only voters that voted on first session are allowed!" 
       );
       
       require(
           !sender.secondVoted,
           "Already voted!" 
       );
       
       require(
           msg.sender != objection.addressOfObjector,
           "You can not vote your own objection!" 
       );
       
       if(vote == 0){
           sender.secondVoted = true;
           objection.voteCount++;
           
       }
       else if(vote == 1){
           sender.secondVoted = true;
           objection.voteCount++;
           objection.positiveVotes++;
           
       }
       else{
           revert("You can only vote 0 and 1!");
       }
   }
   
   function getVotingResult() public returns(uint){
       
       require(
            (block.timestamp - createTime) > sessionTime,
            "Voting session is not ended!"
       );
       if(proposal.voteCount == firstVoteCount){
           return 1;
       }
       else if((objection.positiveVotes*2) >= objection.voteCount){
           
           address(objection.addressOfObjector).transfer((address(this).balance) *desiredAmount /100);
           return 0;
       }else{
           firstOwner = firstOwnerCandidate;
           return 1;
       }
   }
   
    //
    //returns the price of copyright
    //
   function getPrice()public view returns(uint){
       return value/1e18;
   }
   
    //
    //returns the balance of contract
    //
   function getContractBalance() public view returns(uint){
        return address(this).balance;
    }
    
    //
    //returns block time
    //
    function getBlockTime() public view returns(uint){
        return block.timestamp;
    }
   
    //
    //buying section
    //
   function buyCopyright() public payable {
       require(msg.value>=value, "you didn't pay enough!!");
       
       address(this).transfer(msg.value);
       buyers.push(msg.sender);
   }
   
    //
    //sending ethers from contract to owner
    //
   function withdraw() public onlyFirstOwner payable{
        address(firstOwner).transfer(address(this).balance);
    }
    
    //
    //returns the addresses of buyers
    //
    function getListOfBuyers()public view returns(address[] memory){
        return buyers;
    }
   
}

