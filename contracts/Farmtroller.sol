//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import { IFarmers } from './interfaces/IFarmers.sol';

import "hardhat/console.sol";

contract Farmtroller is Ownable {
 
    using SafeMath for uint256;

    address owner;
    address payable Farmers;
    uint public managementFee;
    //underlying value per each outstanding NFT to 1e3 
    uint public nav;
    uint public fundOwns = 0;
    

    address pool1;
    address pool2;
    address pool3;
    address pool4;

    constructor(address payable _Farmers) {
        owner = msg.sender;
        Farmers = _Farmers;
    }

     // _fee where 1/_fee = % t0 charge/ 1% == 100
    function setManagementFee(uint256 _fee) external onlyOwner returns (uint ) {
        managementFee = _fee;
        return managementFee;
    }

    //calculats the underlyingvalue for each NFT
    function NAV() public returns (uint256) {
        //pps = getalance() / Farmer.supply();
        uint supply = Farmers.getSupply();
        if( supply > 0){
            nav = ((getBalance() * 1000) / supply);
        } else {
            nav = 0;
        }
        return nav;
    }

    function payOwner() external onlyOwner returns (uint256) {
        getBalance();
        uint256 pay = fundOwns;

        Farmers.transfer(address(owner), pay);
    
        fundOwns = 0;

        return pay;

    }


    //@dev
    //on harvest of reward tokens fundOwns is taken out and sent to owner
    function chargeManagementFee() external onlyOwner returns (uint) {
        uint charge = (getBalance() / managementFee);
        
        fundOwns = fundOwns + charge;
        
        return charge;

    }

    function setInvestmentPool(address _pool1, address _pool2, address _pool3, address _pool4) external onlyOwner {
        //instantiate the contracts for the pools that won the vote
        pool1 = _pool1;
        pool2 = _pool2;
        pool3 = _pool3;
        pool4 = _pool4;
        //takes balance of the troller and sends 25% of the funds to each pool
    }

    function getBalance() public returns( uint256) {
        // get balance of the fund
    }

    function invest() external onlyOwner {
        //get ballance of fund
        uint balance = getBalance();

        //divide balance into fourths


        //invest each quarter into each pool
       
    }

    // Need this to receive AVAX 
    receive() external payable {}   
}