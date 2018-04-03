pragma solidity ^0.4.15;

import './IPLMatch.sol';
import './Haltable.sol';
import './MultiOwnable.sol';
import './AddressSetLib.sol';
import './EIP20Interface.sol';


contract Ipl is MultiOwnable, Haltable
{
    // libs
    using AddressSetLib for AddressSetLib.AddressSet;
    address public tokenAddress;
    EIP20Interface token;
    // state
    mapping(address => bool) public isTrustedSource;
    mapping(address => string) public playerNames;

    mapping(bytes32 => bool) public questionHasBeenAsked;
    AddressSetLib.AddressSet questions;
   
    // events
    event LogAddQuestion(address whoAdded, address questionAddress, string questionStr, uint betDeadlineBlock, uint voteDeadlineBlock);
    event LogAddETHFuturesQuestion(address whoAdded, address questionAddress, uint targetUSDPrice, uint betDeadlineBlock, uint voteDeadlineBlock);

    function Ipl(address _token) {
        isAdmin[msg.sender] = true;
        token =  EIP20Interface (_token);
        tokenAddress = _token;
    }

    //
    // administrative functions
    //

    function haltSwitch(bool _isHalted)
        onlyAdmin
        returns (bool ok)
    {
        return _haltSwitch(msg.sender, _isHalted);
    }

    // due to our multi-admin setup, it's probably useful to be able to specify the recipient
    // of the destroyed contract's funds.
    function kill(address recipient)
        onlyAdmin
        onlyHalted
        returns (bool ok)
    {
        selfdestruct(recipient);
        return true;
    }

    //
    // business logic
    //

    function addMatch(uint _id)
        onlyAdmin
        onlyNotHalted
        returns (bool ok, address questionAddr)
    {
        IPLMatch match1 = new IPLMatch(_id, tokenAddress);
        match1.setMultiplier([uint256(2),uint256(3),uint256(4),uint256(5),uint256(6),uint256(7)]);
        questions.add(address(match1));
        //LogAddQuestion(msg.sender, address(question), questionStr, betDeadlineBlock, voteDeadlineBlock);
        return (true, address(match1));
    }

    function addPlayer(address _playerAddress, string playerName) onlyAdmin {
        isTrustedSource[_playerAddress] = true;
        token.addTokens(_playerAddress,500);
        playerNames[_playerAddress] = playerName;
    }
    
    //
    // getters for the frontend
    //
    

    function numQuestions()
        constant
        returns (uint)
    {
        return questions.size();
    }

    function getQuestionIndex(uint i)
        constant
        returns (address)
    {
        return questions.get(i);
    }

    function getAllQuestionAddresses()
        constant
        returns (address[])
    {
        return questions.values;
    }
}
