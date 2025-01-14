const hre = require("hardhat");

async function main() {
    // Step 1: Deploy libraries

    // Deploy DataType
    const DataTypes = await hre.ethers.getContractFactory("DataTypes");
    const dataTypes = await DataTypes.deploy();
    await dataTypes.deployed();
    console.log("DataType deployed to:", dataTypes.address);

    // Deploy MathErrors
    const MathErrors = await hre.ethers.getContractFactory("MathErrors");
    const mathErrors = await MathErrors.deploy();
    await mathErrors.deployed();
    console.log("MathErrors deployed to:", mathErrors.address);

    // Deploy SafeMath
    const SafeMath = await hre.ethers.getContractFactory("SafeMath");
    const safeMath = await SafeMath.deploy();
    await safeMath.deployed();
    console.log("SafeMath deployed to:", safeMath.address);

    // Deploy Address
    const Address = await hre.ethers.getContractFactory("Address");
    const addressLib = await Address.deploy();
    await addressLib.deployed();
    console.log("Address deployed to:", addressLib.address);

    // Deploy WadRayMath
    const WadRayMath = await hre.ethers.getContractFactory("WadRayMath");
    const wadRayMath = await WadRayMath.deploy();
    await wadRayMath.deployed();
    console.log("WadRayMath deployed to:", wadRayMath.address);

    // Deploy PercentageMath
    const PercentageMath = await hre.ethers.getContractFactory("PercentageMath");
    const percentageMath = await PercentageMath.deploy();
    await percentageMath.deployed();
    console.log("PercentageMath deployed to:", percentageMath.address);

    // Step 2: Deploy MathUtils
    const MathUtils = await hre.ethers.getContractFactory("MathUtils");
    const mathUtils = await MathUtils.deploy();
    await mathUtils.deployed();
    console.log("MathUtils deployed to:", mathUtils.address);

    // Step 3: Deploy SafeERC20
    const SafeERC20 = await hre.ethers.getContractFactory("SafeERC20");
    const safeERC20 = await SafeERC20.deploy();
    await safeERC20.deployed();
    console.log("SafeERC20 deployed to:", safeERC20.address);

    // Step 4: Deploy AToken and DebtToken
    const AToken = await hre.ethers.getContractFactory("AToken");
    const aTokenName = "Wrapped Ethereum";
    const aTokenSymbol = "WETH";
    const aTokenDecimals = 18;
    const aTokenUnderlyingAssetAddress = "0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889";
    const aTokenCoreContractAddress = "0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889"; // aWETH Replace with the actual core contract address
    const aToken = await AToken.deploy(aTokenName, aTokenSymbol, aTokenDecimals, aTokenUnderlyingAssetAddress, aTokenCoreContractAddress);
    await aToken.deployed();
    console.log("AToken deployed to:", aToken.address);

    const DebtToken = await hre.ethers.getContractFactory("DebtToken");
    const debtTokenName = "Wrapped Bitcoin";
    const debtTokenSymbol = "WBTC";
    const debtTokenDecimals = 18;
    const debtTokenUnderlyingAssetAddress = "0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063";
    const debtTokenCoreContractAddress = "0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063"; // aWBTC
    const debtToken = await DebtToken.deploy(debtTokenName, debtTokenSymbol, debtTokenDecimals, debtTokenUnderlyingAssetAddress, debtTokenCoreContractAddress);
    await debtToken.deployed();
    console.log("DebtToken deployed to:", debtToken.address);

    // Step 5: Deploy YieldFiAdmin
    const ethOracleAddress = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"; // Replace with actual ETH Oracle address
    const wbtcOracleAddress = "0x2260fac5e5542a773aa44fbcfedf7c193bc2c599"; // Replace with actual WBTC Oracle address
    const YieldFiAdmin = await hre.ethers.getContractFactory("YieldFiAdmin");
    const yieldFiAdmin = await YieldFiAdmin.deploy(ethOracleAddress, wbtcOracleAddress);
    await yieldFiAdmin.deployed();
    console.log("YieldFiAdmin deployed to:", yieldFiAdmin.address);

    // Step 6: Deploy YieldFiFlashLoan
    const lendingPoolAddress = "0xDcfb9aE8688E932aA48bF25968BF2f5CD93551cC"; // Replace with actual Lending Pool address
    const YieldFiFlashLoan = await hre.ethers.getContractFactory("YieldFiFlashLoan");
    const yieldFiFlashLoan = await YieldFiFlashLoan.deploy(lendingPoolAddress);
    await yieldFiFlashLoan.deployed();
    console.log("YieldFiFlashLoan deployed to:", yieldFiFlashLoan.address);

    // Step 7: Deploy YieldFiCollateral
    const YieldFiCollateral = await hre.ethers.getContractFactory("YieldFiCollateral");
    const yieldFiCollateral = await YieldFiCollateral.deploy(yieldFiAdmin.address);
    await yieldFiCollateral.deployed();
    console.log("YieldFiCollateral deployed to:", yieldFiCollateral.address);

    // Step 8: Deploy YieldFiCalculations
    const YieldFiCalculations = await hre.ethers.getContractFactory("YieldFiCalculations");
    const yieldFiCalculations = await YieldFiCalculations.deploy(yieldFiCollateral.address, yieldFiFlashLoan.address, yieldFiAdmin.address);
    await yieldFiCalculations.deployed();
    console.log("YieldFiCalculations deployed to:", yieldFiCalculations.address);

    // Step 9: Deploy YieldFiCore
    const YieldFiCore = await hre.ethers.getContractFactory("YieldFiCore");
    const yieldFiCore = await YieldFiCore.deploy(
        ethOracleAddress,
        wbtcOracleAddress,
        lendingPoolAddress
    );
    await yieldFiCore.deployed();
    console.log("YieldFiCore deployed to:", yieldFiCore.address);

    console.log("Deployment completed successfully.");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });