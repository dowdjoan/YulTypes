// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


contract Yultypes {
    
    // Lo que realmente se ejecuta en la máquina virtual Ethereum es el código de bytes.
    // Esta es la salida del compilador de solidez y eso es lo que se almacena en la cadena de bloques.

    // assembly: ejecuciones de bajo nivel


    function getHex() external pure returns(uint256) {
        uint256 x;

        assembly {
            x := 0xa
        }
        return x;
    }

    function demoString() external pure returns(bytes32) {
        bytes32 myString = "";

        assembly {
            myString := "Joan"
        }

        return myString;
    }

    function representation () external pure returns(uint32) {
        uint16 x;

        assembly {
            x := 1
        }

        return x;
    }

    function representationAddress() external pure returns(address) {
        address x;

        assembly {
            x := 1
        }

        return x;
    }

    function negation() external pure returns(uint256 result) {
        result = 1;

        assembly {
            if iszero(0) {
                result := 2
            }
        }
        return result;
    }

    function negacionInsegura1() external pure returns(uint256 result) {
        result = 1;
        // no se recomienda usar este tipo  de negacion
        assembly {
            if not(0) { // true
                result := 2
            }
        }
        return result;  // return 2
    }

    function invertir() external pure returns(bytes32 result) {
        assembly {
            result:= not(2) // va a inveritr los bits, las 'f' = 0, 'd' = 2
        }
    }

    function max(uint256 x, uint256 y) external pure returns(uint256 maximun) {
        assembly {

            if lt(x, y) {
                maximun := y
            }
            if iszero(lt(x, y)) {
                maximun := x
            }
        }
        return maximun;
    }
    
}

contract storageYul {
    
    // a.slot() posicion de almacenamiento

    uint256 x = 10;
    uint256 y = 44;
    uint256 z = 8;

    function setX(uint256 newVal) external {
        x = newVal;
    }

    function getXYul(uint256 slot) external view returns(uint256 res) {
        assembly {
            res:= sload(slot)   // de las variables que inicializamos arriba las va guardando y con esto indicamos la posicion para ver el resultado de lo que almacena
        }
    }

    function setVarYul(uint256 slot, uint256 value) external {
        // slot sera la posiscion y value el valor
        // seteamos en la posicion 'slot' un value
        assembly {
            sstore(slot, value)
        }
    }

    function getOffSetZ() external pure returns(uint256 slot, uint256 offset) {
        assembly {
            slot:= z.slot   // me devuelve la posicion
            offset := z.offset  // me devuelve la cantidad de bytes a la izquierda que se encuentra mi valor
        }
    }

    function readBySlot(uint256 slot) external view returns(bytes32 res) {
        assembly {
            res := sload(slot)
        }
    }
}

contract storageComplejo {
    uint256[3] array;
    uint256[] bigArray;
    mapping (uint256 => uint256) public myMapping;
    mapping (uint256 => mapping(uint256 => uint256)) public nastedMapping;
    mapping (address => uint256[]) public addressToList;

    constructor() {
        array = [9, 99, 999];
        bigArray = [0, 1, 2];
        myMapping[10] = 10;
        myMapping[2] = 20;
        nastedMapping[0][0] = 9;
        nastedMapping[0][1] = 2;
        nastedMapping[0][3] = 5;
        nastedMapping[1][0] = 100;
        nastedMapping[2][0] = 90;
        nastedMapping[3][0] = 21;

        addressToList[0x788B2982343C9f8086aD2Cbb9DF32018f9d54968] = [0, 1, 2];
        addressToList[0x1dC2aBeFe6b0170F9B0A0a6Aa5364851ec828bFb] = [3, 4, 5];
        addressToList[0xBCeF5Dd71ebCB2E2eAB553F397719081400C869d] = [6, 7 , 8, 9];
    }

    function fixedArrayView(uint256 index) external view returns (uint256 res) {
        assembly {
            res := sload(add(array.slot, index))    // devuelve un valor segun el index ingresado
        }
    }

    function bigArrayLength() external view returns (uint256 res) {
        assembly {
            res := sload(bigArray.slot)
        }
    }

    function readBigArrayLocation(uint256 index) external view returns (uint256 res) {
        uint256 slot;

        assembly {
            slot := bigArray.slot
        }

        bytes32 location = keccak256(abi.encode(slot));

        assembly {
            res := sload(add(location, index))
        }
    }

    function getMappging(uint256 key) external view returns (uint256 res) {
        uint256 slot;
        // ingreso index a ver el valor en el mapping
        assembly {
            slot := myMapping.slot
        }

        bytes32 location = keccak256(abi.encode(key, uint256(slot)));

        assembly {
            res := sload(location)
        }
    }

    function getNastedMappging() external view returns (uint256 res) {
        uint256 slot;
        // ingreso index a ver el valor en el mapping
        assembly {
            slot := nastedMapping.slot
        }

        bytes32 location = keccak256(abi.encode(uint256(0), keccak256(abi.encode(uint256(2), uint256(slot))))); // la concatenacion y el has va hacia la izquierda aunque el mapping vaya hacia a derecha

        assembly {
            res := sload(location)
        }
    }

    function lengthOfNastedList() external view returns (uint256 res) {
        uint256 addressToListSlot;

        assembly {
            addressToListSlot := addressToList.slot
        }

        bytes32 location = keccak256(abi.encode(address(0xBCeF5Dd71ebCB2E2eAB553F397719081400C869d), uint256(addressToListSlot)));  // para ver el length de otra direccion cambiarla

        assembly {
            res := sload(location)
        }
    }

    function  getAddressToList(address _address, uint256 index) external view returns (uint256 res) {
        uint256 slot;

        assembly {
            slot := addressToList.slot
        }

        bytes32 location = keccak256(abi.encode(keccak256(abi.encode(address(_address), uint256(slot)))));  // vamos a buscar los valores del mapping segun address y posicion del arreglo

        assembly {
            res := sload(add(location, index))
        }
    }

}

