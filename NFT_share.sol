//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//minting nft
contract NFT is ERC721{
    address payable public  owner;
    uint public tokenId;
    constructor(
        string memory name,
        string memory symbol
    )
    ERC721(name,symbol){
        owner=payable(msg.sender);
    }

    //have to make tokenId public
    function mint(address to, uint _tokenId) external{
        tokenId=_tokenId;
        _mint(to,tokenId);
        
    }
}

//sharing nft
contract Share{
    uint public OwnerShare;
    uint public remainingShare;
   
  
    address public owner;
    mapping(address => uint) shareHoldersMapping;
    address[] shareHolders;
    uint public minShare;
    constructor(uint _ownershare,uint _minShare){
        owner=msg.sender;
        require(msg.sender==owner);
        require(_ownershare>=50);
        OwnerShare=_ownershare;
        minShare=_minShare;
        remainingShare=100-OwnerShare;
    }

}
    




contract Auction is ERC721,Share{
    bool public started;
    bool public ended;
    uint public endAt;
    uint256 public currentPrice;
    //uint public tokenId;
    uint public share;
    address[] bidders;
    mapping(address => uint[]) public bids;

    event Start();
    event End(address highestBidder, uint highestBid);
    event Bid(address indexed sender, uint amount);
    event Withdraw(address indexed bidder, uint amount);



function start() external {
        require(!started, "Already started!");
        require(msg.sender == owner, "You did not start the auction!");
       
        Transfer(msg.sender, address(this), tokenId);
        started = true;
        endAt = block.timestamp + 1 day;
        emit Start();
    

        bidders.push(msg.sender);
        bids[msg.sender] = [share,msg.value];
        payable address(this).transfer(msg.value);
        
        emit Bid(highestBidder, highestBid);
}

        function end() external {
        require(started, "You need to start first!");
        require(block.timestamp >= endAt, "Auction is still ongoing!");
        require(!ended, "Auction already ended!");

        int highestBidder,maxRatio,biddersCount;
        biddersCount = bidders.length;
        while(remainingShare > 0 && bidders.length > 0){
            maxRatio = 0;
            highestBidder = -1;
            for(uint j=0;j<bidders.length;j++){
                if(maxRatio < bids[bidders[j]][1] / bids[bidders[j]][0])
                {
                    highestBidder=j;
                    maxRatio=bids[bidders[j]][1] / bids[bidders[j]][0];
                }
            }
            if(highestBidder!=-1){
                withdraw(bidders[highestBidder],bids[bidders[highestBidder]][0],bids[bidders[highestBidder]][1]);
                remainingShare -= bids[bidders[highestBidder]][0];
                biddersCount-=1;
                bids[bidders[highestBidder]] = [];
                bidders[highestBidder]=0;
            }
        }

        
       


    function withdraw(address bidder,uint share,uint price) external payable returns(uint) {

        require(sent, "Could not withdraw");
        payable(owner.transfer(price));
        shareHoldersMapping[bidder] = share;
        shareHolders.push(bidder);
        emit Withdraw(msg.sender, bal);
        return withdraw;
    }

    function refund () public {
            for(uint i=0;i<bidders.length;i++){
                uint bal=bids[bidders[i]][1];
                payable bidders[i].transfer(bal);
            }
        }
        ended = true;
        emit End(highestBidder, highestBid);
    }






//selling nft

//event Sent(address indexed payee, uint256 amount, uint256 balance);
//event Received(address indexed payer, uint tokenId, uint256 amount, uint256 balance);

constructor(address _nftAddress, uint256 _currentPrice) public  {
require(_nftAddress != address(0) && _nftAddress != address(this));
require(_currentPrice > 0);
nftAddress = ERC721(_nftAddress);
currentPrice = _currentPrice;
}

function purchaseNft() public payable {
require(msg.sender != address(0) && msg.sender != address(this));
require(msg.value >= currentPrice);
require(tokenExists[tokenId]);
address tokenOwner = nftAddress.ownerOf(tokenId);
nftAddress.safeTransferFrom(tokenOwner, msg.sender, tokenId);
emit Received(msg.sender, tokenId, msg.value, address(this).balance);
}

function sendTo() public {
    require(msg.sender==owner);

require(currentPrice > 0 && currentPrice <= address(this).balance);
owner.transfer((currentPrice/100)*(OwnerShare));
for(uint i=0;i<shareHolders.length;i++){
    payable (shareHolders[i]).transfer((currentPrice/100)*(shareHoldersMapping[shareHolders[i]]));
}
// emit Sent(_payee, _amount, address(this).balance);

}

function reset(uint256 _currentPrice) public{
    require(msg.sender==owner);
require(_currentPrice > 0);
currentPrice = _currentPrice;
for(uint i=0;i<shareHolders.length;i++){
    delete shareHoldersMapping[shareHolders[i]];
}
delete shareHolders;

}
}
