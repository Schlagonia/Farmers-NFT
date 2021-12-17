//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import './Yakanator.sol';

import { IFarmers } from './interfaces/IFarmers.sol';

import "hardhat/console.sol";

contract Farmtroller is Ownable, Yakanator {
 
    using SafeMath for uint256;

    IFarmers Farmers;
    uint public managementFee;
    //underlying value per each outstanding NFT to 1e3 
    uint public nav;
    uint public fundOwns = 0;
    

    address pool1;
    address pool2;
    address pool3;
    address pool4;

    constructor(address _Farmers) {
        Farmers = IFarmers(_Farmers);
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
            nav = getBalance().mul(1000).div(supply);
        } else {
            nav = 0;
        }
        return nav;
    }

    function getFundOwned() external view returns (uint256){
        return fundOwns;
    }

    function payOwner() external onlyOwner {
        uint256 toPay = fundOwns;
        uint256 bal = address(this).balance;
        if(toPay > bal){
            //pull funds from one fund to pay owner
        }

        payable(msg.sender).transfer(fundOwns);
        fundOwns = 0;

    }


    //@dev
    //on harvest of reward tokens fundOwns is taken out and sent to owner
    function chargeManagementFee() external onlyOwner returns (uint) {
        uint charge = getBalance().div(managementFee);
        
        fundOwns = fundOwns.add(charge);
        
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

    function getBalance() public view returns( uint256) {
        // get balance of the fund
        //AVAX held in the account
        uint256 bal = address(this).balance;
        //add up the current balance of each pool


        return bal;
    }

    function invest() external onlyOwner {
        //get ballance of fund
        uint bal = getBalance();

        //divide balance into fourths
        uint fourth = bal.div(4);

        //invest each quarter into each pool
       
    }

    function burningToken() external returns(uint) {
        
    }

    // Need this to receive AVAX 
    receive() external payable {}   
}