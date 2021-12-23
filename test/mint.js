const { hre, network, waffle, ethers } = require("hardhat");
const Farmers = require('../artifacts/contracts/Farmers.sol/Farmers.json');
const { constants } = require('./constants.js');


const main = async () => {

    const FARMERS_ADDRESS = '0x922D6956C99E12DFeB3224DEA977D0939758A1Fe';
    const account = '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266';
    const ether = '10000000000000000000';
    const options = { value: ether };
    
    const signer = await ethers.getSigner(account)

    const farmers = new ethers.Contract(FARMERS_ADDRESS, Farmers.abi, signer);

    //mint an NFT
    const mint = await farmers.mintFarmer(10, options );
    await mint.wait();
    console.log('Minted NFT', mint.hash);

    let supply = await farmers.getSupply();
    console.log('Current Supply', supply.toNumber())
    
    
}

const runMain = async () => {
    try {
        await main();
        process.exit(0)
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();