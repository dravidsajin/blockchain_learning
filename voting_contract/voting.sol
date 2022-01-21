// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

contract voting {

    /*
        contains person information
    */
    struct ParticipantsInfo {
        address personAddress;
        bytes personName;
        bytes personSymbol;
    }
    ParticipantsInfo[] public pInfo;

    mapping(address => bytes) public partipantEntered;
    mapping(address => uint) public partipantVotesCount;
    mapping(address => bool) public votingPerson;
    address[] public votingUsersList = [0x810025e0B09C6a2b638048d8a16a6F0B09520CF6, 0x5810e7e21ea7d71a5c11e752ff04d73ceA8E2F1a];

    /*
        @params _address: address of the participant
        @params _name: name of the participant
        @params _symbol: symbol of the participant
    */
    function register(address _address, bytes memory _name, bytes memory _symbol) public {
        require(bytes(partipantEntered[_address]).length == 0, "Already registered");
        partipantEntered[_address] = _symbol;
        pInfo.push(ParticipantsInfo(_address,_name,_symbol));
    }

    /*
        @returns array of participants
    */
    function getParticipants() public view returns (ParticipantsInfo[] memory) {
        return pInfo;
    }

    function addVote(bytes memory _symbol, address _votingpersonAddress) public {
        bool alreadyVoted = false;
        for(uint i = 0; i < votingUsersList.length - 1; i++) {
            if (votingUsersList[i] == _votingpersonAddress) {
                alreadyVoted = true;
                break;
            }
        }
        require(alreadyVoted == true, "Access denied");
        require(votingPerson[_votingpersonAddress] != true, "Already voted");
        for (uint i = 0; i < pInfo.length - 1; i++) {
            bytes memory votesymbol = pInfo[i].personSymbol;
            if (keccak256(votesymbol) == keccak256(_symbol)) {
                partipantVotesCount[pInfo[i].personAddress]++;
                votingPerson[_votingpersonAddress] = true;
                break;
            }
        }
    }
}