
const main = async () => {
    // compiles contract and injects dependencies in artifacts dir
    const nftContractFactory = await hre.ethers.getContractFactory('MyEpicNFT');
    // Hardhat creates a local Ethereum network for us
    const nftContract = await nftContractFactory.deploy();
    // Wait until our contract is officially mined and deployed to our local blockchain!
    await nftContract.deployed();
    console.log("Contract deployed to:", nftContract.address);

    // call the function
    let txn = await nftContract.makeAnEpicNFT();
    // wait for it to be mined
    await txn.wait();

    // Mint another NFT for fun.
    txn = await nftContract.makeAnEpicNFT()
    // Wait for it to be mined.
    await txn.wait()
};
  
const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};
  
runMain();