contract Memory {
    /*
        4 funciones memoria : mload, mstore, mstore8, mzise
        mstore = carga un dato en un espacio en memoria,. Ej: mstore(0x80, 3; agrega en la dir de memoria 0x80 un 3
        mload = recupera 32 bytes de memoria de la posiscion x
        mstore8 = como mstore pero para 1 byte
        msize = mayor indice de memoria accedido en esa transaccion
    */

   event Debug(bytes32, bytes32, bytes32, bytes32);
   
   function args(uint256[] memory arr) external {
    
    bytes32 location;
    bytes32 len;
    bytes32 valueIndex0;
    bytes32 valueIndex1;

    assembly {
        location := arr
        len := mload(arr)
        valueIndex0 := mload(add(arr, 0x20))
        valueIndex1 := mload(add(arr, 0x40))
    }
    emit Debug(location, len, valueIndex0, valueIndex1);
   }

       function return2anf4() external pure returns (uint256, uint256) {
        assembly {
            mstore(0x00, 2)
            mstore(0x20, 4)
            return(0x00, 0x40)
        }
    }
}

contract CallData {
    /*
        Al enviar a un contrato inteligente, los primeros cuatro bytes especifican qué función está
        llamando y los bytes que siguen son argumentos de función codificados en abi.

        https://docs.soliditylang.org/en/develop/abi-spec.html#abi
        Solidity espera que los bytes después del selector de función siempre tengan una longitud múltiplo
        de 32, pero esto es una convención.
        Si envía más bytes, solidity los ignorará.
        Pero un contrato inteligente yul se puede programar para responder a tx.data de
        longitud arbitraria de manera arbitraria

        
        Los selectores de funciones son los primeros cuatro bytes del keccak256 de la firma de la
        función.
        balanceOf(address _address) --> keccak256 ("balanceOf(address)") --> 0x70a08231
    
        balanceOf(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4) 
        0x70a0823100000000000000000000000005B38Da6a701c568545dCfcB03FcB875f56beddC4

        con dos params se veria asi
        
        balanceOf(address _address, uint256 id) 
        keccak256 ("balanceOf(address, uint256)") --> 0x00fdd58e
        balanceOf(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, 5) -->
        0x00fdd58e00000000000000000000000005B38Da6a701c568545dCfcB03FcB875f56beddC40-00000000000000000000000000000005


    */
}

contract OtherContract {
    uint256 public x;
    uint256[] public arr;

    function get21() external pure returns (uint256) {
        return 21;
    }

    function revert99() external pure returns (uint256) {
        assembly {
            mstore(0x00, 99)
            revert(0x00, 0x20)
        }
    }

}

contract ExternalCalls {
    // staticcall no genera cambios
    // desplegar other contract -> copiar direccion y pegarla en parametro de esta funcion = 21
    function externalViewCallNoArgs(address _a) external view returns (uint256) {
        assembly {

            mstore(0x00, 0x9a884bde)
            // 00000000000000000000000000000000000000000000000000000000 9a884bde
            //                                                         28       32
            let success := staticcall(gas(), _a, 28, 32, 0x00, 0x20)
            // gas() cuanto gas desea pasarle a la otra funcion 
            // _a la direccion del contrato que pegamos
            // 28, 32 datos de transaccion cargados en memoria
            // 0x00, 0x20 region de memoria donde vamos a copiar los resultados

            if iszero(success) {
                revert(0, 0)
            }
            return (0x00, 0x20)
        }
    }

    function revertWithInfo(address _a) external view returns (uint256) {
        assembly {
            mstore(0x00, 0x73712595)
            pop(staticcall(gas(), _a, 28, 32, 0x00 ,0x20))
            return (0x00, 0x20)
        }
    }
}

contract Withdraw1 {
    constructor() payable {}

    address public constant owner = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    function withdraw () external {
        (bool s, ) = payable(owner).call{value: address(this).balance}("");
        require(s);
    }
}

contract Withdraw2 {
    /*
    esta es una manera mucho mas eficiente de ahorrar gas a la hora de desplegar
    */
    constructor() payable {}

    address public constant owner = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    function withdraw () external {
        assembly {
            let s := call(gas(), owner, selfbalance(), 0, 0, 0, 0)
            if iszero(s) {
                revert(0, 0)
            }
        }
    }
}