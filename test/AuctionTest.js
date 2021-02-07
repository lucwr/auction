
const {equal} = require("assert");

const auction = artifacts.require("Auction");
const truffleAssert = require('truffle-assertions');
const assert = require("chai").assert;
const {expectRevert}=require('@openzeppelin/test-helpers');
const { expect } = require("chai");

let currentBalance;
let winner;
const adrzero="0x0000000000000000000000000000000000000000";
const starting_bal=1000000000000000;
contract('Auction',(accounts)=>{

it("should have a zero address as the winner and min bid as the winning bid at contract deployment",async function(){
const auctionInstance=await auction.deployed();
const newArgs=await auctionInstance.getWinningBid({from: accounts[0]});
truffleAssert.eventEmitted(newArgs, 'currentWinners', (ev) => {
  return ev._winner === adrzero && ev. _amount.toNumber() === starting_bal;
});

});

it("should accept bids when the auction is open ",async function(){
  const auctionInstance=await auction.deployed();
  const returnArgs=await auctionInstance.contribute({from: accounts[1],value: 10000000000000000});
  truffleAssert.eventEmitted(returnArgs,'bidReceived',(ev)=>{
    return ev.contributor===accounts[1] && ev.amount.toString()==="10000000000000000";
  });
});
it("should revert when the bid is lower than the current highest bidder",async function(){
  const auctionInstance=await auction.deployed();
  await expectRevert(
   auctionInstance.contribute({from: accounts[2],value: 10000000000000}), 'your bid should be higher than the current bid'
  );
});

}); 