App = {
    web3Provider: null,
    contracts: {},
    tratoActual: null,
    currentContractAddress: null,
    instanceGL: null,
    creaContract: null,
    accountGL: null,
    sumHonorarios:null,
    manut:null,
    //Conectamos con los contratos
    init: async function() {
        $.getJSON('AcuerdoInformal.json', function(data) {
            // Get the necessary contract artifact file and instantiate it with truffle-contract
            var AdoptionArtifact = data;
            App.contracts.AcuerdoInformal = TruffleContract(AdoptionArtifact);
            
            // Set the provider for our contract
            App.contracts.AcuerdoInformal.setProvider(App.web3Provider);
        });
    
        $.getJSON('CreadorContratos.json', function(data) {
            var AdoptionArtifact = data;
            App.contracts.CreadorContratos = TruffleContract(AdoptionArtifact);
            
            App.contracts.CreadorContratos.setProvider(App.web3Provider);
        });

        $.getJSON('GestorAyV.json', function(data) {
            var AdoptionArtifact = data;
            App.contracts.GestorAyV = TruffleContract(AdoptionArtifact);
            
            App.contracts.GestorAyV.setProvider(App.web3Provider);
        }); 

        return await App.initWeb3();
    },
    //Conectamos con la red
    initWeb3: async function() {
        // Modern dapp browsers...
        if (window.ethereum) {
            App.web3Provider = window.ethereum;
            try {
            // Request account access
            await window.ethereum.enable();
            } catch (error) {
            // User denied account access...
            console.error("User denied account access")
            }
        }
        // Legacy dapp browsers...
        else if (window.web3) {
            App.web3Provider = window.web3.currentProvider;
        }
        // If no injected web3 instance is detected, fall back to Ganache
        else {
            App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
        }
        web3 = new Web3(App.web3Provider);

        return App.initContract();
    },
  
    initContract: function() {
      return App.bindEvents();
    },
    
    //Recoge los eventos de los botones
    bindEvents: function() {
        $(document).on('click', '.btn-crearContrato', App.createContract);
        $(document).on('click', '.btn-getContract', App.getContract); 
        $(document).on('click', '.btn-getLastContract', App.getLastContract);
        $(document).on('click', '.btn-regVal', App.regValidador);
        $(document).on('click', '.btn-regMed', App.regMediador);
        $(document).on('click', '.btn-aceptVals', App.acceptVals);
        $(document).on('click', '.btn-propVals', App.propVals);
        $(document).on('click', '.btn-acceptCustodia', App.acceptCustodia);
        $(document).on('click', '.btn-propCustodia', App.propCustodia);
        $(document).on('click', '.btn-acceptMan', App.acceptMan);
        $(document).on('click', '.btn-propMan', App.propMan);
        $(document).on('click', '.btn-acceptProp', App.acceptProp);
        $(document).on('click', '.btn-propProp', App.propProp);
    },
    
    //Devuelve el contrato indicado 
    getContract: function(){
        event.preventDefault();
        App.currentContractAddress = document.getElementById('contrato').value;
        console.log(App.currentContractAddress);
        instanceGL = App.contracts.AcuerdoInformal.at(App.currentContractAddress);
        return App.getTrato();
    },

    createContract: function(event) {
        event.preventDefault();        
        var s1 = document.getElementById('cuentaS1').value;
        var s2 = document.getElementById('cuentaS2').value;
        console.log('s1'+s1);
        console.log('s2'+s2);    
        App.contracts.CreadorContratos.deployed().then(function(instance){
             instance.createContract(s1,s2);           
        }).catch(function(err) {
            console.log('Error in creation '+err.message);
        });       
    },

    getLastContract: function(event) {
        event.preventDefault();
        console.log('lastCont');
        var promiseDir = new Map();
        App.contracts.CreadorContratos.deployed().then(function(instance){            
            promiseDir['dirContratoDevuelta'] = instance.getLastContractAddress.call();  
            return promiseDir;
        }).then(function(promiseDir) {             
            promiseDir['dirContratoDevuelta'].then(function(dirContratoDevuelta){
                console.log(dirContratoDevuelta);
                document.getElementById("dirContratoDevuelta").innerHTML = dirContratoDevuelta;
            });                 
        }).catch(function(err) {
          console.log(err.message);
        });  
    },

    regValidador: function(event){
        event.preventDefault();
        var gMax = document.getElementById('gMax').value;
        var gMin = document.getElementById('gMin').value;
        var dp1 = document.getElementById('dp1').value;
        App.contracts.GestorAyV.deployed().then(function(instance){
            instance.setValidador(gMax,gMin,dp1, {value:dp1});           
        }).catch(function(err) {
           console.log('Error in creation '+err.message);
        });
    },

    regMediador: function(event){
        event.preventDefault();
        var gMax = document.getElementById('gMax').value;
        var gMin = document.getElementById('gMin').value;
        var dp1 = document.getElementById('dp1').value;
        var dp2 = document.getElementById('dp2').value;
        var sum = parseInt(dp1) + parseInt(dp2);
      
        App.contracts.GestorAyV.deployed().then(function(instance){
            instance.setMediador(gMax,gMin,dp1,dp2,{value:sum});           
        }).catch(function(err) {
           console.log('Error in creation '+err.message);
        });
    },

    acceptVals: function(event){
        event.preventDefault();
        App.contracts.AcuerdoInformal.at(App.currentContractAddress).then(function(instance) {
            
            instance.acceptParticipants({value:App.sumHonorarios});
            console.log('dd');
        }).catch(function(err) {
           console.log('Error in creation '+err.message);
        });
    },

    propVals: function(event){
        event.preventDefault();
        var nVal = document.getElementById('nVal').value;
        var nMed = document.getElementById('nMed').value;
        var hVal = document.getElementById('hVal').value;
        var hMed = document.getElementById('hMed').value;
        var sum = (parseInt(hVal) + parseInt(hMed))/2;
        App.contracts.AcuerdoInformal.at(App.currentContractAddress).then(function(instance) {
            instance.propParticipants(nVal,nMed,hVal,hMed, {value:sum});
            console.log('propPart');
        }).catch(function(err) {
           console.log('Error in creation '+err.message);
        });       
    },

    acceptCustodia: function(event){
        event.preventDefault();
        App.contracts.AcuerdoInformal.at(App.currentContractAddress).then(function(instance) {            
            instance.acceptCustodia();
            console.log('ddCus');
        }).catch(function(err) {
           console.log('Error in creation '+err.message);
        });
    },

    propCustodia: function(event){
        event.preventDefault();
        var custodia = document.getElementById('custodia').value;
        App.contracts.AcuerdoInformal.at(App.currentContractAddress).then(function(instance) {
            instance.propCustodia(custodia);
            console.log('propcus');
        }).catch(function(err) {
           console.log('Error in creation '+err.message);
        });
        
    },

    acceptMan: function(event){
        event.preventDefault();
        App.contracts.AcuerdoInformal.at(App.currentContractAddress).then(function(instance) {            
            instance.acceptManutencion({value:App.manut});
            console.log('ddCus');
        }).catch(function(err) {
           console.log('Error in creation '+err.message);
        });
    },

    propMan: function(event){
        event.preventDefault();
        var manutencion = document.getElementById('manutencion').value;
        var periodMan = document.getElementById('periodMan').value;
        var benefMan = document.getElementById('benefMan').value;
        App.contracts.AcuerdoInformal.at(App.currentContractAddress).then(function(instance) {
            instance.propManutencion(manutencion,benefMan,periodMan,{value:manutencion});
            console.log('propcus2');
        }).catch(function(err) {
           console.log('Error in creation '+err.message);
        });
        
    },

    acceptProp: function(event){
        event.preventDefault();
        App.contracts.AcuerdoInformal.at(App.currentContractAddress).then(function(instance) {            
            instance.acceptPropiedad();
            console.log('ddCus');
        }).catch(function(err) {
           console.log('Error in creation '+err.message);
        });
    },

    propProp: function(event){
        event.preventDefault();
        var tipo = document.getElementById('propiedad').value;
        var periodMan = document.getElementById('periodProp').value;
        var benefMan = document.getElementById('benefProp').value;
        App.contracts.AcuerdoInformal.at(App.currentContractAddress).then(function(instance) {
            instance.propPropiedad(tipo,benefMan,periodMan);
            console.log('propcus2');
        }).catch(function(err) {
           console.log('Error in creation '+err.message);
        });
        
    },

    getTrato: function() {
        var infoTrato = new Map();
        //location.href = 'contrato.html';
        App.contracts.AcuerdoInformal.at(App.currentContractAddress).then(function(instance) {           
            infoTrato['participants']=instance.getParticipantes.call();
            infoTrato['acceptsParticipants']=instance.getParticipantsAccepts.call();
            infoTrato['custodia']=instance.getCustodiaAccepts.call();
            infoTrato['manutencion']=instance.getManutencionAccepts.call();
            infoTrato['propiedad']=instance.getPropiedadAccepts.call(); 
            return infoTrato;
        }).then(function(trato) { 
            trato['acceptsParticipants'].then(function(acceptsParticipants){
                document.getElementById("acceptsParticipants").innerHTML =  'Nº Arbitros: '+acceptsParticipants[0]+
                                                                            ' Nº validadores: '+acceptsParticipants[1]+
                                                                            ' Honorarios Mediadores: '+acceptsParticipants[2]+
                                                                            ' Honorarios Validadores: '+acceptsParticipants[3]+
                                                                            ' Aceptacion participantes -> S1: '+acceptsParticipants[4]+
                                                                            ' S2: '+acceptsParticipants[5];
                App.sumHonorarios = (parseInt(acceptsParticipants[2]) + parseInt(acceptsParticipants[3]))/2
            });
            trato['participants'].then(function(participants){
                document.getElementById("participants").innerHTML = 'S1: '+participants[0]+
                                                                    ' <br>S2: '+participants[1]+
                                                                    ' <br>Validador: '+participants[2]+
                                                                    ' <br>Mediador: '+participants[3];
            });
            trato['custodia'].then(function(custodia){
                document.getElementById("custodia1").innerHTML = 'Custodia: '+custodia[0]+
                                                                    ' Aceptacion participantes -> S1: '+custodia[1]+
                                                                    ' S2:  '+custodia[2]+
                                                                    ' Validador '+custodia[3];
            });
            trato['manutencion'].then(function(manutencion){
                document.getElementById("manutencion1").innerHTML = 'Manutencion: '+manutencion[0]+
                                                                    ' Periodicidad: '+manutencion[1]+
                                                                    ' Beneficiario: '+manutencion[2]+
                                                                    ' Aceptacion participantes -> S1: '+manutencion[3]+
                                                                    ' S2:  '+manutencion[4];
                App.manut = manutencion[0];
            });
            trato['propiedad'].then(function(propiedad){
                document.getElementById("propiedad1").innerHTML =   'Tipo propiedad: '+propiedad[0]+
                                                                    ' Periodicidad: '+propiedad[1]+
                                                                    ' Beneficiario: '+propiedad[2]+
                                                                    ' Aceptacion participantes -> S1: '+propiedad[3]+
                                                                    ' S2:  '+propiedad[4];
            });                   
        }).catch(function(err) {
          console.log(err.message);
        });       
    }, 
};
  
$(function() {
    $(window).load(function() {
      App.init();
    });
});