//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IYakregator} from './interfaces/IYakregator.sol';
import {IYakFarm} from './interfaces/IYakFarm.sol';

import "hardhat/console.sol";

contract Yakanator is Ownable {

    using SafeMath for uint256;

    IYakregator yakregator;
    address public constant WAVAX = 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7;
    uint gasPrice = 225000000000;
    uint maxSteps = 2;
    uint256 slippage = 100;

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

    function setSlippage(uint256  _slippage) external onlyOwner{
        slippage = _slippage;
    }

    function _stake(address _token, address _vault, uint256 _amount) internal {
        //takes in tokens and stakes them in specified Yak vault
        IYakFarm vault = IYakFarm(_vault);
        IERC20 token = IERC20(_token);
        
        //check if depositing avax of erc20
        if(_token == WAVAX){

            vault.deposit{ value: _amount }();
            console.log('Staking WAVAX:');
        } else {
            
            uint256 bal = token.balanceOf(address(this));
            //approve spending of token
            token.approve(_vault,  bal);

            vault.deposit(bal);
            console.log('Staked ERC20');
        }

        emit staked(_amount, _vault);
    }

    function _unstake(uint256 _amount, address _vault) internal {
        //takes in amount and pulls from the pool
        IYakFarm vault = IYakFarm(_vault);    
        vault.withdraw(_amount);

        emit unstaked(_amount, _vault);
    }

    function _query(uint256 _amountIn, address _tokenIn, address _tokenOut) internal view returns (IYakregator.FormattedOffer memory) {
        IYakregator.FormattedOffer memory offer = yakregator.findBestPath(_amountIn, _tokenIn, _tokenOut, maxSteps);

        return offer;
    } 

    function _swapToAvax(uint256 _amount, address _from) internal {
        //takes in token swaps with aggregator
        IYakregator.FormattedOffer memory offer = _query(_amount, _from, WAVAX);
        //FormattedOfferWithGas memory offer = yakregator.findBestPathWithGas(_amount, _from, _to, 4, gasPrice);

        //calculate min based on slippage tolerance
        uint256 min = offer.amounts[offer.amounts.length - 1].div(slippage);
        min = offer.amounts[offer.amounts.length - 1].sub(min);
        
        IYakregator.Trade memory trade = IYakregator.Trade(
            _amount,
            min,
            offer.path,
            offer.adapters
        );

        //need to approve spending 
        IERC20 token = IERC20(_from);
        token.approve(address(yakregator), _amount);

        yakregator.swapNoSplitToAVAX(trade, address(this), 0);

        emit swapped(_amount, _from, WAVAX);

    }

    function _swapFromAvax(uint256 _amount, address _to) internal{
        IYakregator.FormattedOffer memory offer = _query(_amount, WAVAX, _to);

        console.log('Offer.amounts: ', offer.amounts[offer.amounts.length - 1]);
        uint256 out = offer.amounts[offer.amounts.length.sub(1)];
        //calculate min based on slippage tolerance
        uint256 min = out.div(slippage);
        out = out.sub(min);
        console.log('Min: ', out);
        
        IYakregator.Trade memory trade = IYakregator.Trade(
            _amount,
            min,
            offer.path,
            offer.adapters
        );

        yakregator.swapNoSplitFromAVAX{ value: _amount }(trade, address(this), 0);

        emit swapped(_amount, WAVAX, _to);
    }

    //returns balance of specific pool
    function _balance(address _vault) internal view returns(uint) {
        IYakFarm vault = IYakFarm(_vault);
        uint256 bal = vault.balanceOf(address(this));

        return bal;
    }

}