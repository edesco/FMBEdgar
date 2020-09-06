pragma solidity >0.6.0;

import "./AcuerdoInformal.sol";

contract GestorAyV {

    //mapa de dir cuenta -> perfil validador
    mapping(address => Participant) public validadoresMap;
    //mapa de dir cuenta -> perfil mediador
    mapping(address => Participant) public mediadoresMap;
    //Direcciones payable de validadores y mediadores
    address payable[] public validadoresAccts;
    address payable[] public mediadoresAccts;
    //Mapa de direcciones validadas por una autoridad legal
    mapping (address => bool) public allowedAdresses;

    //Estructura para guardar el perfil de cada validador
    struct Participant{
        address addr;
        uint gananciaMax;
        uint gananciaMin;
        uint prcgAciertos;
        uint deposito1;
        uint deposito2;
        uint participaciones;
        string typeParticipant;
    }

    //Para añadir una dirección permitida
    function setAllowedAddress(address _addr) public{
        allowedAdresses[_addr] = true;
    }

    //funcion contains() para comprobar
    function contains(address _addr) internal returns (bool){
        return allowedAdresses[_addr];
    }

    //funcion mejora para usar varios validadores
    /*function selectValidador(uint _nArb, uint _nVal, uint _hArb, uint _hVal) public  view returns(address){
        address valToAdd;
        for(uint i=0; i<validadoresAccts.length; i++){
            if(validadoresMap[validadoresAccts[i]].gananciaMax <= _hVal && validadoresMap[validadoresAccts[i]].gananciaMin >= _hVal ){
                valToAdd = validadoresAccts[i];
                break;
            }
        }
       //reordenar validadoresAccts en funcion de sus participaciones
       return valToAdd;       
    }

    function selectMediador(uint _nArb, uint _nVal, uint _hArb, uint _hVal) public  view returns(address){
        address valToAdd;
        for(uint i=0; i<mediadoresAccts.length; i++){
            if(mediadoresMap[mediadoresAccts[i]].gananciaMax >= _hArb && mediadoresMap[mediadoresAccts[i]].gananciaMin <= _hArb ){
                valToAdd = mediadoresAccts[i];
                break;
            }
        }
       //reordenar validadoresAccts en funcion de sus participaciones
       return valToAdd;       
    }*/

    //Registro de un validador en la app
    function setValidador(uint _gMax, uint _gMin, uint _dp1) public payable{
        //require(contains(msg.sender), 'Account not identified');
        //require(msg.value == _dp1, 'Not enough ether');
        require(_gMax <= 7, 'Not enough ether');
        Participant storage participant = validadoresMap[msg.sender]; 
        participant.addr = msg.sender;
        participant.gananciaMax = _gMax;
        participant.gananciaMin = _gMin;
        participant.prcgAciertos = 0;
        participant.typeParticipant = 'Validador';
        participant.deposito1 = _dp1;
        participant.deposito2 = 0;
        participant.participaciones = 0;
        
        validadoresAccts.push(msg.sender);
    }

    //Registro de un mediador en la app
    function setMediador(uint _gMax, uint _gMin, uint _dp1, uint _dp2) public payable{
        require(contains(msg.sender), 'Account not identified');
        //require(msg.value == _dp1 + _dp2, 'Not enough ether');
        require(_gMax <= 7, 'Not enough ether');
       
        Participant storage participant = mediadoresMap[msg.sender]; 
        participant.addr = msg.sender;
        participant.gananciaMax = _gMax;
        participant.gananciaMin = _gMin;
        participant.prcgAciertos = 0;
        participant.typeParticipant = 'Mediador';
        participant.deposito1 = _dp1;
        participant.deposito2 = _dp2;
        participant.participaciones = 0;
        
        mediadoresAccts.push(msg.sender);
    }

    //devuelve el perfil de un validador
    //Mejora1: duplicar para mediadores y mostrar en UI
    function getInstructor(address ins) public view returns (address, uint, uint, uint, uint, uint) {
        return (    validadoresMap[ins].addr,
                    validadoresMap[ins].gananciaMax, 
                    validadoresMap[ins].gananciaMin,
                    validadoresMap[ins].prcgAciertos,
                    validadoresMap[ins].deposito1, 
                    validadoresMap[ins].deposito2                  
                );
    }

    //Selecciona el validador y el mediador en base al criterio de ganancia max.
    //Mejora1: Utilizar los demas criterios (%acertos, nº de participaciones)
    function selectParticipants(uint _nArb, uint _nVal, uint _hArb, uint _hVal) public  view returns(address payable[] memory){
        address payable[] memory dirsToAdd = new address payable[](2);
        for(uint i=0; i<validadoresAccts.length; i++){
            if(validadoresMap[validadoresAccts[i]].gananciaMax >= _hVal && validadoresMap[validadoresAccts[i]].gananciaMin <= _hVal ){
                dirsToAdd[0] = validadoresAccts[i];
                break;
            }
        }
        for(uint i=0; i<mediadoresAccts.length; i++){
            if(mediadoresMap[mediadoresAccts[i]].gananciaMax >= _hArb && mediadoresMap[mediadoresAccts[i]].gananciaMin <= _hArb ){
                dirsToAdd[1] = mediadoresAccts[i];
                break;
            }
        }
       //Mejora 2: reordenar validadoresAccts en funcion de sus participaciones para equilibrar quien participa
       return dirsToAdd;       
    }

    function returnDeposito(/*address payable[] memory dirs*/ address payable validador, address payable  mediador) public{
        //Mejora: Para varios validadores y mediadores
        /*for(uint i=0; i<dirs.length; i++){
            if(validadoresMap[dirs[i]] != 0){
                dirs[i].transfer(validadoresMap[dirs[i]].deposito1 + validadoresMap[dirs[i]].deposito2);
            }else if(mediadoresMap[dirs[i]] != 0){
                dirs[i].transfer(mediadoresMap[dirs[i]].deposito1 + mediadoresMap[dirs[i]].deposito2);
            }
        }*/
        validador.transfer(validadoresMap[validador].deposito1);
        mediador.transfer(mediadoresMap[validador].deposito1 + mediadoresMap[validador].deposito2);
    }
    

    function sendToVote(address payable[] memory dirs) public{

    }
    
}

