const { hre, network, waffle, ethers } = require("hardhat");
const Farmers = require('../artifacts/contracts/Farmers.sol/Farmers.json');
const Farmtroller = require('../artifacts/contracts/Farmtroller.sol/Farmtroller.json');
        
const main = async () => {
    
        const ether = '1000000000000000000';
        const options = { value: ether };
        const FARMERS_ADDRESS = '0xCD8a1C3ba11CF5ECfa6267617243239504a98d90';
        const FARMTROLLER_ADDRESS = '0x82e01223d51Eb87e16A03E24687EDF0F294da6f1';
        const account = '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266';
        const vault1 = '0xf6cCf601bd024612aAF85440153c2df0524E4607';
        const token1 = '0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7';

        
        const signer = await ethers.getSigner(account)
    
        const farmtroller = new ethers.Contract(FARMTROLLER_ADDRESS, Farmtroller.abi, signer);
    
        const invest = await farmtroller.invest();
        await invest.wait();
        console.log('Invested: ', invest.hash)
        
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