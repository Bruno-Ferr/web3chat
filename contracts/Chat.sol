// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Chat {
  //estruturar usuário
  struct User {
    string name;
    Friend[] friendList;
  }
  //estruturar mensagens
  struct Messages {
    address sender;
    uint timestamp;
    string content;
  }
  //estruturar amigos
  struct Friend {
    address pubkey;
    string name;
  }

  //guardar usuários da aplicação
  mapping (address => User) allUsers;
  //guardar mensagens
  mapping (bytes32 => Messages[]) allMessages;

  //Checar se usuário existe (middleware)
  modifier checkUserExists(address pubkey) {
    require(bytes(allUsers[pubkey].name).length > 0, "User don't exists!");
    _;
  }

  //Create account function
  function createAccount(address pubkey, string name) public  {
    require(bytes(allUsers[pubkey].name).length === 0, "User already has an account");

  }

  //getUsername

  //addFriend

  //get my friend list

  //get chat code

  //send message

  //Read message

}
