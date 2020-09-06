# TFMFamilyMediationBlockchain
This is an app that help and improve the family mediation process and is supportb by Blockchain technology.

Prerequisites
- linux Ubuntu >18.04
- npm
- Node.js
- Ganache-CLI (last release)
- Truffle
In this link there is a tutorial to install the previeous package and programs and how connect Ganache with Truffle. They also show how setup Ganache.
https://www.codeooze.com/blockchain/ethereum-dev-environment-2019/
The
- Web3
- Metamask (Chrome Extension)
In this link there is a tutorial to install the previeous extension and how connect with Ganache through Web3. They also show how setup Metamask.
https://www.trufflesuite.com/docs/truffle/getting-started/truffle-with-metamask
The host and port in Ganache must be the same that theconfiguration in truffle-config.js in root directory of the project
When all packache have been installed you can deploy the smart contract (files.sol) in the Contracts directory to Ganache.
From the root directory of the project in cmd console:
- truffle init
- truffle compile
- truffle migrate
If you want deploy again the contracts and rewrite the existent contracts in Ganache:
- truffle migrate --reset --compile-all
If all is right you will see
    Summary
    =======
    > Total deployments:   2
    > Final cost:          0.01188916 ETH
--------------------------------------------

Now you can open Ganache CLI app and see your contracts, accounts, transactions, etc.

To use the app:
- From the root directory of the project in cmd console execute:
    - truffle console
    - var creadorContratos;
    - CreadorContratos.deployed().then(function(instance){creadorContratos = instance});
    - creadorContratos.setGestorDir(addr);   (addr is the smart contract "CreadorContratos" address and you can find it in Ganache interface)
    - exit truffle with ctrl+d o ctrl+c.
    - sudo npm run dev  
    - Open the localhost ip in Google Chrome and you are ready to use the app.
