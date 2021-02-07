var auction=artifacts.require('Auction');
var title= "An auction to sell a car"
var description= "Selling cars is awesome"
var deadline= 1612828800 //02/09/2021 @ 12:00am (UTC)
var starting_amount= 1000000000000000 //0.001eth/bnb

module.exports=function(deployer){
    deployer.deploy(auction,title,description,deadline,starting_amount);
};