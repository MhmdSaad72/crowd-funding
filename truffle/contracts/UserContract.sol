// SPDX-License-Identifier: MIT
pragma solidity >=0.4.17 <0.9.0;

contract UserContract {
    struct User{
        uint256 index; 
        address _address;
        string name;
        string email;
        string code;
        bool verified;
    }

    uint256 nonce;
    User[] public users;


    modifier uniqueEmail(string memory _email) {
        for (uint256 i = 0; i < users.length; i++) {
          require(!equal(users[i].email, _email), "u-err 1");
        }
        _;
    }

    function createUser(string memory _name, string memory _email) public uniqueEmail(_email){
      User memory _user = getUser(msg.sender);
      require(_user._address == address(0), "u-err 2");
      string memory _code = generateRandomString(nonce++);
      users.push(User(users.length, msg.sender, _name, _email, _code, false));
    }

    function updateUser(uint256 index, string memory _name) public{
      User storage user = users[index];
      require(user._address == msg.sender, "u-err 3");
      user.name = _name;
    }

    function getAllUsers() external view returns(User[] memory result) {
        result = new User[](users.length);
        result = users;
    }

    function getUser(address _sender) public view returns(User memory _user) {
        for (uint256 i = 0; i < users.length; i++) {
            if (users[i]._address == _sender) _user = users[i];
        }
    }

    function verification(uint256 index, string memory _code) public{
        User storage _user = users[index];
        require(equal(_user.code, _code) && _user._address == msg.sender, "u-err 4");
        _user.verified = true;
    }

    /* INTERNAL METHODS */
    function equal(string memory _value1, string memory _value2) internal pure returns(bool){
        return keccak256(abi.encodePacked(_value1)) == keccak256(abi.encodePacked(_value2));
    }

    function generateRandomString(uint256 _nonce) internal view returns (string memory) {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, _nonce)));
        return bytes32ToString(bytes32(randomNumber));
    }

    function bytes32ToString(bytes32 _bytes32) internal pure returns (string memory) {
        bytes memory bytesArray = new bytes(64);
        for (uint256 i = 0; i < 32; i++) {
            bytesArray[i * 2] = bytes1(hexChar(uint8(_bytes32[i] >> 4)));
            bytesArray[i * 2 + 1] = bytes1(hexChar(uint8(_bytes32[i] & 0x0f)));
        }
        return string(bytesArray);
    }

    function hexChar(uint8 _byte) internal pure returns (uint8) {
        return _byte < 10 ? _byte + 48 : _byte + 55;
    }

}
