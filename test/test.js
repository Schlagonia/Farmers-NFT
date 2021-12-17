
const main = async () => {

    const yakRouter = '0xC4729E56b831d74bBc18797e0e17A295fA77488c'
    
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
    console.log(setTroller)
    
    const setRouter = await farmtrollerContract.setYakregator(yakRouter);
    await setRouter.wait()
    console.log(setRouter)
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