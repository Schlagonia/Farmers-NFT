const { hre, network, waffle, ethers } = require("hardhat");
const Farmers = require('../artifacts/contracts/Farmers.sol/Farmers.json');

        
const main = async () => {
    
        const ether = '1000000000000000000';
        const options = { value: ether };
        const FARMERS_ADDRESS = '0xCD8a1C3ba11CF5ECfa6267617243239504a98d90';
        const FARMTROLLER_ADDRESS = '0x82e01223d51Eb87e16A03E24687EDF0F294da6f1';
        const account = '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266';
        
        const signer = await ethers.getSigner(account)
    
        const farmers = new ethers.Contract(FARMERS_ADDRESS, Farmers.abi, signer);
    
        const burn = await farmers.burn(8);
        await burn.wait();
        console.log('Burn NFT', burn.hash);

        supply = await farmers.getSupply();
        console.log('Current Supply', supply.toNumber())

        let bal = await ethers.getBalance(FARMTROLLER_ADDRESS);
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