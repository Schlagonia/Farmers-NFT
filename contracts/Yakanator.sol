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

    function setYakregator(address _yakregator) external onlyOwner{
        yakregator = IYakregator(_yakregator);
    }

    function setGasPrice(uint256 _gasPrice) external onlyOwner{
        gasPrice = _gasPrice;
    }

    function _stake(uint256 _amount, address _token, address _vault) internal {
        //takes in tokens and stakes them in specified Yak vault
        IYakVault vault = IYakVault(_vault);
        //approve spending of token


        vault.deposit(_token, _amount);
    }

    function _unStake(uint256 _amount, address _vault) internal {
        //takes in amount and pulls from the pool
        IYakVault vault = IYakVault(_vault);    
        vault.withdraw(_amount);
    }

    function _query(uint256 _amountIn, address _tokenIn, address _tokenOut) internal view returns (IYakregator.FormattedOfferWithGas memory) {
        IYakregator.FormattedOfferWithGas memory offer = yakregator.findBestPathWithGas(_amountIn, _tokenIn, _tokenOut, 4, gasPrice);

        return offer;
    } 

    function _swapToAvax(uint256 _amount, address _out, address _from, address _to) internal {
        //takes in token swaps with aggregator
        IYakregator.FormattedOfferWithGas memory offer = _query(_amount, _from, _to);
        //FormattedOfferWithGas memory offer = yakregator.findBestPathWithGas(_amount, _from, _to, 4, gasPrice);
        
        IYakregator.Trade memory trade = IYakregator.Trade(
            _amount,
            offer.amounts[1],
            offer.path,
            offer.adapters
        );

        yakregator.swapNoSplitToAVAX(trade, _out);

    }

    function _swapFromAvax(uint256 _amount, address _out, address _from, address _to) internal{
        IYakregator.FormattedOfferWithGas memory offer = _query(_amount, _from, _to);
        
        IYakregator.Trade memory trade = IYakregator.Trade(
            _amount,
            offer.amounts[1],
            offer.path,
            offer.adapters
        );

        yakregator.swapNoSplitFromAVAX(trade, _out);

    }

    //returns balance of specific pool
    function _balance(address _vault) internal view returns(uint) {
        IYakVault vault = IYakVault(_vault);
        uint256 bal = vault.balanceOf(address(this));

        return bal;
    }

}