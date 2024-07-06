// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DutchAuction {
    address payable public owner;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public pricePerunit;
    uint256 public totalBidAmount = 0;
    address[] public bidders;

    constructor(uint256  _startTime,uint256  _endTime,uint256  _pricePerunit) {
        startTime = _startTime;
        endTime = _endTime;
        pricePerunit = _pricePerunit;
        owner = payable(msg.sender);  
    }

    function startAuction(uint256  _startTime,uint256  _endTime,uint256  _pricePerunit) public {
        startTime  = _startTime;
        endTime = _endTime;
        pricePerunit = _pricePerunit;
        owner = payable(msg.sender);
        emit AuctionStarted(_startTime,_endTime,_pricePerunit);
    }
    
    event AuctionStarted(uint256 startTime, uint256 endTime,uint256 pricePerunit);
        
    function bid(uint256  _amount, uint256  _totalBidAmount)public{
        require(block.timestamp >=startTime && block.timestamp <= endTime);
        require(_amount >= pricePerunit);
        require(_totalBidAmount > 0, "Total bid amount must be greater than zero");
        bidders.push(msg.sender);
        totalBidAmount = _totalBidAmount;
        emit BidPlaced(_amount, msg.sender);
    }
    event BidPlaced(uint256  _amount,address indexed  _bidder);
    
    function getBidAmount()public view returns(uint256){
        return totalBidAmount;
    }
}

contract DutchAuctionTest {
    uint256 _startTime;
    uint256 _endTime;
    uint256 _pricePerunit;
    DutchAuction auction;
    function setUp() public {
        auction = new DutchAuction(_startTime, _endTime, _pricePerunit);
    }
    
    function test_start_auction() public{
        auction.startAuction(1,1,1);
        assert(auction.startTime() == 1);
        assert(auction.endTime() == 1);
        assert(auction.pricePerunit() == 1);
        assert(auction.totalBidAmount() == 0);
    }
    
    function test_bid() public{
        auction.bid(1,1);
        assert(auction.totalBidAmount() == 1);

    }
    
    function test_getBidAmount() public view{
       assert(auction.getBidAmount() == 1);
    }
}