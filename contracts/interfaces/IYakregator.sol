//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


interface IYakregator {

    function swapNoSplit(Trade calldata _trade, address _to, uint _fee) public;
    function swapNoSplitFromAVAX(Trade calldata _trade, address _to, uint _fee) external payable ;
    function swapNoSplitToAVAX(Trade calldata _trade, address _to, uint _fee) public;
}