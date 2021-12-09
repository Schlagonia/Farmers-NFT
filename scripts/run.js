
const main = async () => {

    const farmtrollerFactory = await hre.ethers.getContractFactory("Farmtroller");
    const farmtrollerContract = await farmtrollerFactory.deploy();
    await farmtrollerContract.deployed();

    console.log("Contract deplyed to: ", farmtrollerContract.address);
    
    const farmerFactory = await hre.ethers.getContractFactory("Farmers");
    const farmerContract = await farmerFactory.deploy(10000, farmtrollerContract.address);
    await farmerContract.deployed();

    console.log("Contract deplyed to: ", farmerContract.address);

    


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