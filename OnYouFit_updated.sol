// SPDX-License-Identifier: MIT
pragma solidity >0.4.99 <0.6.0;

contract OnYouFit {
  // INSERT struct Product
  struct Product {
  string name;
  string description;
  string upiID;
  bool isActive; // is product active
  uint256 price; 
  address owner; // Owner of the product

}

  // Unique and sequential productId for every new product
  uint256 public productId;

  // mapping of productId to Product object
  mapping(uint256 => Product) public products;

  // INSERT struct Booking

  struct Buyin {
    uint256 productId;
    uint256 quantity;
    address user;
    string pmode;
  }

  uint256 public buyinId;

  // mapping of bookingId to Booking object
  mapping(uint256 => Buyin) public buyins;

  // This event is emitted when a new product is put up for sale
  event NewProduct (
    uint256 indexed productId
  );

  // This event is emitted when a NewBooking is made
  event NewBooking (
    uint256 indexed productId,
    uint256 indexed buyinId
  );

  /**
    * @dev Put up your funky space on the market
    * @param name Name of the product
    * @param description Short description of your product
    * @param price Price per day in wei (1 ether = 10^18 wei)
    */
function listProduct(string memory name, string memory description,string memory upiID, uint256 price) public {
  Product memory product = Product({
    name: name,
    description: description,
    upiID: upiID,
    isActive: true,
    price: price,
    owner: msg.sender
  });

  // Persist `product` object to the "permanent" storage
  products[productId] = product;

  // emit an event to notify the clients
  emit NewProduct(productId++);
}
  /**
   * @dev Make a Buy Order
   * @param _productId id of the product to rent out
   * @param _pmode id of the product to rent out
   */
  function buyProduct(uint256 _productId, uint256 quantity, string memory _pmode) public payable{
    // Retrieve `product` object from the storage
    Product storage product = products[_productId];

    // Assert that product is active
    // Assert that product is active
    require(
      product.isActive == true,
      "Product is not available"
    );    
    if(keccak256(bytes(_pmode)) == keccak256(bytes("t"))){
    //   require(
    //     msg.value == parseInt(toWei(((product.price * (quantity))/133999).toString(), 'ether')),
    //     "Sent insufficient funds"
    //   );
      _sendFunds(product.owner, msg.value);
      _createBuyin(_productId, quantity, _pmode);
    }
    // conditions for a booking are satisfied, so make the booking
    if(keccak256(bytes(_pmode)) == keccak256(bytes("f"))){
      _createBuyin(_productId, quantity, _pmode);
    }
    
  }

   function _sendFunds (address beneficiary, uint256 value) internal {
     // address(uint160()) is a weird solidity quirk
     // Read more here: https://solidity.readthedocs.io/en/v0.5.10/050-breaking-changes.html?highlight=address%20payable#explicitness-requirements
     address (uint160(beneficiary)).transfer(value);
   }

  function _createBuyin(uint256 _productId, uint256 quantity, string memory _pmode) internal {
    // Create a new booking object
    Buyin memory buyin = Buyin({
      productId: _productId,
      quantity : quantity,
      user: msg.sender,
      pmode : _pmode 
    });

    // persist to storage
    buyins[buyinId] = buyin;


    

    // Emit an event to notify clients
    emit NewBooking(_productId, buyinId++);
  }

  /**
   * @dev Take down the product from the market
   * @param _productId Product ID
   */
  function markProduct(uint256 _productId) public {
    require(
      products[_productId].owner == msg.sender,
      "THIS IS NOT YOUR PRODUCT"
    );
    if(products[_productId].isActive==true){
        products[_productId].isActive = false;
    }
    else{
        products[_productId].isActive = true;
    }
  }
}

