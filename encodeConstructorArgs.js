const { ethers } = require("ethers");

// Function to encode constructor arguments
function encodeConstructorArgs(types, values) {
  return ethers.utils.defaultAbiCoder.encode(types, values);
}

const typesA = ["string", "string", "uint8", "address", "address"];
const valuesA = ["Wrapped Ethereum", "WETH", 18, "0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889", "0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889"]; // Replace with actual addresses
const encodedArgsA = encodeConstructorArgs(typesA, valuesA);
console.log(`Encoded Constructor Args for Contract A: ${encodedArgsA}`);

const typesB = ["string", "string", "uint8", "address", "address"];
const valuesB = ["Wrapped Bitcoin", "WBTC", 18, "0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063", "0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063"]; // Replace with actual values
const encodedArgsB = encodeConstructorArgs(typesB, valuesB);
console.log(`Encoded Constructor Args for Contract B: ${encodedArgsB}`);

const typesC = ["address", "address"];
const valuesC = ["0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2", "0x2260fac5e5542a773aa44fbcfedf7c193bc2c599"]; // Replace with actual values
const encodedArgsC = encodeConstructorArgs(typesC, valuesC);
console.log(`Encoded Constructor Args for Contract C: ${encodedArgsC}`);

const typesD = ["address"];
const valuesD = ["0xDcfb9aE8688E932aA48bF25968BF2f5CD93551cC"]; // Replace with actual values
const encodedArgsD = encodeConstructorArgs(typesD, valuesD);
console.log(`Encoded Constructor Args for Contract D: ${encodedArgsD}`);

const typesE = ["address", "address", "address"];
const valuesE = ["0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2", "0x2260fac5e5542a773aa44fbcfedf7c193bc2c599", "0xDcfb9aE8688E932aA48bF25968BF2f5CD93551cC"]; // Replace with actual values
const encodedArgsE = encodeConstructorArgs(typesE, valuesE);
console.log(`Encoded Constructor Args for Contract E: ${encodedArgsE}`);
