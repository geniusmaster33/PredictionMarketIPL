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
    address[] public playerList;
    
    struct PlayerStat {
        uint256 toalWinAmount;
        uint256 totalLooseAmount;
        uint256 totalWins;
        uint256 totalLoose;
        uint256 totalBets;
    }
    
    struct MatchStat {
        uint256 toalWinAmount;
        uint256 totalLooseAmount;
        uint256 totalWins;
        uint256 totalLoose;
        uint256 totalBets;
    }
    
    struct QuestionStat {
        uint256 toalWinAmount;
        uint256 totalLooseAmount;
        uint256 totalWins;
        uint256 totalLoose;
        uint256 totalBets;
    }
    
    mapping (address => uint) public playerRank;
    mapping (address => PlayerStat) public playerStats;
    mapping (address => MatchStat) public matchStats;
    mapping (address => QuestionStat) public questionStats;

    AddressSetLib.AddressSet matches;
   
    // events
    
    event LogMatchAdded(uint indexed matchId);

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
        require(matches.size()+1 == _id);
        
        IPLMatch match1 = new IPLMatch(_id, tokenAddress);
        match1.setMultiplier([uint256(2),uint256(3),uint256(4),uint256(5),uint256(6),uint256(7)]);
        matches.add(address(match1));
        
        emit LogMatchAdded(_id);
        
        return (true, address(match1));
    }

    function addPlayer(address _playerAddress, string playerName) 
        onlyAdmin 
        onlyNotHalted
        returns (bool ok)
    {
        
        require(!isTrustedSource[_playerAddress]);
        
        isTrustedSource[_playerAddress] = true;
        token.addTokens(_playerAddress,500);
        playerNames[_playerAddress] = playerName;
        playerList.push(_playerAddress);
        
        return true;
    }
    
    function setPlayerRank(uint[] rankArray, address[] addressArray)
        onlyAdmin
        onlyNotHalted
        returns (bool ok)
    {
        uint i;
        for(i=0;i<addressArray.length;i++){
            playerRank[addressArray[i]] = rankArray[i];
        }
        
        return true;
        
    }
    
    
    
    //
    // getters for the frontend
    //
    

    function numMatches()
        constant
        returns (uint)
    {
        return matches.size();
    }

    function getMatchByIndex(uint i)
        constant
        returns (address)
    {
        return matches.get(i);
    }

    function getAllMatchAddresses()
        constant
        returns (address[])
    {
        return matches.values;
    }
    
    function getPlayerList()
        constant
        returns (address[])
    {
        return playerList;
    }
   /* function getAllPlayerStats()
        constant
        returns(PlayerStat[])
    {
        uint i;
        PlayerStat[] memory allPlayerStats;
        for (i=0;i<playerList.length;i++)
        {
            allPlayerStats.push(playerStats[playerList[i]]);
        }
        
        return allPlayerStats;
    }*/
    
    /*function getAllMatchStats
        constant
    {
        
    }
    function getAllQuestionStats
        constant
    {
        
    }
    function getAllPlayerRanks
        constant
    {
        
    }*/
}