//"linkReferences": {},
// 	"object": "608060405234801561001057600080fd5b506110eb806100206000396000f3fe6080604052600436106100705760003560e01c8063c5ce39111161004e578063c5ce391114610366578063c72da5d914610391578063ebc9368f14610591578063fc97816f1461066057610070565b806375c19a47146100755780637acc0b20146100a0578063b2a9e82714610271575b600080fd5b34801561008157600080fd5b5061008a61069b565b6040518082815260200191505060405180910390f35b3480156100ac57600080fd5b506100d9600480360360208110156100c357600080fd5b81019080803590602001909291905050506106a1565b60405180806020018060200180602001871515151581526020018681526020018573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200184810384528a818151815260200191508051906020019080838360005b83811015610163578082015181840152602081019050610148565b50505050905090810190601f1680156101905780820380516001836020036101000a031916815260200191505b50848103835289818151815260200191508051906020019080838360005b838110156101c95780820151818401526020810190506101ae565b50505050905090810190601f1680156101f65780820380516001836020036101000a031916815260200191505b50848103825288818151815260200191508051906020019080838360005b8381101561022f578082015181840152602081019050610214565b50505050905090810190601f16801561025c5780820380516001836020036101000a031916815260200191505b50995050505050505050505060405180910390f35b34801561027d57600080fd5b506102aa6004803603602081101561029457600080fd5b81019080803590602001909291905050506108d2565b604051808581526020018481526020018373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200180602001828103825283818151815260200191508051906020019080838360005b8381101561032857808201518184015260208101905061030d565b50505050905090810190601f1680156103555780820380516001836020036101000a031916815260200191505b509550505050505060405180910390f35b34801561037257600080fd5b5061037b6109ba565b6040518082815260200191505060405180910390f35b34801561039d57600080fd5b5061058f600480360360808110156103b457600080fd5b81019080803590602001906401000000008111156103d157600080fd5b8201836020820111156103e357600080fd5b8035906020019184600183028401116401000000008311171561040557600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f8201169050808301925050505050505091929192908035906020019064010000000081111561046857600080fd5b82018360208201111561047a57600080fd5b8035906020019184600183028401116401000000008311171561049c57600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f820116905080830192505050505050509192919290803590602001906401000000008111156104ff57600080fd5b82018360208201111561051157600080fd5b8035906020019184600183028401116401000000008311171561053357600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f820116905080830192505050505050509192919290803590602001909291905050506109c0565b005b61065e600480360360608110156105a757600080fd5b810190808035906020019092919080359060200190929190803590602001906401000000008111156105d857600080fd5b8201836020820111156105ea57600080fd5b8035906020019184600183028401116401000000008311171561060c57600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f820116905080830192505050505050509192919290505050610b33565b005b34801561066c57600080fd5b506106996004803603602081101561068357600080fd5b8101908080359060200190929190505050610cb7565b005b60025481565b6001602052806000526040600020600091509050806000018054600181600116156101000203166002900480601f01602080910402602001604051908101604052809291908181526020018280546001816001161561010002031660029004801561074d5780601f106107225761010080835404028352916020019161074d565b820191906000526020600020905b81548152906001019060200180831161073057829003601f168201915b505050505090806001018054600181600116156101000203166002900480601f0160208091040260200160405190810160405280929190818152602001828054600181600116156101000203166002900480156107eb5780601f106107c0576101008083540402835291602001916107eb565b820191906000526020600020905b8154815290600101906020018083116107ce57829003601f168201915b505050505090806002018054600181600116156101000203166002900480601f0160208091040260200160405190810160405280929190818152602001828054600181600116156101000203166002900480156108895780601f1061085e57610100808354040283529160200191610889565b820191906000526020600020905b81548152906001019060200180831161086c57829003601f168201915b5050505050908060030160009054906101000a900460ff16908060040154908060050160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff16905086565b60036020528060005260406000206000915090508060000154908060010154908060020160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1690806003018054600181600116156101000203166002900480601f0160208091040260200160405190810160405280929190818152602001828054600181600116156101000203166002900480156109b05780601f10610985576101008083540402835291602001916109b0565b820191906000526020600020905b81548152906001019060200180831161099357829003601f168201915b5050505050905084565b60005481565b6109c8610f85565b6040518060c001604052808681526020018581526020018481526020016001151581526020018381526020013373ffffffffffffffffffffffffffffffffffffffff1681525090508060016000805481526020019081526020016000206000820151816000019080519060200190610a41929190610fd3565b506020820151816001019080519060200190610a5e929190610fd3565b506040820151816002019080519060200190610a7b929190610fd3565b5060608201518160030160006101000a81548160ff0219169083151502179055506080820151816004015560a08201518160050160006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff160217905550905050600080815480929190600101919050557f4cf76794269f0514dbcdb5cbc4ab9cbdc6bf693c5c45e36dc94b2e7384d49c7960405160405180910390a25050505050565b6000600160008581526020019081526020016000209050600115158160030160009054906101000a900460ff16151514610bd5576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260188152602001807f50726f64756374206973206e6f7420617661696c61626c65000000000000000081525060200191505060405180910390fd5b6040518060400160405280600181526020017f74000000000000000000000000000000000000000000000000000000000000008152508051906020012082805190602001201415610c5a57610c4e8160050160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1634610e24565b610c59848484610e6f565b5b6040518060400160405280600181526020017f66000000000000000000000000000000000000000000000000000000000000008152508051906020012082805190602001201415610cb157610cb0848484610e6f565b5b50505050565b3373ffffffffffffffffffffffffffffffffffffffff166001600083815260200190815260200160002060050160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1614610d8e576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260188152602001807f54484953204953204e4f5420594f55522050524f44554354000000000000000081525060200191505060405180910390fd5b600115156001600083815260200190815260200160002060030160009054906101000a900460ff1615151415610df25760006001600083815260200190815260200160002060030160006101000a81548160ff021916908315150217905550610e21565b600180600083815260200190815260200160002060030160006101000a81548160ff0219169083151502179055505b50565b8173ffffffffffffffffffffffffffffffffffffffff166108fc829081150290604051600060405180830381858888f19350505050158015610e6a573d6000803e3d6000fd5b505050565b610e77611053565b60405180608001604052808581526020018481526020013373ffffffffffffffffffffffffffffffffffffffff16815260200183815250905080600360006002548152602001908152602001600020600082015181600001556020820151816001015560408201518160020160006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055506060820151816003019080519060200190610f3d929190610fd3565b509050506002600081548092919060010191905055847f4f65de66b4cd3e97fb943ca503efa62b328170ad1a0aac0e9c979a164a317b3860405160405180910390a350505050565b6040518060c0016040528060608152602001606081526020016060815260200160001515815260200160008152602001600073ffffffffffffffffffffffffffffffffffffffff1681525090565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f1061101457805160ff1916838001178555611042565b82800160010185558215611042579182015b82811115611041578251825591602001919060010190611026565b5b50905061104f9190611091565b5090565b60405180608001604052806000815260200160008152602001600073ffffffffffffffffffffffffffffffffffffffff168152602001606081525090565b6110b391905b808211156110af576000816000905550600101611097565b5090565b9056fea265627a7a72315820ef055d83fd43d9e9a70f4d3ab8a9ad940848e7c72a921058d9705c696e920b4664736f6c63430005110032",
// 	"opcodes": "PUSH1 0x80 PUSH1 0x40 MSTORE CALLVALUE DUP1 ISZERO PUSH2 0x10 JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST POP PUSH2 0x10EB DUP1 PUSH2 0x20 PUSH1 0x0 CODECOPY PUSH1 0x0 RETURN INVALID PUSH1 0x80 PUSH1 0x40 MSTORE PUSH1 0x4 CALLDATASIZE LT PUSH2 0x70 JUMPI PUSH1 0x0 CALLDATALOAD PUSH1 0xE0 SHR DUP1 PUSH4 0xC5CE3911 GT PUSH2 0x4E JUMPI DUP1 PUSH4 0xC5CE3911 EQ PUSH2 0x366 JUMPI DUP1 PUSH4 0xC72DA5D9 EQ PUSH2 0x391 JUMPI DUP1 PUSH4 0xEBC9368F EQ PUSH2 0x591 JUMPI DUP1 PUSH4 0xFC97816F EQ PUSH2 0x660 JUMPI PUSH2 0x70 JUMP JUMPDEST DUP1 PUSH4 0x75C19A47 EQ PUSH2 0x75 JUMPI DUP1 PUSH4 0x7ACC0B20 EQ PUSH2 0xA0 JUMPI DUP1 PUSH4 0xB2A9E827 EQ PUSH2 0x271 JUMPI JUMPDEST PUSH1 0x0 DUP1 REVERT JUMPDEST CALLVALUE DUP1 ISZERO PUSH2 0x81 JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST POP PUSH2 0x8A PUSH2 0x69B JUMP JUMPDEST PUSH1 0x40 MLOAD DUP1 DUP3 DUP2 MSTORE PUSH1 0x20 ADD SWAP2 POP POP PUSH1 0x40 MLOAD DUP1 SWAP2 SUB SWAP1 RETURN JUMPDEST CALLVALUE DUP1 ISZERO PUSH2 0xAC JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST POP PUSH2 0xD9 PUSH1 0x4 DUP1 CALLDATASIZE SUB PUSH1 0x20 DUP2 LT ISZERO PUSH2 0xC3 JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST DUP2 ADD SWAP1 DUP1 DUP1 CALLDATALOAD SWAP1 PUSH1 0x20 ADD SWAP1 SWAP3 SWAP2 SWAP1 POP POP POP PUSH2 0x6A1 JUMP JUMPDEST PUSH1 0x40 MLOAD DUP1 DUP1 PUSH1 0x20 ADD DUP1 PUSH1 0x20 ADD DUP1 PUSH1 0x20 ADD DUP8 ISZERO ISZERO ISZERO ISZERO DUP2 MSTORE PUSH1 0x20 ADD DUP7 DUP2 MSTORE PUSH1 0x20 ADD DUP6 PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND DUP2 MSTORE PUSH1 0x20 ADD DUP5 DUP2 SUB DUP5 MSTORE DUP11 DUP2 DUP2 MLOAD DUP2 MSTORE PUSH1 0x20 ADD SWAP2 POP DUP1 MLOAD SWAP1 PUSH1 0x20 ADD SWAP1 DUP1 DUP4 DUP4 PUSH1 0x0 JUMPDEST DUP4 DUP2 LT ISZERO PUSH2 0x163 JUMPI DUP1 DUP3 ADD MLOAD DUP2 DUP5 ADD MSTORE PUSH1 0x20 DUP2 ADD SWAP1 POP PUSH2 0x148 JUMP JUMPDEST POP POP POP POP SWAP1 POP SWAP1 DUP2 ADD SWAP1 PUSH1 0x1F AND DUP1 ISZERO PUSH2 0x190 JUMPI DUP1 DUP3 SUB DUP1 MLOAD PUSH1 0x1 DUP4 PUSH1 0x20 SUB PUSH2 0x100 EXP SUB NOT AND DUP2 MSTORE PUSH1 0x20 ADD SWAP2 POP JUMPDEST POP DUP5 DUP2 SUB DUP4 MSTORE DUP10 DUP2 DUP2 MLOAD DUP2 MSTORE PUSH1 0x20 ADD SWAP2 POP DUP1 MLOAD SWAP1 PUSH1 0x20 ADD SWAP1 DUP1 DUP4 DUP4 PUSH1 0x0 JUMPDEST DUP4 DUP2 LT ISZERO PUSH2 0x1C9 JUMPI DUP1 DUP3 ADD MLOAD DUP2 DUP5 ADD MSTORE PUSH1 0x20 DUP2 ADD SWAP1 POP PUSH2 0x1AE JUMP JUMPDEST POP POP POP POP SWAP1 POP SWAP1 DUP2 ADD SWAP1 PUSH1 0x1F AND DUP1 ISZERO PUSH2 0x1F6 JUMPI DUP1 DUP3 SUB DUP1 MLOAD PUSH1 0x1 DUP4 PUSH1 0x20 SUB PUSH2 0x100 EXP SUB NOT AND DUP2 MSTORE PUSH1 0x20 ADD SWAP2 POP JUMPDEST POP DUP5 DUP2 SUB DUP3 MSTORE DUP9 DUP2 DUP2 MLOAD DUP2 MSTORE PUSH1 0x20 ADD SWAP2 POP DUP1 MLOAD SWAP1 PUSH1 0x20 ADD SWAP1 DUP1 DUP4 DUP4 PUSH1 0x0 JUMPDEST DUP4 DUP2 LT ISZERO PUSH2 0x22F JUMPI DUP1 DUP3 ADD MLOAD DUP2 DUP5 ADD MSTORE PUSH1 0x20 DUP2 ADD SWAP1 POP PUSH2 0x214 JUMP JUMPDEST POP POP POP POP SWAP1 POP SWAP1 DUP2 ADD SWAP1 PUSH1 0x1F AND DUP1 ISZERO PUSH2 0x25C JUMPI DUP1 DUP3 SUB DUP1 MLOAD PUSH1 0x1 DUP4 PUSH1 0x20 SUB PUSH2 0x100 EXP SUB NOT AND DUP2 MSTORE PUSH1 0x20 ADD SWAP2 POP JUMPDEST POP SWAP10 POP POP POP POP POP POP POP POP POP POP PUSH1 0x40 MLOAD DUP1 SWAP2 SUB SWAP1 RETURN JUMPDEST CALLVALUE DUP1 ISZERO PUSH2 0x27D JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST POP PUSH2 0x2AA PUSH1 0x4 DUP1 CALLDATASIZE SUB PUSH1 0x20 DUP2 LT ISZERO PUSH2 0x294 JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST DUP2 ADD SWAP1 DUP1 DUP1 CALLDATALOAD SWAP1 PUSH1 0x20 ADD SWAP1 SWAP3 SWAP2 SWAP1 POP POP POP PUSH2 0x8D2 JUMP JUMPDEST PUSH1 0x40 MLOAD DUP1 DUP6 DUP2 MSTORE PUSH1 0x20 ADD DUP5 DUP2 MSTORE PUSH1 0x20 ADD DUP4 PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND DUP2 MSTORE PUSH1 0x20 ADD DUP1 PUSH1 0x20 ADD DUP3 DUP2 SUB DUP3 MSTORE DUP4 DUP2 DUP2 MLOAD DUP2 MSTORE PUSH1 0x20 ADD SWAP2 POP DUP1 MLOAD SWAP1 PUSH1 0x20 ADD SWAP1 DUP1 DUP4 DUP4 PUSH1 0x0 JUMPDEST DUP4 DUP2 LT ISZERO PUSH2 0x328 JUMPI DUP1 DUP3 ADD MLOAD DUP2 DUP5 ADD MSTORE PUSH1 0x20 DUP2 ADD SWAP1 POP PUSH2 0x30D JUMP JUMPDEST POP POP POP POP SWAP1 POP SWAP1 DUP2 ADD SWAP1 PUSH1 0x1F AND DUP1 ISZERO PUSH2 0x355 JUMPI DUP1 DUP3 SUB DUP1 MLOAD PUSH1 0x1 DUP4 PUSH1 0x20 SUB PUSH2 0x100 EXP SUB NOT AND DUP2 MSTORE PUSH1 0x20 ADD SWAP2 POP JUMPDEST POP SWAP6 POP POP POP POP POP POP PUSH1 0x40 MLOAD DUP1 SWAP2 SUB SWAP1 RETURN JUMPDEST CALLVALUE DUP1 ISZERO PUSH2 0x372 JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST POP PUSH2 0x37B PUSH2 0x9BA JUMP JUMPDEST PUSH1 0x40 MLOAD DUP1 DUP3 DUP2 MSTORE PUSH1 0x20 ADD SWAP2 POP POP PUSH1 0x40 MLOAD DUP1 SWAP2 SUB SWAP1 RETURN JUMPDEST CALLVALUE DUP1 ISZERO PUSH2 0x39D JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST POP PUSH2 0x58F PUSH1 0x4 DUP1 CALLDATASIZE SUB PUSH1 0x80 DUP2 LT ISZERO PUSH2 0x3B4 JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST DUP2 ADD SWAP1 DUP1 DUP1 CALLDATALOAD SWAP1 PUSH1 0x20 ADD SWAP1 PUSH5 0x100000000 DUP2 GT ISZERO PUSH2 0x3D1 JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST DUP3 ADD DUP4 PUSH1 0x20 DUP3 ADD GT ISZERO PUSH2 0x3E3 JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST DUP1 CALLDATALOAD SWAP1 PUSH1 0x20 ADD SWAP2 DUP5 PUSH1 0x1 DUP4 MUL DUP5 ADD GT PUSH5 0x100000000 DUP4 GT OR ISZERO PUSH2 0x405 JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST SWAP2 SWAP1 DUP1 DUP1 PUSH1 0x1F ADD PUSH1 0x20 DUP1 SWAP2 DIV MUL PUSH1 0x20 ADD PUSH1 0x40 MLOAD SWAP1 DUP2 ADD PUSH1 0x40 MSTORE DUP1 SWAP4 SWAP3 SWAP2 SWAP1 DUP2 DUP2 MSTORE PUSH1 0x20 ADD DUP4 DUP4 DUP1 DUP3 DUP5 CALLDATACOPY PUSH1 0x0 DUP2 DUP5 ADD MSTORE PUSH1 0x1F NOT PUSH1 0x1F DUP3 ADD AND SWAP1 POP DUP1 DUP4 ADD SWAP3 POP POP POP POP POP POP POP SWAP2 SWAP3 SWAP2 SWAP3 SWAP1 DUP1 CALLDATALOAD SWAP1 PUSH1 0x20 ADD SWAP1 PUSH5 0x100000000 DUP2 GT ISZERO PUSH2 0x468 JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST DUP3 ADD DUP4 PUSH1 0x20 DUP3 ADD GT ISZERO PUSH2 0x47A JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST DUP1 CALLDATALOAD SWAP1 PUSH1 0x20 ADD SWAP2 DUP5 PUSH1 0x1 DUP4 MUL DUP5 ADD GT PUSH5 0x100000000 DUP4 GT OR ISZERO PUSH2 0x49C JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST SWAP2 SWAP1 DUP1 DUP1 PUSH1 0x1F ADD PUSH1 0x20 DUP1 SWAP2 DIV MUL PUSH1 0x20 ADD PUSH1 0x40 MLOAD SWAP1 DUP2 ADD PUSH1 0x40 MSTORE DUP1 SWAP4 SWAP3 SWAP2 SWAP1 DUP2 DUP2 MSTORE PUSH1 0x20 ADD DUP4 DUP4 DUP1 DUP3 DUP5 CALLDATACOPY PUSH1 0x0 DUP2 DUP5 ADD MSTORE PUSH1 0x1F NOT PUSH1 0x1F DUP3 ADD AND SWAP1 POP DUP1 DUP4 ADD SWAP3 POP POP POP POP POP POP POP SWAP2 SWAP3 SWAP2 SWAP3 SWAP1 DUP1 CALLDATALOAD SWAP1 PUSH1 0x20 ADD SWAP1 PUSH5 0x100000000 DUP2 GT ISZERO PUSH2 0x4FF JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST DUP3 ADD DUP4 PUSH1 0x20 DUP3 ADD GT ISZERO PUSH2 0x511 JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST DUP1 CALLDATALOAD SWAP1 PUSH1 0x20 ADD SWAP2 DUP5 PUSH1 0x1 DUP4 MUL DUP5 ADD GT PUSH5 0x100000000 DUP4 GT OR ISZERO PUSH2 0x533 JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST SWAP2 SWAP1 DUP1 DUP1 PUSH1 0x1F ADD PUSH1 0x20 DUP1 SWAP2 DIV MUL PUSH1 0x20 ADD PUSH1 0x40 MLOAD SWAP1 DUP2 ADD PUSH1 0x40 MSTORE DUP1 SWAP4 SWAP3 SWAP2 SWAP1 DUP2 DUP2 MSTORE PUSH1 0x20 ADD DUP4 DUP4 DUP1 DUP3 DUP5 CALLDATACOPY PUSH1 0x0 DUP2 DUP5 ADD MSTORE PUSH1 0x1F NOT PUSH1 0x1F DUP3 ADD AND SWAP1 POP DUP1 DUP4 ADD SWAP3 POP POP POP POP POP POP POP SWAP2 SWAP3 SWAP2 SWAP3 SWAP1 DUP1 CALLDATALOAD SWAP1 PUSH1 0x20 ADD SWAP1 SWAP3 SWAP2 SWAP1 POP POP POP PUSH2 0x9C0 JUMP JUMPDEST STOP JUMPDEST PUSH2 0x65E PUSH1 0x4 DUP1 CALLDATASIZE SUB PUSH1 0x60 DUP2 LT ISZERO PUSH2 0x5A7 JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST DUP2 ADD SWAP1 DUP1 DUP1 CALLDATALOAD SWAP1 PUSH1 0x20 ADD SWAP1 SWAP3 SWAP2 SWAP1 DUP1 CALLDATALOAD SWAP1 PUSH1 0x20 ADD SWAP1 SWAP3 SWAP2 SWAP1 DUP1 CALLDATALOAD SWAP1 PUSH1 0x20 ADD SWAP1 PUSH5 0x100000000 DUP2 GT ISZERO PUSH2 0x5D8 JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST DUP3 ADD DUP4 PUSH1 0x20 DUP3 ADD GT ISZERO PUSH2 0x5EA JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST DUP1 CALLDATALOAD SWAP1 PUSH1 0x20 ADD SWAP2 DUP5 PUSH1 0x1 DUP4 MUL DUP5 ADD GT PUSH5 0x100000000 DUP4 GT OR ISZERO PUSH2 0x60C JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST SWAP2 SWAP1 DUP1 DUP1 PUSH1 0x1F ADD PUSH1 0x20 DUP1 SWAP2 DIV MUL PUSH1 0x20 ADD PUSH1 0x40 MLOAD SWAP1 DUP2 ADD PUSH1 0x40 MSTORE DUP1 SWAP4 SWAP3 SWAP2 SWAP1 DUP2 DUP2 MSTORE PUSH1 0x20 ADD DUP4 DUP4 DUP1 DUP3 DUP5 CALLDATACOPY PUSH1 0x0 DUP2 DUP5 ADD MSTORE PUSH1 0x1F NOT PUSH1 0x1F DUP3 ADD AND SWAP1 POP DUP1 DUP4 ADD SWAP3 POP POP POP POP POP POP POP SWAP2 SWAP3 SWAP2 SWAP3 SWAP1 POP POP POP PUSH2 0xB33 JUMP JUMPDEST STOP JUMPDEST CALLVALUE DUP1 ISZERO PUSH2 0x66C JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST POP PUSH2 0x699 PUSH1 0x4 DUP1 CALLDATASIZE SUB PUSH1 0x20 DUP2 LT ISZERO PUSH2 0x683 JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST DUP2 ADD SWAP1 DUP1 DUP1 CALLDATALOAD SWAP1 PUSH1 0x20 ADD SWAP1 SWAP3 SWAP2 SWAP1 POP POP POP PUSH2 0xCB7 JUMP JUMPDEST STOP JUMPDEST PUSH1 0x2 SLOAD DUP2 JUMP JUMPDEST PUSH1 0x1 PUSH1 0x20 MSTORE DUP1 PUSH1 0x0 MSTORE PUSH1 0x40 PUSH1 0x0 KECCAK256 PUSH1 0x0 SWAP2 POP SWAP1 POP DUP1 PUSH1 0x0 ADD DUP1 SLOAD PUSH1 0x1 DUP2 PUSH1 0x1 AND ISZERO PUSH2 0x100 MUL SUB AND PUSH1 0x2 SWAP1 DIV DUP1 PUSH1 0x1F ADD PUSH1 0x20 DUP1 SWAP2 DIV MUL PUSH1 0x20 ADD PUSH1 0x40 MLOAD SWAP1 DUP2 ADD PUSH1 0x40 MSTORE DUP1 SWAP3 SWAP2 SWAP1 DUP2 DUP2 MSTORE PUSH1 0x20 ADD DUP3 DUP1 SLOAD PUSH1 0x1 DUP2 PUSH1 0x1 AND ISZERO PUSH2 0x100 MUL SUB AND PUSH1 0x2 SWAP1 DIV DUP1 ISZERO PUSH2 0x74D JUMPI DUP1 PUSH1 0x1F LT PUSH2 0x722 JUMPI PUSH2 0x100 DUP1 DUP4 SLOAD DIV MUL DUP4 MSTORE SWAP2 PUSH1 0x20 ADD SWAP2 PUSH2 0x74D JUMP JUMPDEST DUP3 ADD SWAP2 SWAP1 PUSH1 0x0 MSTORE PUSH1 0x20 PUSH1 0x0 KECCAK256 SWAP1 JUMPDEST DUP2 SLOAD DUP2 MSTORE SWAP1 PUSH1 0x1 ADD SWAP1 PUSH1 0x20 ADD DUP1 DUP4 GT PUSH2 0x730 JUMPI DUP3 SWAP1 SUB PUSH1 0x1F AND DUP3 ADD SWAP2 JUMPDEST POP POP POP POP POP SWAP1 DUP1 PUSH1 0x1 ADD DUP1 SLOAD PUSH1 0x1 DUP2 PUSH1 0x1 AND ISZERO PUSH2 0x100 MUL SUB AND PUSH1 0x2 SWAP1 DIV DUP1 PUSH1 0x1F ADD PUSH1 0x20 DUP1 SWAP2 DIV MUL PUSH1 0x20 ADD PUSH1 0x40 MLOAD SWAP1 DUP2 ADD PUSH1 0x40 MSTORE DUP1 SWAP3 SWAP2 SWAP1 DUP2 DUP2 MSTORE PUSH1 0x20 ADD DUP3 DUP1 SLOAD PUSH1 0x1 DUP2 PUSH1 0x1 AND ISZERO PUSH2 0x100 MUL SUB AND PUSH1 0x2 SWAP1 DIV DUP1 ISZERO PUSH2 0x7EB JUMPI DUP1 PUSH1 0x1F LT PUSH2 0x7C0 JUMPI PUSH2 0x100 DUP1 DUP4 SLOAD DIV MUL DUP4 MSTORE SWAP2 PUSH1 0x20 ADD SWAP2 PUSH2 0x7EB JUMP JUMPDEST DUP3 ADD SWAP2 SWAP1 PUSH1 0x0 MSTORE PUSH1 0x20 PUSH1 0x0 KECCAK256 SWAP1 JUMPDEST DUP2 SLOAD DUP2 MSTORE SWAP1 PUSH1 0x1 ADD SWAP1 PUSH1 0x20 ADD DUP1 DUP4 GT PUSH2 0x7CE JUMPI DUP3 SWAP1 SUB PUSH1 0x1F AND DUP3 ADD SWAP2 JUMPDEST POP POP POP POP POP SWAP1 DUP1 PUSH1 0x2 ADD DUP1 SLOAD PUSH1 0x1 DUP2 PUSH1 0x1 AND ISZERO PUSH2 0x100 MUL SUB AND PUSH1 0x2 SWAP1 DIV DUP1 PUSH1 0x1F ADD PUSH1 0x20 DUP1 SWAP2 DIV MUL PUSH1 0x20 ADD PUSH1 0x40 MLOAD SWAP1 DUP2 ADD PUSH1 0x40 MSTORE DUP1 SWAP3 SWAP2 SWAP1 DUP2 DUP2 MSTORE PUSH1 0x20 ADD DUP3 DUP1 SLOAD PUSH1 0x1 DUP2 PUSH1 0x1 AND ISZERO PUSH2 0x100 MUL SUB AND PUSH1 0x2 SWAP1 DIV DUP1 ISZERO PUSH2 0x889 JUMPI DUP1 PUSH1 0x1F LT PUSH2 0x85E JUMPI PUSH2 0x100 DUP1 DUP4 SLOAD DIV MUL DUP4 MSTORE SWAP2 PUSH1 0x20 ADD SWAP2 PUSH2 0x889 JUMP JUMPDEST DUP3 ADD SWAP2 SWAP1 PUSH1 0x0 MSTORE PUSH1 0x20 PUSH1 0x0 KECCAK256 SWAP1 JUMPDEST DUP2 SLOAD DUP2 MSTORE SWAP1 PUSH1 0x1 ADD SWAP1 PUSH1 0x20 ADD DUP1 DUP4 GT PUSH2 0x86C JUMPI DUP3 SWAP1 SUB PUSH1 0x1F AND DUP3 ADD SWAP2 JUMPDEST POP POP POP POP POP SWAP1 DUP1 PUSH1 0x3 ADD PUSH1 0x0 SWAP1 SLOAD SWAP1 PUSH2 0x100 EXP SWAP1 DIV PUSH1 0xFF AND SWAP1 DUP1 PUSH1 0x4 ADD SLOAD SWAP1 DUP1 PUSH1 0x5 ADD PUSH1 0x0 SWAP1 SLOAD SWAP1 PUSH2 0x100 EXP SWAP1 DIV PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND SWAP1 POP DUP7 JUMP JUMPDEST PUSH1 0x3 PUSH1 0x20 MSTORE DUP1 PUSH1 0x0 MSTORE PUSH1 0x40 PUSH1 0x0 KECCAK256 PUSH1 0x0 SWAP2 POP SWAP1 POP DUP1 PUSH1 0x0 ADD SLOAD SWAP1 DUP1 PUSH1 0x1 ADD SLOAD SWAP1 DUP1 PUSH1 0x2 ADD PUSH1 0x0 SWAP1 SLOAD SWAP1 PUSH2 0x100 EXP SWAP1 DIV PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND SWAP1 DUP1 PUSH1 0x3 ADD DUP1 SLOAD PUSH1 0x1 DUP2 PUSH1 0x1 AND ISZERO PUSH2 0x100 MUL SUB AND PUSH1 0x2 SWAP1 DIV DUP1 PUSH1 0x1F ADD PUSH1 0x20 DUP1 SWAP2 DIV MUL PUSH1 0x20 ADD PUSH1 0x40 MLOAD SWAP1 DUP2 ADD PUSH1 0x40 MSTORE DUP1 SWAP3 SWAP2 SWAP1 DUP2 DUP2 MSTORE PUSH1 0x20 ADD DUP3 DUP1 SLOAD PUSH1 0x1 DUP2 PUSH1 0x1 AND ISZERO PUSH2 0x100 MUL SUB AND PUSH1 0x2 SWAP1 DIV DUP1 ISZERO PUSH2 0x9B0 JUMPI DUP1 PUSH1 0x1F LT PUSH2 0x985 JUMPI PUSH2 0x100 DUP1 DUP4 SLOAD DIV MUL DUP4 MSTORE SWAP2 PUSH1 0x20 ADD SWAP2 PUSH2 0x9B0 JUMP JUMPDEST DUP3 ADD SWAP2 SWAP1 PUSH1 0x0 MSTORE PUSH1 0x20 PUSH1 0x0 KECCAK256 SWAP1 JUMPDEST DUP2 SLOAD DUP2 MSTORE SWAP1 PUSH1 0x1 ADD SWAP1 PUSH1 0x20 ADD DUP1 DUP4 GT PUSH2 0x993 JUMPI DUP3 SWAP1 SUB PUSH1 0x1F AND DUP3 ADD SWAP2 JUMPDEST POP POP POP POP POP SWAP1 POP DUP5 JUMP JUMPDEST PUSH1 0x0 SLOAD DUP2 JUMP JUMPDEST PUSH2 0x9C8 PUSH2 0xF85 JUMP JUMPDEST PUSH1 0x40 MLOAD DUP1 PUSH1 0xC0 ADD PUSH1 0x40 MSTORE DUP1 DUP7 DUP2 MSTORE PUSH1 0x20 ADD DUP6 DUP2 MSTORE PUSH1 0x20 ADD DUP5 DUP2 MSTORE PUSH1 0x20 ADD PUSH1 0x1 ISZERO ISZERO DUP2 MSTORE PUSH1 0x20 ADD DUP4 DUP2 MSTORE PUSH1 0x20 ADD CALLER PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND DUP2 MSTORE POP SWAP1 POP DUP1 PUSH1 0x1 PUSH1 0x0 DUP1 SLOAD DUP2 MSTORE PUSH1 0x20 ADD SWAP1 DUP2 MSTORE PUSH1 0x20 ADD PUSH1 0x0 KECCAK256 PUSH1 0x0 DUP3 ADD MLOAD DUP2 PUSH1 0x0 ADD SWAP1 DUP1 MLOAD SWAP1 PUSH1 0x20 ADD SWAP1 PUSH2 0xA41 SWAP3 SWAP2 SWAP1 PUSH2 0xFD3 JUMP JUMPDEST POP PUSH1 0x20 DUP3 ADD MLOAD DUP2 PUSH1 0x1 ADD SWAP1 DUP1 MLOAD SWAP1 PUSH1 0x20 ADD SWAP1 PUSH2 0xA5E SWAP3 SWAP2 SWAP1 PUSH2 0xFD3 JUMP JUMPDEST POP PUSH1 0x40 DUP3 ADD MLOAD DUP2 PUSH1 0x2 ADD SWAP1 DUP1 MLOAD SWAP1 PUSH1 0x20 ADD SWAP1 PUSH2 0xA7B SWAP3 SWAP2 SWAP1 PUSH2 0xFD3 JUMP JUMPDEST POP PUSH1 0x60 DUP3 ADD MLOAD DUP2 PUSH1 0x3 ADD PUSH1 0x0 PUSH2 0x100 EXP DUP2 SLOAD DUP2 PUSH1 0xFF MUL NOT AND SWAP1 DUP4 ISZERO ISZERO MUL OR SWAP1 SSTORE POP PUSH1 0x80 DUP3 ADD MLOAD DUP2 PUSH1 0x4 ADD SSTORE PUSH1 0xA0 DUP3 ADD MLOAD DUP2 PUSH1 0x5 ADD PUSH1 0x0 PUSH2 0x100 EXP DUP2 SLOAD DUP2 PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF MUL NOT AND SWAP1 DUP4 PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND MUL OR SWAP1 SSTORE POP SWAP1 POP POP PUSH1 0x0 DUP1 DUP2 SLOAD DUP1 SWAP3 SWAP2 SWAP1 PUSH1 0x1 ADD SWAP2 SWAP1 POP SSTORE PUSH32 0x4CF76794269F0514DBCDB5CBC4AB9CBDC6BF693C5C45E36DC94B2E7384D49C79 PUSH1 0x40 MLOAD PUSH1 0x40 MLOAD DUP1 SWAP2 SUB SWAP1 LOG2 POP POP POP POP POP JUMP JUMPDEST PUSH1 0x0 PUSH1 0x1 PUSH1 0x0 DUP6 DUP2 MSTORE PUSH1 0x20 ADD SWAP1 DUP2 MSTORE PUSH1 0x20 ADD PUSH1 0x0 KECCAK256 SWAP1 POP PUSH1 0x1 ISZERO ISZERO DUP2 PUSH1 0x3 ADD PUSH1 0x0 SWAP1 SLOAD SWAP1 PUSH2 0x100 EXP SWAP1 DIV PUSH1 0xFF AND ISZERO ISZERO EQ PUSH2 0xBD5 JUMPI PUSH1 0x40 MLOAD PUSH32 0x8C379A000000000000000000000000000000000000000000000000000000000 DUP2 MSTORE PUSH1 0x4 ADD DUP1 DUP1 PUSH1 0x20 ADD DUP3 DUP2 SUB DUP3 MSTORE PUSH1 0x18 DUP2 MSTORE PUSH1 0x20 ADD DUP1 PUSH32 0x50726F64756374206973206E6F7420617661696C61626C650000000000000000 DUP2 MSTORE POP PUSH1 0x20 ADD SWAP2 POP POP PUSH1 0x40 MLOAD DUP1 SWAP2 SUB SWAP1 REVERT JUMPDEST PUSH1 0x40 MLOAD DUP1 PUSH1 0x40 ADD PUSH1 0x40 MSTORE DUP1 PUSH1 0x1 DUP2 MSTORE PUSH1 0x20 ADD PUSH32 0x7400000000000000000000000000000000000000000000000000000000000000 DUP2 MSTORE POP DUP1 MLOAD SWAP1 PUSH1 0x20 ADD KECCAK256 DUP3 DUP1 MLOAD SWAP1 PUSH1 0x20 ADD KECCAK256 EQ ISZERO PUSH2 0xC5A JUMPI PUSH2 0xC4E DUP2 PUSH1 0x5 ADD PUSH1 0x0 SWAP1 SLOAD SWAP1 PUSH2 0x100 EXP SWAP1 DIV PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND CALLVALUE PUSH2 0xE24 JUMP JUMPDEST PUSH2 0xC59 DUP5 DUP5 DUP5 PUSH2 0xE6F JUMP JUMPDEST JUMPDEST PUSH1 0x40 MLOAD DUP1 PUSH1 0x40 ADD PUSH1 0x40 MSTORE DUP1 PUSH1 0x1 DUP2 MSTORE PUSH1 0x20 ADD PUSH32 0x6600000000000000000000000000000000000000000000000000000000000000 DUP2 MSTORE POP DUP1 MLOAD SWAP1 PUSH1 0x20 ADD KECCAK256 DUP3 DUP1 MLOAD SWAP1 PUSH1 0x20 ADD KECCAK256 EQ ISZERO PUSH2 0xCB1 JUMPI PUSH2 0xCB0 DUP5 DUP5 DUP5 PUSH2 0xE6F JUMP JUMPDEST JUMPDEST POP POP POP POP JUMP JUMPDEST CALLER PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND PUSH1 0x1 PUSH1 0x0 DUP4 DUP2 MSTORE PUSH1 0x20 ADD SWAP1 DUP2 MSTORE PUSH1 0x20 ADD PUSH1 0x0 KECCAK256 PUSH1 0x5 ADD PUSH1 0x0 SWAP1 SLOAD SWAP1 PUSH2 0x100 EXP SWAP1 DIV PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND EQ PUSH2 0xD8E JUMPI PUSH1 0x40 MLOAD PUSH32 0x8C379A000000000000000000000000000000000000000000000000000000000 DUP2 MSTORE PUSH1 0x4 ADD DUP1 DUP1 PUSH1 0x20 ADD DUP3 DUP2 SUB DUP3 MSTORE PUSH1 0x18 DUP2 MSTORE PUSH1 0x20 ADD DUP1 PUSH32 0x54484953204953204E4F5420594F55522050524F445543540000000000000000 DUP2 MSTORE POP PUSH1 0x20 ADD SWAP2 POP POP PUSH1 0x40 MLOAD DUP1 SWAP2 SUB SWAP1 REVERT JUMPDEST PUSH1 0x1 ISZERO ISZERO PUSH1 0x1 PUSH1 0x0 DUP4 DUP2 MSTORE PUSH1 0x20 ADD SWAP1 DUP2 MSTORE PUSH1 0x20 ADD PUSH1 0x0 KECCAK256 PUSH1 0x3 ADD PUSH1 0x0 SWAP1 SLOAD SWAP1 PUSH2 0x100 EXP SWAP1 DIV PUSH1 0xFF AND ISZERO ISZERO EQ ISZERO PUSH2 0xDF2 JUMPI PUSH1 0x0 PUSH1 0x1 PUSH1 0x0 DUP4 DUP2 MSTORE PUSH1 0x20 ADD SWAP1 DUP2 MSTORE PUSH1 0x20 ADD PUSH1 0x0 KECCAK256 PUSH1 0x3 ADD PUSH1 0x0 PUSH2 0x100 EXP DUP2 SLOAD DUP2 PUSH1 0xFF MUL NOT AND SWAP1 DUP4 ISZERO ISZERO MUL OR SWAP1 SSTORE POP PUSH2 0xE21 JUMP JUMPDEST PUSH1 0x1 DUP1 PUSH1 0x0 DUP4 DUP2 MSTORE PUSH1 0x20 ADD SWAP1 DUP2 MSTORE PUSH1 0x20 ADD PUSH1 0x0 KECCAK256 PUSH1 0x3 ADD PUSH1 0x0 PUSH2 0x100 EXP DUP2 SLOAD DUP2 PUSH1 0xFF MUL NOT AND SWAP1 DUP4 ISZERO ISZERO MUL OR SWAP1 SSTORE POP JUMPDEST POP JUMP JUMPDEST DUP2 PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND PUSH2 0x8FC DUP3 SWAP1 DUP2 ISZERO MUL SWAP1 PUSH1 0x40 MLOAD PUSH1 0x0 PUSH1 0x40 MLOAD DUP1 DUP4 SUB DUP2 DUP6 DUP9 DUP9 CALL SWAP4 POP POP POP POP ISZERO DUP1 ISZERO PUSH2 0xE6A JUMPI RETURNDATASIZE PUSH1 0x0 DUP1 RETURNDATACOPY RETURNDATASIZE PUSH1 0x0 REVERT JUMPDEST POP POP POP JUMP JUMPDEST PUSH2 0xE77 PUSH2 0x1053 JUMP JUMPDEST PUSH1 0x40 MLOAD DUP1 PUSH1 0x80 ADD PUSH1 0x40 MSTORE DUP1 DUP6 DUP2 MSTORE PUSH1 0x20 ADD DUP5 DUP2 MSTORE PUSH1 0x20 ADD CALLER PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND DUP2 MSTORE PUSH1 0x20 ADD DUP4 DUP2 MSTORE POP SWAP1 POP DUP1 PUSH1 0x3 PUSH1 0x0 PUSH1 0x2 SLOAD DUP2 MSTORE PUSH1 0x20 ADD SWAP1 DUP2 MSTORE PUSH1 0x20 ADD PUSH1 0x0 KECCAK256 PUSH1 0x0 DUP3 ADD MLOAD DUP2 PUSH1 0x0 ADD SSTORE PUSH1 0x20 DUP3 ADD MLOAD DUP2 PUSH1 0x1 ADD SSTORE PUSH1 0x40 DUP3 ADD MLOAD DUP2 PUSH1 0x2 ADD PUSH1 0x0 PUSH2 0x100 EXP DUP2 SLOAD DUP2 PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF MUL NOT AND SWAP1 DUP4 PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND MUL OR SWAP1 SSTORE POP PUSH1 0x60 DUP3 ADD MLOAD DUP2 PUSH1 0x3 ADD SWAP1 DUP1 MLOAD SWAP1 PUSH1 0x20 ADD SWAP1 PUSH2 0xF3D SWAP3 SWAP2 SWAP1 PUSH2 0xFD3 JUMP JUMPDEST POP SWAP1 POP POP PUSH1 0x2 PUSH1 0x0 DUP2 SLOAD DUP1 SWAP3 SWAP2 SWAP1 PUSH1 0x1 ADD SWAP2 SWAP1 POP SSTORE DUP5 PUSH32 0x4F65DE66B4CD3E97FB943CA503EFA62B328170AD1A0AAC0E9C979A164A317B38 PUSH1 0x40 MLOAD PUSH1 0x40 MLOAD DUP1 SWAP2 SUB SWAP1 LOG3 POP POP POP POP JUMP JUMPDEST PUSH1 0x40 MLOAD DUP1 PUSH1 0xC0 ADD PUSH1 0x40 MSTORE DUP1 PUSH1 0x60 DUP2 MSTORE PUSH1 0x20 ADD PUSH1 0x60 DUP2 MSTORE PUSH1 0x20 ADD PUSH1 0x60 DUP2 MSTORE PUSH1 0x20 ADD PUSH1 0x0 ISZERO ISZERO DUP2 MSTORE PUSH1 0x20 ADD PUSH1 0x0 DUP2 MSTORE PUSH1 0x20 ADD PUSH1 0x0 PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND DUP2 MSTORE POP SWAP1 JUMP JUMPDEST DUP3 DUP1 SLOAD PUSH1 0x1 DUP2 PUSH1 0x1 AND ISZERO PUSH2 0x100 MUL SUB AND PUSH1 0x2 SWAP1 DIV SWAP1 PUSH1 0x0 MSTORE PUSH1 0x20 PUSH1 0x0 KECCAK256 SWAP1 PUSH1 0x1F ADD PUSH1 0x20 SWAP1 DIV DUP2 ADD SWAP3 DUP3 PUSH1 0x1F LT PUSH2 0x1014 JUMPI DUP1 MLOAD PUSH1 0xFF NOT AND DUP4 DUP1 ADD OR DUP6 SSTORE PUSH2 0x1042 JUMP JUMPDEST DUP3 DUP1 ADD PUSH1 0x1 ADD DUP6 SSTORE DUP3 ISZERO PUSH2 0x1042 JUMPI SWAP2 DUP3 ADD JUMPDEST DUP3 DUP2 GT ISZERO PUSH2 0x1041 JUMPI DUP3 MLOAD DUP3 SSTORE SWAP2 PUSH1 0x20 ADD SWAP2 SWAP1 PUSH1 0x1 ADD SWAP1 PUSH2 0x1026 JUMP JUMPDEST JUMPDEST POP SWAP1 POP PUSH2 0x104F SWAP2 SWAP1 PUSH2 0x1091 JUMP JUMPDEST POP SWAP1 JUMP JUMPDEST PUSH1 0x40 MLOAD DUP1 PUSH1 0x80 ADD PUSH1 0x40 MSTORE DUP1 PUSH1 0x0 DUP2 MSTORE PUSH1 0x20 ADD PUSH1 0x0 DUP2 MSTORE PUSH1 0x20 ADD PUSH1 0x0 PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND DUP2 MSTORE PUSH1 0x20 ADD PUSH1 0x60 DUP2 MSTORE POP SWAP1 JUMP JUMPDEST PUSH2 0x10B3 SWAP2 SWAP1 JUMPDEST DUP1 DUP3 GT ISZERO PUSH2 0x10AF JUMPI PUSH1 0x0 DUP2 PUSH1 0x0 SWAP1 SSTORE POP PUSH1 0x1 ADD PUSH2 0x1097 JUMP JUMPDEST POP SWAP1 JUMP JUMPDEST SWAP1 JUMP INVALID LOG2 PUSH6 0x627A7A723158 KECCAK256 0xEF SDIV 0x5D DUP4 REVERT NUMBER 0xD9 0xE9 0xA7 0xF 0x4D GASPRICE 0xB8 0xA9 0xAD SWAP5 ADDMOD 0x48 0xE7 0xC7 0x2A SWAP3 LT PC 0xD9 PUSH17 0x5C696E920B4664736F6C63430005110032 ",
// 	"sourceMap": "68:3900:0:-;;;;8:9:-1;5:2;;;30:1;27;20:12;5:2;68:3900:0;;;;;;;"