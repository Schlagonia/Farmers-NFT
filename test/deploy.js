const { hre, network, waffle, ethers } = require("hardhat");

const main = async () => {

    const yakRouter = '0xC4729E56b831d74bBc18797e0e17A295fA77488c';

    const account = '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266'
    const ether = '10000000000000000000'; //10
    const options = { value: ether };
    const pool = {
        one: {
            //avax JOe
            vault: '0xf6cCf601bd024612aAF85440153c2df0524E4607',
            token: '0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7'
        },
        two: {
            //joe
            vault: '0x3A91a592A06390ca7884c4D9dd4CBA2B4B7F36D1',
            token: '0x6e84a6216ea6dacc71ee8e6b0a5b7322eebc0fdd',
        },
        three: {
            //usdc.e Aave
            vault: '0xf5Ac502C3662c07489662dE5f0e127799D715E1E',
            token: '0xa7d7079b0fead91f3e65f86e8915cb59c1a4c664',
        },
        four: {
            //wbtc benqi
            vault: '0x330cC45c8f60FEF7F9D271a7512542B3d201A48D',
            token: '0x50b7545627a5162f82a992c33b87adc75187b218',
        },
    }
    
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

    let vault = await farmtrollerContract.setInvestmentPool(0, pool.one.vault, pool.one.token);
    await vault.wait()
    console.log('Vault 1 set:', vault.hash)

    vault = await farmtrollerContract.setInvestmentPool(1, pool.two.vault, pool.two.token);
    await vault.wait()
    console.log('Vault 2 set:', vault.hash)

    vault = await farmtrollerContract.setInvestmentPool(2, pool.three.vault, pool.three.token);
    await vault.wait()
    console.log('Vault 3 set:', vault.hash)

    vault = await farmtrollerContract.setInvestmentPool(3, pool.four.vault, pool.four.token);
    await vault.wait()
    console.log('Vault 4 set:', vault.hash)

    const mint = await farmerContract.mintFarmer(10, options );
    await mint.wait();
    console.log('Minted NFT', mint.hash);

    let supply = await farmerContract.getSupply();
    console.log('Current Supply', supply.toNumber())

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