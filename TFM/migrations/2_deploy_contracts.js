var acuerdoInformal = artifacts.require ('./AcuerdoInformal.sol');
var creadorContratos = artifacts.require ('./CreadorContratos.sol');
var gestorAyV = artifacts.require ('./GestorAyV.sol');

module.exports = function(deployer) {
      deployer.deploy(acuerdoInformal);
      deployer.deploy(creadorContratos);
      deployer.deploy(gestorAyV);
}