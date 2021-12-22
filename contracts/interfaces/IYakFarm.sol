//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


interface IYakFarm {

    function withdraw(uint256 amount) external;
    function deposit(uint256 amount) external payable;
    function balanceOf(address account) external view returns (uint);
}