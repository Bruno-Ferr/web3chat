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
  struct Message {
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
  mapping (bytes32 => Message[]) allMessages;

  //Checar se usuário existe (middleware)
  function _checkUserExists(address pubkey) internal view returns(bool){
    return bytes(allUsers[pubkey].name).length > 0;
  }

  //Create account function
  function createAccount(string calldata name) public {
    require(_checkUserExists(msg.sender) == false, "User already has an account");
    require(bytes(name).length > 0, "Username cannot be empty");

    allUsers[msg.sender].name = name;
  }

  //getUsername
  function getUsername(address pubkey) external view returns(string memory) {
    require(_checkUserExists(pubkey), "User don't exists");
    return allUsers[pubkey].name;
  }

  //addFriend
  function addFriend(address friend_key, string calldata name) external {
    require(_checkUserExists(msg.sender), "Create an account first");
    require(_checkUserExists(friend_key), "User don't exists");
    require(msg.sender != friend_key, "You cannot be friend of yourself");
    require(checkAlreadyFriend(msg.sender, friend_key) == false, "This user is already on your friend list");
    require(bytes(name).length > 0, "Friend name cannot be empty");

    _addFriend(msg.sender, friend_key, name);
    _addFriend(friend_key, msg.sender, allUsers[msg.sender].name);
  }

  //check if they already are friends
  function checkAlreadyFriend(address pubkey1, address pubkey2) internal view returns (bool) { // 2 e 1
    if(allUsers[pubkey1].friendList.length > allUsers[pubkey2].friendList.length) {
      address tmp = pubkey1;
      pubkey1 = pubkey2;
      pubkey2 = tmp;
    }

    for(uint256 i = 0; i < allUsers[pubkey1].friendList.length; i++) {
      if(allUsers[pubkey1].friendList[i].pubkey == pubkey2) return true;
    }
    return false;
  }

  //add friend function
  function _addFriend(address me, address friend_key, string memory name) internal {
    allUsers[me].friendList.push(Friend(friend_key, name));
  }

  //get my friend list
  function getFriendList() external view returns(Friend[] memory){
    return allUsers[msg.sender].friendList;
  }

  //get chat code
  function _getChatCode(address pubkey1, address pubkey2) internal pure returns(bytes32) {
    if(pubkey1 < pubkey2) {
      return keccak256(abi.encodePacked(pubkey1, pubkey2));
    } else return keccak256(abi.encodePacked(pubkey2, pubkey1));
  }

  //send message
  function sendMessage(address friend_key, string calldata _message) external {
    require(_checkUserExists(msg.sender), "Create an account first");
    require(_checkUserExists(friend_key), "User do not exists");
    require(checkAlreadyFriend(msg.sender, friend_key), "You can only send messages to friends");

    bytes32 chatCode = _getChatCode(msg.sender, friend_key);
    Message memory newMsg = Message(msg.sender, block.timestamp, _message);
    allMessages[chatCode].push(newMsg);
  }

  //Read message
  function readMessage(address friend_key) external view returns(Message[] memory) {
    bytes32 chatCode = _getChatCode(msg.sender, friend_key);
    return allMessages[chatCode];
  }
}
