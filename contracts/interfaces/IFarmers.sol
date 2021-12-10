//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


interface IFarmers {

    function getSupply() external view returns(uint256);
    function numberMinted() external view returns(uint256);
    function bal(address _address) external view returns (uint256);

}