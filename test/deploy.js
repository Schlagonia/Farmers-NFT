
const main = async () => {

    const yakRouter = '0xC4729E56b831d74bBc18797e0e17A295fA77488c';
    const ether = '1000000000000000000';
    const account = '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266'
    const options = { value: ether };
    const vault1 = '0xf6cCf601bd024612aAF85440153c2df0524E4607';
    const token1 = '0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7';

    
    const farmerFactory = await hre.ethers.getContractFactory("Farmers");
    const farmerContract = await farmerFactory.deploy(10000);
    await farmerContract.deployed();
    console.log("Farmers deplyed to: ", farmerContract.address);

    const farmtrollerFactory = await hre.ethers.getContractFactory("Farmtroller");
    const farmtrollerContract = await farmtrollerFactory.deploy(farmerContract.address);
    await farmtrollerContract.deployed();
    console.log("Farmtroller deplyed to: ", farmtrollerContract.address);

    const setTroller = await farmerContract.setFarmtroller(farmtrollerContract.address)
    await setTroller.wait()
    console.log('set Troller', setTroller)
    
    const setRouter = await farmtrollerContract.setYakregator(yakRouter);
    await setRouter.wait()
    console.log('router set', setRouter)

    const active = await farmerContract.flipSaleState();
    await active.wait();
    console.log('Market Made ACtive')

    let vault = await farmtrollerContract.setInvestmentPool(0, vault1, token1);
    await vault.wait()
    console.log('Vault 1 set:', vault.hash)

    vault = await farmtrollerContract.setInvestmentPool(1, vault1, token1);
    await vault.wait()
    console.log('Vault 2 set:', vault.hash)

    vault = await farmtrollerContract.setInvestmentPool(2, vault1, token1);
    await vault.wait()
    console.log('Vault 3 set:', vault.hash)

    vault = await farmtrollerContract.setInvestmentPool(3, vault1, token1);
    await vault.wait()
    console.log('Vault 4 set:', vault.hash)
    

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