//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IFarmtroller {

    function burningToken(address _address) external returns(uint256);
    function NAV() external returns (uint256) 
}