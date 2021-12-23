const { hre, network, waffle, ethers } = require("hardhat");
const Farmers = require('../artifacts/contracts/Farmers.sol/Farmers.json');
const Farmtroller = require('../artifacts/contracts/Farmtroller.sol/Farmtroller.json');
        
const main = async () => {
    
        const ether = '1000000000000000000';
        const options = { gas: 50000000 };
        const FARMTROLLER_ADDRESS = '0x59b670e9fA9D0A427751Af201D676719a970857b';
        const account = '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266';

        const signer = await ethers.getSigner(account)
    
        const farmtroller = new ethers.Contract(FARMTROLLER_ADDRESS, Farmtroller.abi, signer);
    
        const divest = await farmtroller.divestAll();
        await divest.wait();
        console.log('Divested All: ', divest.hash)
        
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