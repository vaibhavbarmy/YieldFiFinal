# YieldFiFinal
Assignment : Create a simplified version of aave v2 prptocol

nvm install 18
nvm use 18
mkdir YieldFiFinal
cd YielFiFinal
npm init -y
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox
npm instal dotenv
npx hardhat
> select Create an empty hardhat.config.j
> Create a .env file

npx hardhat compile
npx hardhat run scripts/deploy.js --network sepolia

DataType deployed to: 0xf7f1C1b5F28a5190a21F12a5a3235141afE5767C
MathErrors deployed to: 0x105315dECc761c6D1Cc8b263fe065D089D7BFeFC
SafeMath deployed to: 0x9AF6035C3d31B234757F93e4dFffc4D00CAF5039
Address deployed to: 0x7DdC999321979B19C426D08e1e4178B02024611F
WadRayMath deployed to: 0xB9a3ccf576C6d9319a4138e964C7239116C25D78
PercentageMath deployed to: 0xBd9E3166edf2eE9e0ba99dED595c5b402eDc6fE7
MathUtils deployed to: 0xE04803dAAB2369e615DB900379305C6d64a077a3
SafeERC20 deployed to: 0x6b4d852e9F3A009b4728631800d4401527C500A3
AToken deployed to: 0x962b6aD55f41F04Af6E60C46F21a1A067679BF63
DebtToken deployed to: 0x01d73159D902A29611385E91FE5291a1B0D1bFb1
YieldFiAdmin deployed to: 0xB441Cf957216D0B7EbE84785d0C76CA3B78fA013
YieldFiFlashLoan deployed to: 0xfBf527eA15D3FC78759123A9AB61C2a372631c54
YieldFiCollateral deployed to: 0xc541a746cc38D08922D2c4a9b4104018b433D8ed
YieldFiCalculations deployed to: 0xb8b0550680BF6E4B319F0E96ea48dc6355cD1F74
YieldFiCore deployed to: 0x0834891B4762A77d679cAA4498aF359E8Dab08F0
Deployment completed successfully.

npm install ethers
node encodeConstructorArgs.js
Encoded Constructor Args for Contract A: 0x00000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e000000000000000000000000000000000000000000000000000000000000000120000000000000000000000009c3c9283d3e44854697cd22d3faa240cfb0328890000000000000000000000009c3c9283d3e44854697cd22d3faa240cfb03288900000000000000000000000000000000000000000000000000000000000000105772617070656420457468657265756d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000045745544800000000000000000000000000000000000000000000000000000000
Encoded Constructor Args for Contract B: 0x00000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e000000000000000000000000000000000000000000000000000000000000000120000000000000000000000008f3cf7ad23cd3cadbd9735aff958023239c6a0630000000000000000000000008f3cf7ad23cd3cadbd9735aff958023239c6a063000000000000000000000000000000000000000000000000000000000000000f5772617070656420426974636f696e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000045742544300000000000000000000000000000000000000000000000000000000
Encoded Constructor Args for Contract C: 0x000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc20000000000000000000000002260fac5e5542a773aa44fbcfedf7c193bc2c599
Encoded Constructor Args for Contract D: 0x000000000000000000000000dcfb9ae8688e932aa48bf25968bf2f5cd93551cc
Encoded Constructor Args for Contract E: 0x000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc20000000000000000000000002260fac5e5542a773aa44fbcfedf7c193bc2c599000000000000000000000000dcfb9ae8688e932aa48bf25968bf2f5cd93551cc

Note:
I was able to verify and publish code of every smart code on etherscan sepolia network except YieldFiCore. Since it was my first attempt most of the code written was using Qwen2.5-Coder-demo huggingface model which is a state of art generative ai model by alibaba cloud which performs best while writing code.

As the code written is by Generative AIs I understand its not production grade and will lack to run coherently together also if it can be used then major flaws are there in terms of security of smart contract etc

Most of the code is just a shell of how functionalities in aave v2 protocol can be implemented in forms of variables nad functions

At the end of the day I really loved these 7-8 days and if you are satisfied that I can pick up any new programming language as a polyglot and have the passion to do epic shit in blockchain ecosystem over the next decade then please lets take this further and get on a call

Even if you doesn't see me fit I would anyways would like to stay in touch and let me know in a simple paragraph like writeup why and where the submitted code block lacks
