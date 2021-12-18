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
    address public constant WAVAX = 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7;
    uint gasPrice = 225000000000;
    uint maxSteps = 4;

    event staked(
        uint256 amount,
        address vault
    );

    event unstaked(
        uint256 amount,
        address vault
    );

    event swapped(
        uint256 amount,
        address from,
        address to
    );

    function setYakregator(address _yakregator) external onlyOwner{
        yakregator = IYakregator(_yakregator);
    }

    function setGasPrice(uint256 _gasPrice) external onlyOwner{
        gasPrice = _gasPrice;
    }

    function setMaxSteps(uint256 _steps) external onlyOwner {
        maxSteps = _steps;
    }

    function _stake(address _token, address _vault, uint256 _amount) internal {
        //takes in tokens and stakes them in specified Yak vault
        IYakVault vault = IYakVault(_vault);
        
        //check if depositing avax of erc20
        if(_token == WAVAX){
            vault.deposit(_token, _amount);
        } else {
            IERC20 token = IERC20(_token);
            uint256 bal = token.balanceOf(address(this));
            //approve spending of token
            token.approve(_vault,  bal);

            vault.deposit(_token, bal);
        }

        emit staked(_amount, _vault);
    }

    function _unstake(uint256 _amount, address _vault) internal {
        //takes in amount and pulls from the pool
        IYakVault vault = IYakVault(_vault);    
        vault.withdraw(_amount);

        emit unstaked(_amount, _vault);
    }

    function _query(uint256 _amountIn, address _tokenIn, address _tokenOut) internal view returns (IYakregator.FormattedOfferWithGas memory) {
        IYakregator.FormattedOfferWithGas memory offer = yakregator.findBestPathWithGas(_amountIn, _tokenIn, _tokenOut, maxSteps, gasPrice);

        return offer;
    } 

    function _swapToAvax(uint256 _amount, address _from) internal {
        //takes in token swaps with aggregator
        IYakregator.FormattedOfferWithGas memory offer = _query(_amount, _from, WAVAX);
        //FormattedOfferWithGas memory offer = yakregator.findBestPathWithGas(_amount, _from, _to, 4, gasPrice);
        
        IYakregator.Trade memory trade = IYakregator.Trade(
            _amount,
            offer.amounts[1],
            offer.path,
            offer.adapters
        );

        //need to approve spending 

        yakregator.swapNoSplitToAVAX(trade, address(this));

        emit swapped(_amount, _from, WAVAX);

    }

    function _swapFromAvax(uint256 _amount, address _to) internal{
        IYakregator.FormattedOfferWithGas memory offer = _query(_amount, WAVAX, _to);
        
        IYakregator.Trade memory trade = IYakregator.Trade(
            _amount,
            offer.amounts[1],
            offer.path,
            offer.adapters
        );

        yakregator.swapNoSplitFromAVAX(trade, address(this));

        emit swapped(_amount, WAVAX, _to);
    }

    //returns balance of specific pool
    function _balance(address _vault) internal view returns(uint) {
        IYakVault vault = IYakVault(_vault);
        uint256 bal = vault.balanceOf(address(this));

        return bal;
    }

}