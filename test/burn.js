const { hre, network, waffle, ethers } = require("hardhat");
const Farmers = require('../artifacts/contracts/Farmers.sol/Farmers.json');

        
const main = async () => {
    
        const ether = '1000000000000000000';
        const options = { value: ether };
        const FARMERS_ADDRESS = '0x9E545E3C0baAB3E08CdfD552C960A1050f373042';
        const FARMTROLLER_ADDRESS = '0xa82fF9aFd8f496c3d6ac40E2a0F282E47488CFc9';
        const provider = waffle.provider;
        
        const account = '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266';
        
        const signer = await ethers.getSigner(account)
    
        const farmers = new ethers.Contract(FARMERS_ADDRESS, Farmers.abi, signer);
    
        const burn = await farmers.burn(8);
        await burn.wait();
        console.log('Burn NFT', burn.hash);

        supply = await farmers.getSupply();
        console.log('Current Supply', supply.toNumber())

        let bal = await provider.getBalance(FARMTROLLER_ADDRESS);
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