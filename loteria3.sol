// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Loteria {
    address public owner;
    uint public constant ticketPrice = 1 ether; // Precio de cada ticket en ethers
    uint public constant totalTickets = 1000; // Total de tickets disponibles
    mapping(address => uint) public ticketsSold; // Almacenar los números de los tickets vendidos relacionados con las cuentas que los compraron
    uint public ganadorNumero;
    address public ganadorDireccion;

    event TicketComprado(address comprador, uint numeroTicket);
    event GanadorElegido(uint numeroGanador, address ganador);
    event PremioRetirado(address ganador, uint premio);

    constructor() {
        owner = msg.sender;
    }

    // Comprar tickets
    function comprarTicket(uint _numeroTicket) public payable {
        require(msg.value == ticketPrice, "Debe enviar 1 ether para comprar un ticket");
        require(_numeroTicket >= 1 && _numeroTicket <= totalTickets, "Numero de ticket invalido");
        require(ticketsSold[msg.sender] == 0, "Ya has comprado un ticket");
        
        ticketsSold[msg.sender] = _numeroTicket;
        emit TicketComprado(msg.sender, _numeroTicket);
    }


    // Sortear ganador
    function sortearGanador() public {
        require(msg.sender == owner, "Solo el propietario puede sortear un ganador");
        
        // Generar número aleatorio
        ganadorNumero = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % totalTickets + 1;
        
        // Buscar al ganador
        ganadorDireccion = getKeyByValue(ticketsSold, ganadorNumero);
        
        emit GanadorElegido(ganadorNumero, ganadorDireccion);
    }



    // Función auxiliar para obtener la clave del mapeo a partir del valor
    function getKeyByValue(mapping(address => uint) storage map, uint value) internal view returns(address) {
        for (uint i = 1; i <= totalTickets; i++) {
            if (map[msg.sender] == value) {
                return msg.sender;
            }
        }
        revert("No se encontro el valor especificado");
    }


    // Función para revisar si un ticket ha sido vendido
    function revisaTicketVendido(uint _numeroTicket) public view returns (bool) {
        return ticketsSold[msg.sender] == _numeroTicket;
    }

    // Función para retirar el premio
    function retiraPremio() public {
        require(msg.sender == ganadorDireccion, "Solo el ganador puede retirar el premio");
        require(address(this).balance > 0, "No hay fondos para retirar");
        payable(ganadorDireccion).transfer(address(this).balance);
        emit PremioRetirado(ganadorDireccion, address(this).balance);
    }

    // Función para que el propietario pueda retirar los fondos no reclamados
    function retirarFondos() public {
        require(msg.sender == owner, "Solo el propietario puede retirar los fondos");
        require(address(this).balance > 0, "No hay fondos para retirar");
        payable(owner).transfer(address(this).balance);
    }
    
}
