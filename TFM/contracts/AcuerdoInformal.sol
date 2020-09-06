pragma solidity >0.6.0;

import "./GestorAyV.sol";

contract AcuerdoInformal {
    
    address payable[] public validadores;
    address payable public validador;
    address payable public mediador;
    address[] public arbitros;
    mapping (address => bool) public allowedAdresses;
 
    address payable private s1;
    address payable private s2;
    GestorAyV public gestor;

    string public trato;
    string public state;

    bool public accept_p1_s1;
    bool public accept_p1_s2;
    bool public vistoS1;
    bool public vistoS2;

    bool public acuerdo;

    uint public fechaAcuerdo;
    uint public fechaAcuerdo2;
    uint public contadorImpagos = 0;

    //Periodicidades:
    //0 -> Siempre
    //1 -> Semanal
    //2 -> Mensual
    //3 -> Anual
    uint manutencion = 0;
    uint periodicidadMan = 0;
    address payable beneficiarioManutencion;
    uint public fechaUltimoPago;

    //Tipo Propiedad:
    //0 -> Individual
    //1 -> Compartida
    uint tipoProp = 0;
    uint periodicidadProp = 0;
    address payable beneficiarioPropiedad;
    uint public fechaUltimoCambio;

    uint nArbitros;
    uint nValidadores;
    uint hArbitros;
    uint hValidadores;

    mapping (string => bool) public aceptacionesS1;
    mapping (string => bool) public aceptacionesS2;
    mapping (string => bool) public aceptacionesV;
    mapping (string => bool) public aceptacionesM;
 
    //Crea el acuerdo e inicializa los mapas que indican el estado de aceptacion del contrat
    function create( address payable _s1, address payable _s2, GestorAyV _gestoraddr) public  {
        s1 = _s1;
        s2 = _s2; 
        gestor = _gestoraddr;    
        aceptacionesS1['participants'] = false;
        aceptacionesS2['participants'] = false;  
        aceptacionesS1['custodia'] = false;
        aceptacionesS2['custodia'] = false;
        aceptacionesV['custodia'] = false;
        aceptacionesS1['manutencion'] = false;
        aceptacionesS2['manutencion'] = false;
        aceptacionesS1['propiedad'] = false;
        aceptacionesS2['propiedad'] = false;
    }

    //Aceptacion y seleccion del validador y el mediador
    //Requiere un pago de la mitad de los honorarios acordados y solo puede ser llamada por S1 y S2
    function acceptParticipants() public payable{
        //require(msg.value == (hArbitros + hValidadores)/2, 'Not enough Ether');
        //require (msg.sender == s1 || msg.sender == s2, 'You are not in this contract or you dont init session!');
        if(msg.sender == s1){
            aceptacionesS1['participants'] = true;
        }else if(msg.sender == s2){
            aceptacionesS2['participants'] = true;
        } 
        //Mejora: Varios validadores y mediadores
        validadores = gestor.selectParticipants(nArbitros, nValidadores, hArbitros,  hValidadores);
        validador = validadores[0];
        mediador = validadores[1];
    }   

    //Propuesta para acuerdo de validadores y mediadores a participar
    //Requiere un pago de la mitad de los honorarios y solo puede ser llamada por S1 y S2
    function propParticipants(uint _nVal, uint _nMed, uint _hVal, uint _hMed) public payable{   
        //require(msg.value == (_hVal + _hMed)/2, 'Not enough Ether');
        //require (msg.sender == s1 || msg.sender == s2, 'You are not in this contract or you dont init session!');
        if(msg.sender == s1){
            aceptacionesS1['participants'] = true;
            aceptacionesS2['participants'] = false;
            if(hArbitros+hValidadores>0)s2.transfer((hArbitros+hValidadores)/2);
        }else if(msg.sender == s2){
            aceptacionesS1['participants'] = false;
            aceptacionesS2['participants'] = true;
            if(hArbitros+hValidadores>0)s1.transfer((hArbitros+hValidadores)/2);
        }
        nArbitros = _nMed;
        nValidadores = _nVal;
        hArbitros = _hMed;
        hValidadores = _hVal;        
    } 

    function propCustodia(string memory _trato) public{
        //require (msg.sender == s1 || msg.sender == s2 || msg.sender == validador, 'You are not in this contract or you dont init session!');
        trato = _trato;
        if(msg.sender == s1){
            aceptacionesS1['custodia'] = true;
            aceptacionesS2['custodia'] = false;
            aceptacionesV['custodia'] = false;
        }else if(msg.sender == s2){
            aceptacionesS1['custodia'] = false;
            aceptacionesS2['custodia'] = true;
            aceptacionesV['custodia'] = false;
        }else if(msg.sender == validador){
            aceptacionesS1['custodia'] = false;
            aceptacionesS2['custodia'] = false;
            aceptacionesV['custodia'] = true;
        }
    } 


    function acceptCustodia() public{
        //require (msg.sender == s1 || msg.sender == s2 || msg.sender == validador, 'You are not in this contract or you dont init session!');
        if(msg.sender == s1){
            aceptacionesS1['custodia'] = true;
        }else if(msg.sender == s2){
            aceptacionesS2['custodia'] = true;
        }else if(msg.sender == validador){
            aceptacionesV['custodia'] = true;
            //gestor.sendToVote(validador);
        }
    } 

    //Si la parte que propone  se pone como beneficiario se le devuelve el pago que debe ser igual a la manutencion
    function propManutencion(uint _manutencion, address payable _beneficiario, uint _periodicidad) public payable{
        //require (msg.sender == s1 || msg.sender == s2, 'You are not in this contract or you dont init session!');
        //require (_periodicidad > 0 && _periodicidad < 4, 'Periodicidad debe ser un valor entre 0 y 4!'); 1=semanal, 2 = mensual, 3 = anual
        //require (msg-value = _manutencion);
        manutencion = _manutencion;
        periodicidadMan = _periodicidad;
        beneficiarioManutencion = _beneficiario;
        if(msg.sender == _beneficiario){
            msg.sender.transfer(msg.value);
        }
        if(msg.sender == s1){
            aceptacionesS1['manutencion'] = true;
            aceptacionesS2['manutencion'] = false;
        }else if(msg.sender == s2){
            aceptacionesS1['manutencion'] = false;
            aceptacionesS2['manutencion'] = true;
        }
    } 

    //Si la parte que acepta es el beneficiario se le devuelve el pago de la llamada
    function acceptManutencion() public payable{
        //require (msg.sender == s1 || msg.sender == s2, 'You are not in this contract or you dont init session!');
        //require (_periodicidad != 0, 'Aun no hay nada que aceptar');
        if(msg.sender == beneficiarioManutencion){
            msg.sender.transfer(msg.value);
        }
        if(msg.sender == s1){
            aceptacionesS1['manutencion'] = true;
        }else if(msg.sender == s2){
            aceptacionesS2['manutencion'] = true;
        }
    } 

    function propPropiedad(uint _tipoProp, address payable _beneficiario, uint _periodicidad) public{
        //require (msg.sender == s1 || msg.sender == s2, 'You are not in this contract or you dont init session!');
        //require (_periodicidad > 0 && _periodicidad < 4, 'Periodicidad debe ser un valor entre 0 y 4!'); 
        //require (_tipoProp > 0 && _tipoProp < 3, 'Tipo de propiedad debe ser un valor entre 0 y 3!'); 
        tipoProp = _tipoProp;
        periodicidadProp = _periodicidad;
        beneficiarioPropiedad = _beneficiario;
        if(msg.sender == s1){
            aceptacionesS1['propiedad'] = true;
            aceptacionesS2['propiedad'] = false;
        }else if(msg.sender == s2){
            aceptacionesS1['propiedad'] = false;
            aceptacionesS2['propiedad'] = true;
        }
    } 

    function acceptPropiedad() public{
        //require (msg.sender == s1 || msg.sender == s2, 'You are not in this contract or you dont init session!');
        //require (_periodicidad != 0, 'Aun no hay nada que aceptar');
        if(msg.sender == s1){
            aceptacionesS1['propiedad'] = true;
        }else if(msg.sender == s2){
            aceptacionesS2['propiedad'] = true;
        }
    } 

    //Cierre contrato
    function acceptContrato() public{
       //require (msg.sender == s1 || msg.sender == s2 || msg.sender == validador, 'You are not in this contract or you dont init session!'); 
        require (aceptacionesS1['custodia'] && aceptacionesS2['custodia'] && aceptacionesV['custodia']
                && aceptacionesS1['manutencion'] && aceptacionesS2['manutencion']
                && aceptacionesS1['propiedad'] && aceptacionesS2['propiedad'], 'No se han aceptado todas las clausulas');
        acuerdo = true;
        validador.transfer(hValidadores);
        mediador.transfer(hArbitros);
        fechaAcuerdo = block.timestamp;
        fechaUltimoCambio = block.timestamp;
        //notificar a gestor direcciones para que les devuelva su deposito
        gestor.returnDeposito(validador,mediador);
    }

    //funcion que registra impapago e base a la fecha ultimo pago
    //Mejora: Utilizar los valores de periodicidad para hacer una comprobación diaria, semanal, mensual, 
    function setImpago() public{
        require(((block.timestamp - fechaUltimoPago) / 60 / 60 / 24)> 30);
        contadorImpagos += 1;
    }

    //Regula un impago al comprobar si se hacen 2 pagos en el mismo dia
    function pagoManutencion() public payable{
        //require(msg.sender != beneficiarioManutencion && (msg.sender == s1 || msg.sender == s2) && msg.value == manutencion);
        beneficiarioManutencion.transfer(msg.value);
        if(((block.timestamp - fechaUltimoPago) / 60 / 60 / 24) < 1){
            contadorImpagos -= 1;
        }
        fechaUltimoPago = block.timestamp;
    }
 
    //Cambia el propietario si ya ha pasado el tiempo acordado en periodicidad
    //Mejora: Utilizar los distintos valores de periodicidad
    function cambiaPropiedad() public{
        require((msg.sender == s1 || msg.sender == s2) && ((block.timestamp - fechaUltimoPago) / 60 / 60 / 24) < 30);
        beneficiarioPropiedad = beneficiarioPropiedad == s1 ? s2 : s1;
    }

    function  getParticipantsAccepts() public view returns (uint, uint, uint, uint, bool , bool) {
        return (nArbitros,nValidadores,hArbitros,hValidadores, aceptacionesS1['participants'], aceptacionesS2['participants']);
    }

    function  getCustodiaAccepts() public view returns (string memory, bool, bool, bool) {
        return (trato, aceptacionesS1['custodia'], aceptacionesS2['custodia'],aceptacionesV['custodia']);
    }

    function  getManutencionAccepts() public view returns (uint, uint, address , bool, bool) {
        return (manutencion, periodicidadMan, beneficiarioManutencion, aceptacionesS1['manutencion'], aceptacionesS2['manutencion']);
    }

    function  getPropiedadAccepts() public view returns (uint, uint,address , bool, bool) {
        return (tipoProp, periodicidadProp, beneficiarioPropiedad, aceptacionesS1['propiedad'], aceptacionesS2['propiedad']);
    }

    function getParticipantes() public view returns (address, address, address, address) {
        return (s1, s2, validador, mediador);
    }

    function getAceptacionTotal() public view returns (bool, uint, bool, uint) {
        return (acuerdo, fechaAcuerdo, fechaAcuerdo < fechaAcuerdo2, (block.timestamp - fechaAcuerdo2) / 60 / 60 / 24 );
    }
/*
    //Mejora formatear la fecha en javascript para mostrar fecha legible
    function getFechaAcuerdo() public view returns (string memory) {
        return fechaAcuerdo;
    }

    function getFechaDesacuerdo() public view returns (string memory) {
        return fechaDesacuerdo;
    }
*/
}
