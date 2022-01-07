//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import { IFarmtroller } from './interfaces/IFarmtroller.sol';

import "hardhat/console.sol";

// We need to import the helper functions from the contract that we copy/pasted.
import { Base64 } from "./libraries/Base64.sol";


contract Farmers is ERC721URIStorage, Ownable {

    using SafeMath for uint256;

    //Keeps track of how many minted
    uint256 public tokenIds = 0;
    //Keep track of circulating supply. Minted - Burned
    uint256 public supply = 0;
    //base URI
    string baseUri = '';

    IFarmtroller Farmtroller;

    //price to mint. This should start at 2 avax and grow once funds have been invested along with the NAV
    //creates urgency to mint and rewards early adopters
    uint256 public constant firstFarmerPrice = 2000000000000000000; //2 AVAX
    bool invested = false;

    //max to purchase at a time
    uint256 public constant maxFarmerPurchase = 10;

    //determine how many there will
    uint256 public MAX_FARMERS;
    
    mapping (uint256 => uint256) used;

    bool public saleIsActive = false;

    event NFTMinted(
        address sender, 
        uint256 tokenId
    );

    event NFTBurned(
        uint256 tokenId
    );

    constructor(uint256 maxNftSupply) ERC721("AVAX Farmers", "FRMR") {
        MAX_FARMERS = maxNftSupply;
    
    }

    function setFarmtroller(address payable _farmtroller) external onlyOwner {
        Farmtroller = IFarmtroller(_farmtroller);
    }

    function invested() external onlyOwner{
        invested = true;
    }

    //withdrawas funds in contract to Farmtroller to be invested
    function withdraw() external onlyOwner {
        uint balance = address(this).balance;
        payable(address(Farmtroller)).transfer(balance);
    }

    function getSupply() external view returns(uint256) {
        return supply;
    }

    function numberMinted() external view returns(uint256) {
        return tokenIds;
    }    

    function bal(address _address) external view returns (uint256) {
        return balanceOf(_address);
    }

    // Pause sale if active, make active if paused
    function flipSaleState() external onlyOwner {
        saleIsActive = !saleIsActive;
    }

    function _getBatchPrice(uint256 _n) public view returns (uint256) {
        uint256 totalPrice = 0;
        uint256 index = tokenIds;
        if(!invested){
            totalPrice = _n.mul(firstFarmerPrice);
            
        } else {
            totalPrice = _n.mul(Farmtorller.NAV());
        }
        console.log('total Price: ', totalPrice);
        return totalPrice;
    }   

    function _imageId(uint256 _id) internal view returns (uint256) {
        //check mapping and find a image not yet used
        //means the id has not been used
        uint256 id = _id;

        while(used[id] != 0){

        }

        return id;
    }

    function _enoughRandom() internal view returns (uint256) {
        if (MAX_FARMERS - tokenIds == 0) return 0;
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        block.timestamp,
                        msg.sender,
                        blockhash(block.number)
                    )
                )
            ) % (MAX_FARMERS);
    }

    //Mints nft'S    
    //@dev still need to determine how to host Json with Moralis and include each item ID
    function mintFarmer(uint numberOfTokens) external payable {
        require(saleIsActive, "Sale must be active to mint Farmer");
        require(numberOfTokens <= maxFarmerPurchase, "Can only mint 10 tokens at a time");
        require(_getBatchPrice(numberOfTokens) <= msg.value, "AVAX value sent is not correct");
        
        for(uint i = 0; i < numberOfTokens; i++) {
            uint256 newItemId = tokenIds;

            require(newItemId < MAX_FARMERS, "All NFT's have been Minted");

            //Need to generate name and image
            //uint256 id = _enoughRandom();
            //uint256 imageId = _imageId(id);

            //encode the JSON file 
            //poosibly take the newItemID and insert it into Moralis hosted url that points to specific image 
            string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT .
                        newItemId,
                        '", "description": "A NFT collection to harvest the fields of AVAX and beyond.", "image":', 
                        baseUri, newItemId,'}'
                        )
                    )
                )
            );

            // Just like before, we prepend data:application/json;base64, to our data.
            string memory finalTokenUri = string(
                abi.encodePacked("data:application/json;base64,", json)
            );

            _safeMint(msg.sender, newItemId);


            _setTokenURI(newItemId, finalTokenUri);

            tokenIds ++;
            supply ++;

            emit NFTMinted(msg.sender, newItemId);
            console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
        }

        payable(address(Farmtroller)).transfer(address(this).balance);


    }

    function burn(uint256 _tokenId) external {
        require(ownerOf(_tokenId) == msg.sender);
        _burn(_tokenId);
        
        //pull funds from Farmtroller based off of current value of the NFT
        Farmtroller.burningToken(msg.sender);

        //send funds equal to NFT NAV - royalty fee that goes to tresury to msg.sender
        supply -= 1;
        emit NFTBurned(_tokenId);
    }

    // Need this to receive ETH when `borrowEthExample` executes
    receive() external payable {}   
    
}