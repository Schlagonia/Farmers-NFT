const { hre, network, waffle, ethers } = require("hardhat");
const Farmers = require('../artifacts/contracts/Farmers.sol/Farmers.json');

        
const main = async () => {
    
        const ether = '1000000000000000000';
        const options = { value: ether };
        const FARMERS_ADDRESS = '0xc6e7DF5E7b4f2A278906862b61205850344D4e7d';
        const FARMTROLLER_ADDRESS = '0x59b670e9fA9D0A427751Af201D676719a970857b';
        const provider = waffle.provider;
        
        const account = '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266';
        
        const signer = await ethers.getSigner(account)
    
        const farmers = new ethers.Contract(FARMERS_ADDRESS, Farmers.abi, signer);
    
        const burn = await farmers.burn(1);
        await burn.wait();
        console.log('Burn NFT', burn.hash);

        supply = await farmers.getSupply();
        console.log('Current Supply', supply.toNumber())

        let bal = await provider.getBalance(account);
        console.log(bal.toString())
        
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