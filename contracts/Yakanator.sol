//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IYakregator} from './interfaces/IYakregator.sol';
import {IYakVault} from './interfaces/IYakVault.sol';

import "hardhat/console.sol";

contract Yakanator is Ownable {

    using SafeMath for uint256;

    IYakregator yakregator;

    constructor(address _yakregator) {
        yakregator = IYakregator(_yakregator);  
    }

    function setYakregator(address _yakregator) external onlyOwner{
        yakregator = IYakregator(_yakregator);
    }

    function stake(uint256 _amount, address _vault) external {
        //takes in tokens and stakes them in specified Yak vault
        
    }

    function unStake(uint256 _amount, address _vault) external {
        //takes in amount and pulls from the pool

    }

    function swap(uint256 _amount, address _from, address _to) external returns(uint){
        //takes in token swaps with aggregator

    }

    //returns balance of specific pool
    function balance(address _vault) external view returns(uint) {
        IYakVault vault = IYakVault(_vault);
        uint256 bal = vault.balanceOf(address(this));

        return bal;
    }

    // Need this to receive AVAX 
    receive() external payable {}   
}