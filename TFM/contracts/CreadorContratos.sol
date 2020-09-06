pragma solidity >0.6.0;

import "./AcuerdoInformal.sol";
import "./GestorAyV.sol";

contract CreadorContratos {

    uint public totalContracts;
    address[] public contracts;        
    GestorAyV public gestor;

    //Crea instancia AcuerdoInformal con los separados S1 y S2.
    //Le pasa la direccion del contrato Gestor y guarda la direccion de la instancia creada de Acuerdo Informal
    function createContract (address payable S1, address payable S2) public{       
        address newContract = address(new AcuerdoInformal());
        AcuerdoInformal instance = AcuerdoInformal(newContract);
        instance.create(S1,S2,gestor);
        contracts.push(newContract);
        totalContracts = contracts.length;              
    } 

    //Añadir la direccion del contrato GestorAyV manualmente al desplegar los contratos
    function setGestorDir(address addr) public {
        gestor = GestorAyV(addr);
    }

    //devuelve nº total de contratos instancia creados
    function getContractsNumber() public view returns (uint) {
        return totalContracts;
    }

    //devuelve la direccion del ultimo contrato creado 
    //Mejora1: devolver una clave amigable relacionada con cada dir de contrato
    //Mejora2: devolver una lista de todos los contratos relacionados con un usuario
    function getLastContractAddress() public view returns (address) {
        return contracts[totalContracts-1];
    }

    //Mejora: Funcion para recuperar valores antiguos de un contrato
    /*
    function getOldStateOfContract(address instanceInformal, nBlock) public view returns (address) {
        1.Get instance
        2. Call function instance .call(nBlock) -> Devuelve el estado en el bloque indicado
    }
    */
}