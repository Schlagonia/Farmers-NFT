//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


interface IYakregator {

    struct FormattedOfferWithGas {
        uint[] amounts;
        address[] adapters;
        address[] path;
        uint gasEstimate;
    }
    
    struct Trade {
        uint amountIn;
        uint amountOut;
        address[] path;
        address[] adapters;
    }

    function findBestPathWithGas(
        uint256 _amountIn, 
        address _tokenIn, 
        address _tokenOut, 
        uint _maxSteps,
        uint _gasPrice
    ) external view returns (FormattedOfferWithGas memory); 
    
    function swapNoSplitFromAVAX(Trade calldata _trade, address _to) external payable ;
    function swapNoSplitToAVAX(Trade calldata _trade, address _to) external;
}