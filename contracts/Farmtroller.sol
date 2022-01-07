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
    uint256 public managementFee;
    //underlying value per each outstanding NFT to 1e3 
    uint256 public nav;
    uint256 public fundOwns = 0;

    uint256 burnRoyalty = 50;
    uint256 vaults = 4;
    //starting point to setrmine which vault to pull funds from using mod
    uint256 pullVault = 100;
    //amount to keep in famrtroller for rounding errors/slippage
    // 100/buffer == %
    uint256 buffer = 100;

    //current yak vaults and underlying tokens being used set to id 0 -3
    mapping(uint256 => address) vault;
    mapping(uint256 => address) token;

    uint256 eth = 1000000000000000;

    modifier farmersOnly {
        require(msg.sender == address(Farmers));
        _;
    }

    event payedOwner(
        uint256 payed
    );

    event invested(
        uint256 _invested
    );

    event tokenBurned(
        address _address,
        uint256 amount
    );

    constructor(IFarmers _Farmers) {
        Farmers = _Farmers;
    }

     // _fee where 1/_fee = % t0 charge/ 1% == 100
    function setManagementFee(uint256 _fee) external onlyOwner returns (uint256) {
        managementFee = _fee;
        return managementFee;
    }

    function setVaults(uint256 _vaults) external onlyOwner {
        vaults = _vaults;
    }

     // _fee where 1/_fee = % t0 charge/ 1% == 100
    function setBurnRoyalty(uint256 _royalty) external onlyOwner{
        burnRoyalty = _royalty;
    }

    function setBuffer(uint256 _buffer) external onlyOwner {
        buffer = _buffer;
    }

    function _vaultToPull() internal returns(uint256) {
        uint256 id = pullVault.mod(vaults);
        pullVault += 1;
        return id;
    }

    //calculats the underlyingvalue for each NFT
    function NAV() public returns (uint256) {
        
        uint256 supply = Farmers.getSupply();
        console.log('Supply: ', supply);
        if( supply > 0){
            
            nav = getBalance().div(supply);
        } else {
            nav = 0;
        }
        console.log('NAV: ', nav.div(eth));  
        return nav;
    }

    function getFundOwned() external view returns (uint256){
        return fundOwns;
    }

    function payOwner() external onlyOwner returns (uint256){
        uint256 toPay =  _chargeManagementFee();
        uint256 bal = address(this).balance;

        require(bal > toPay, 'Not enough AVAX');

        payable(msg.sender).transfer(toPay);

        fundOwns = 0;

        emit payedOwner(toPay);
        return toPay;

    }

    //on harvest of reward tokens fundOwns is taken out and sent to owner
    function _chargeManagementFee() internal returns (uint256) {
        uint256 charge = getBalance().div(managementFee);
        
        fundOwns = fundOwns.add(charge);
        
        return fundOwns;
    }

    //pass number 0 - 3 as the id and it is used to assign mapping of that id with vault and token address
    function setInvestmentPool(uint256 _id, address _vault, address _token) external onlyOwner {
        vault[_id] = _vault;
        token[_id] = _token;
    }

    //@dev need to convert balances to avax or usd
    function getBalance() public view returns(uint256) {
        //AVAX held 
        uint256 bal = address(this).balance;
        console.log('AVAX Balance: ', bal.div(eth));

        //add up the current balance of each pool
        for(uint256 i = 0; i < vaults; i ++){
            uint256 valance = _balance(vault[i]);
            console.log('Valance: ', i, valance.div(eth));
            if(valance > 0){
                if(token[i] == WAVAX){
                    bal = bal.add(valance);
                } else {            

                    IYakregator.FormattedOffer memory offer = _query(valance, token[i], WAVAX);
                
                    console.log('Offer 1: ', offer.amounts[offer.amounts.length - 1].div(eth));
                    bal = bal.add(offer.amounts[offer.amounts.length - 1]);
                }
            }
        }
        //subtract what the fund owns
        bal = bal.sub(fundOwns);
        console.log('Full Balance: ', bal.div(eth));
        return bal;
    }

    function invest() external onlyOwner {
        //get ballance of fund
        uint256 bal = address(this).balance;
        //subtract buffer
        uint256 toInvest = bal.sub(bal.div(buffer)); 
        //divide balance into fourths
        uint256 fourth = toInvest.div(4);
        console.log('Fourth: ', fourth.div(eth));

        //invest each quarter into each vault
        for(uint256 i = 0; i < vaults; i ++) {
            if(token[i] != WAVAX){
                //if not staking avax swap to token
                console.log('Swapping from AVAX');
                _swapFromAvax(fourth, token[i]);
                //stake with 0 as amount cause it wont be used
                console.log('Staking ERC20');
                _stake(token[i], vault[i], 0) ;
            } else {
                console.log('Staking AVAX');
                _stake(token[i], vault[i], fourth);
            }

        }

        emit invested(toInvest);
       
    }

    function divestAll() external onlyOwner {

        for(uint256 i = 0; i < vaults; i ++){
            uint256 valance = _balance(vault[i]);
            _unstake(valance, vault[i]);

            if(token[i] != WAVAX){
                _swapToAvax(valance, token[i]);
            }

        }

    }
    
    function _pullFunds(uint256 _amount, uint256 _id) internal returns(bool){
        
        if(token[_id] == WAVAX) {
            console.log('Pulling AVAX Token');
            _unstake(_amount, vault[_id]);

            return true;

        } else {
            console.log('Pulling Non-Avax Token');
            IYakregator.FormattedOffer memory offer = _query(_amount, WAVAX, token[_id]);
            _unstake(offer.amounts[offer.amounts.length - 1], vault[_id]);
            _swapToAvax(offer.amounts[offer.amounts.length - 1], token[_id]);

            return true;
        }
        
    }

    function burningToken(address _address) external farmersOnly returns(uint256) {
        nav = NAV();

        uint256 toPull = nav.sub(nav.div(burnRoyalty));
        console.log('Topull: ', toPull);
        if(address(this).balance < toPull){
            //decide which fund to pull from
            uint256 id = _vaultToPull();
            console.log('Vault to Pull: ', id);
            //random, switch everytime, any that are avax, or lowest current yield
            _pullFunds(toPull, id);
        }
        payable(_address).transfer(toPull);

        emit tokenBurned(_address, toPull);
        return toPull;
    }

    // Need this to receive AVAX 
    receive() external payable {}   
}