const { hre, network, waffle, ethers } = require("hardhat");
const Farmers = require('../artifacts/contracts/Farmers.sol/Farmers.json');
const Farmtroller = require('../artifacts/contracts/Farmtroller.sol/Farmtroller.json');
const Router = require('./ABI/YakRouter.json');
        
const main = async () => {
    
        const ether = '1000000000000000000';
        const options = { value: ether };
        const FARMTROLLER_ADDRESS = '0x59b670e9fA9D0A427751Af201D676719a970857b';
        const FARMERS_ADDRESS = '0xc6e7DF5E7b4f2A278906862b61205850344D4e7d';
        const account = '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266';
        const provider = waffle.provider;
    
        const signer = await ethers.getSigner(account)
    
        const farmtroller = new ethers.Contract(FARMTROLLER_ADDRESS, Farmtroller.abi, signer);
        const farmers = new ethers.Contract(FARMERS_ADDRESS, Farmers.abi, signer);
      
       //const bal1 = await farmtroller.getBalance();
       //console.log('Farmtroller Balance: ', ethers.utils.formatEther(bal1));

       const nav = await farmtroller.NAV();
       console.log('NAV: ', nav.toString())

       const bal3  = await provider.getBalance(account)
       console.log('Account Balance: ', ethers.utils.formatEther(bal3))
       
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