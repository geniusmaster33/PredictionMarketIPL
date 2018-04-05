pragma solidity ^0.4.20;

import './MultiOwnable.sol';
import './EIP20Interface.sol';
import './RegistrationInterface.sol';

contract Registration is MultiOwnable, RegistrationInterface {
    
  
    
    function Registration(address _tokenAddress){
        tokenAddress = _tokenAddress;
        token = EIP20Interface(_tokenAddress);
        startingPoints = 100;
    
    }
    
    //AdminFunctions
    
     function addPlayer(address _playerAddress, string playerName, uint _playerType)
        public returns (bool ok)
    {
        
        require(!isTrustedPlayer[_playerAddress]);
        
        isTrustedPlayer[_playerAddress] = true;
        token.addTokens(_playerAddress,startingPoints);
        playerNames[_playerAddress] = playerName;
        playerType[_playerAddress]=_playerType;
        playerList.push(_playerAddress);
        playerBalances.push(token.balanceOf(_playerAddress));
        playerTypes.push(_playerType);
        
        emit LogAddPlayer(_playerAddress, playerName, _playerType);
        
        return true;
    }
    
    function freezePlayer(address _playerAddress, bool freezeStatus)
    public onlyAdmin returns(bool ok){
        
        require(isTrustedPlayer[_playerAddress]);    
        
        isPlayerFrozen[_playerAddress] = freezeStatus;
        
        emit LogPlayerStatus(_playerAddress, freezeStatus) ;
        return true;
        
    }
    
    //Utility Functions
    
    function getPlayerList() public view returns(address[] _playerList){
        return playerList;
    }
    
    function getNumberPlayers() public view returns (uint numberPlayer){
        return playerList.length;
    }
    
    function getPlayerBalance(address _playerAddress) public view returns (uint balance){
        return token.balanceOf(_playerAddress);
    }
    
    function getPlayerDetail() public returns(address[] _playerList, uint256[] balance, uint[] _playerType){
        uint i;
        for(i=0;i<playerList.length;i++){
            playerBalances[i] = token.balanceOf(playerList[i]);
            playerTypes[i]= playerType[playerList[i]];
        }
        
        return (playerList,playerBalances,playerTypes);
        
    }
    function getLeaderBoard() constant returns(address[] _playerList, uint256[] balance, uint[] _playerType){
        return (playerList,playerBalances,playerTypes);
    }
   
    function changeTokenAddress(address _newTokenAddress) public onlyAdmin returns(bool ok){
        tokenAddress = _newTokenAddress;
        token = EIP20Interface(_newTokenAddress);
        
        return true;
    }
    
    function changeStartingPoints(uint256 newPoints) public onlyAdmin returns(bool ok){
        
        emit LogChangeStartingpoint(startingPoints,newPoints);
        startingPoints = newPoints;
        return true;
    }
    
     function setPlayerRank(uint[] rankArray, address[] addressArray)
        public
        onlyAdmin
        returns (bool ok)
    {
        uint i;
        for(i=0;i<addressArray.length;i++){
            playerRank[addressArray[i]] = rankArray[i];
        }
        
        return true;
        
    }
    
    
    
}