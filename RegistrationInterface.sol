pragma solidity ^0.4.20;

import './MultiOwnable.sol';
import './EIP20Interface.sol';

contract RegistrationInterface {
    
    struct PlayerStat {
        uint256 toalWinAmount;
        uint256 totalLooseAmount;
        uint256 totalWins;
        uint256 totalLoose;
    }
    
    struct MatchStat {
        uint256 toalWinAmount;
        uint256 totalLooseAmount;
        uint256 totalWins;
        uint256 totalLoose;
    }
    
    struct QuestionStat {
        uint256 toalWinAmount;
        uint256 totalLooseAmount;
        uint256 totalWins;
        uint256 totalLoose;
    }
    
    mapping(address => bool) public isTrustedPlayer;
    mapping(address => bool) public isPlayerFrozen;
    mapping(address => string) public playerNames;
    address[] public playerList;
    uint256[] public playerBalances;
    uint256[] public playerTypes;
    
    uint256 public startingPoints;
   
    address public tokenAddress;
   
    EIP20Interface token;
    
    mapping (address => uint) public playerRank;
    mapping (address => PlayerStat) public playerStats;
      mapping (address => uint) public playerType;
    mapping (address => MatchStat) public matchStats;
    mapping (uint => QuestionStat) public questionStats;
    
    
    //AdminFunctions
    
     function addPlayer(address _playerAddress, string playerName, uint _playerType)
        public returns (bool ok);
    
    function freezePlayer(address _playerAddress, bool freezeStatus) public returns(bool ok);
    
    //Utility Functions
    
    function getPlayerList() public view returns(address[] _playerList);
    
    function getNumberPlayers() public view returns (uint numberPlayer);
    
    function getPlayerBalance(address _playerAddress) public view returns (uint balance);
    
    function getPlayerDetail() public returns(address[] _playerList, uint256[] balance,uint[] _playerType);
    
    function changeTokenAddress(address _newTokenAddress) public returns (bool ok);
    
    function changeStartingPoints(uint256 newPoints) public returns(bool ok);
    
    
    //Modifiers
    
    //Events
    
    event LogAddPlayer(address indexed playerAddress, string playerName, uint playerType);
    event LogChangeStartingpoint(uint256 oldPoints, uint256 newPoints);
    event LogPlayerStatus(address indexed playerAddress, bool freezeStatus);
    
    
    
}