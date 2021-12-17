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
    
    //current yak vaults and underlying tokens being used
    address vault1;
    address token1;
    address vault2;
    address token2;
    address vault3;
    address token3;
    address vault4;
    address token4;

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
            nav = getBalance().div(supply);
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


    //
    //on harvest of reward tokens fundOwns is taken out and sent to owner
    function chargeManagementFee() external onlyOwner returns (uint) {
        uint charge = getBalance().div(managementFee);
        
        fundOwns = fundOwns.add(charge);
        
        return charge;
    }

    function setInvestmentPool(
        address _vault1, address _token1, 
        address _vault2, address _token2,
        address _vault3, address _token3,
        address _vault4, address _token4
    ) external onlyOwner {
        //assign the contracts and the tokens for the vault that won the vote
        vault1 = _vault1;
        token1 = _token1;
        vault2 = _vault2;
        token2 = _token2;
        vault3 = _vault3;
        token3 = _token3;
        vault4 = _vault4;
        token4 = _token4;
    }

    function getBalance() public view returns( uint256) {
        // get balance of the fund
        //AVAX held in the account
        uint256 bal = address(this).balance;
        //add up the current balance of each pool
        //subtract what the fund owns

        return bal;
    }

    function invest() external onlyOwner {
        //get ballance of fund
        uint bal = getBalance();

        //divide balance into fourths
        uint fourth = bal.div(4);

        //invest each quarter into each 
        _stake(fourth, token1, vault1);
        _stake(fourth, token2, vault2);
        _stake(fourth, token3, vault3);
        _stake(fourth, token4, vault4);
       
    }

    function divestAll() external onlyOwner {
        uint256 bal1 = _balance(vault1);
        _unStake(bal1, vault1);
        //swap to avax

        uint256 bal2 = _balance(vault2);
        _unStake(bal2, vault2);

        uint256 bal3 = _balance(vault3);
        _unStake(bal3, vault3);

        uint256 bal4 = _balance(vault4);
        _unStake(bal4, vault4);
    }

    function pullFunds(uint256 _amount, address _token, address _vault) external returns(uint256){
        _unStake(_amount, _vault);

        //swap to avax if need be
        if(_token != WAVAX) {
         _swapToAvax(_amount, address(this), _token, WAVAX);
        }
        
        return _amount;
    }

    function burningToken() external returns(uint) {
        
    }

    // Need this to receive AVAX 
    receive() external payable {}   
}