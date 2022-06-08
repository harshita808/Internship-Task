
//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//minting nft
contract NFT is ERC721{
address payable public owner;
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
bool public started;
bool public ended;
uint public endAt;
uint256 public currentPrice;
uint public tokenId;
uint public share;
address[] bidders;
mapping(address => uint[]) public bids;

event Start();
event End(address highestBidder, uint highestBid);
event Bid(address indexed sender, uint amount);
event Withdraw(address indexed bidder, uint amount);



function start() external payable {
require(!started, "Already started!");
require(msg.sender == owner, "You did not start the auction!");
// transfer function is not implemented.
// Transfer(msg.sender, address(this), tokenId);
started = true;
endAt = block.timestamp + 1 days;
emit Start();


bidders.push(msg.sender);
bids[msg.sender] = [share,msg.value];
payable(address(this)).transfer(msg.value);

emit Bid(msg.sender, msg.value);
}

function end() external {
require(started, "You need to start first!");
require(block.timestamp >= endAt, "Auction is still ongoing!");
require(!ended, "Auction already ended!");

uint256 highestBidder;
uint256 maxRatio;
uint256 biddersCount;
biddersCount = bidders.length;
while(remainingShare > 0 && bidders.length > 0){
maxRatio = 0;
highestBidder = 0;
for(uint j=0;j<bidders.length;j++){
if(maxRatio < bids[bidders[j]][1] / bids[bidders[j]][0])
{
highestBidder=j;
maxRatio=bids[bidders[j]][1] / bids[bidders[j]][0];
}
}
if(highestBidder!=0){
//This function was decaled external. I changed it to public .
withdraw(bidders[highestBidder],bids[bidders[highestBidder]][0],bids[bidders[highestBidder]][1]);
remainingShare -= bids[bidders[highestBidder]][0];
biddersCount-=1;
// Why is it empty ?
//bids[bidders[highestBidder]] = [];
// Addde address 0
bidders[highestBidder]=address(0);
}
}
}





function withdraw(address bidder,uint _share,uint price) public payable returns(uint) {

// require(sent, "Could not withdraw");
payable(address(this)).transfer(msg.value);
shareHoldersMapping[bidder] = share;
shareHolders.push(bidder);
emit Withdraw(msg.sender, price);
return price ;
}

function refund () public {
for(uint i=0;i<bidders.length;i++){
uint bal=bids[bidders[i]][1];
payable( bidders[i]).transfer(bal);
}
ended = true;
// Update thid value
emit End(msg.sender, 0);
}

constructor(address _nftAddress, uint256 _currentPrice) Share(1,2) ERC721("AS", "As") {
require(_nftAddress != address(0) && _nftAddress != address(this));
require(_currentPrice > 0);
// Non- decalred nft address.
//nftAddress = address(ERC721(_nftAddress));
currentPrice = _currentPrice;
}

function purchaseNft() public payable {
require(msg.sender != address(0) && msg.sender != address(this));
require(msg.value >= currentPrice);
// This struct doesn't exist.
// require(tokenExists[tokenId]);
address tokenOwner = ownerOf(tokenId);
safeTransferFrom(tokenOwner, msg.sender, tokenId);
// Event doesn't exist.
//emit Received(msg.sender, tokenId, msg.value, address(this).balance);
}


function sendTo() public {
require(msg.sender==owner);

require(currentPrice > 0 && currentPrice <= address(this).balance);
payable(owner).transfer((currentPrice/100)*(OwnerShare));
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

