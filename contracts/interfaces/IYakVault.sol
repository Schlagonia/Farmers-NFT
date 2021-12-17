//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


interface IYakVault {

    function withdraw(uint amount) external;
    function deposit(address token, uint amount) external;
    function balanceOf(address account) external view returns (uint);
}