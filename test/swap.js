const { hre, network, waffle, ethers } = require("hardhat");
const Farmers = require('../artifacts/contracts/Farmers.sol/Farmers.json');
const Farmtroller = require('../artifacts/contracts/Farmtroller.sol/Farmtroller.json');
const Router = require('./ABI/YakRouter.json');
        
const main = async () => {
    
        const ether = '1000000000000000000';
        const options = { value: ether };
        const FARMTROLLER_ADDRESS = '0x99bbA657f2BbC93c02D617f8bA121cB8Fc104Acf';
        const FARMERS_ADDRESS = '0x4826533B4897376654Bb4d4AD88B7faFD0C98528';
        const yakRouter = '0xC4729E56b831d74bBc18797e0e17A295fA77488c';
        const account = '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266';
        const provider = waffle.provider;
    
        
        const signer = await ethers.getSigner(account)
    
        const farmtroller = new ethers.Contract(FARMTROLLER_ADDRESS, Farmtroller.abi, signer);
        const farmers = new ethers.Contract(FARMERS_ADDRESS, Farmers.abi, signer);
        const router = new ethers.Contract(yakRouter, Router.abi, signer);

        let bal  = await provider.getBalance(account)
       console.log('Account Balance: ', ethers.utils.formatEther(bal))

        let offer = await router.findBestPath(ether, '0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7', '0xa7d7079b0fead91f3e65f86e8915cb59c1a4c664', 2)
        console.log('offer', offer);
        
        console.log('offer.amounts[0]',offer.amounts[offer.amounts.length -1])
        console.log('offer.amounts[0].toString', offer.amounts[offer.amounts.length -1].toString())

        let trade = [
            ether,
            offer.amounts[offer.amounts.length - 1],
            offer.path,
            offer.adapters
        ];

        let swap = await router.swapNoSplitFromAVAX(trade, account, 0, options );
        await swap.wait()
        console.log('Swapped: ', swap.hash)

        bal = await provider.getBalance(account)
        console.log('Account Balance: ', ethers.utils.formatEther(bal))

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