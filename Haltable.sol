pragma solidity ^0.4.15;

import './SafeMath.sol';
import './Interfaces.sol';
import './Ownable.sol';
import './Haltable.sol';
import './EIP20Interface.sol';


contract IPLMatch is Haltable, Ownable
{
    using SafeMath for uint;

    EIP20Interface token;
    
    uint public matchId;
    uint256[6] public multiplier;

    struct Bet {
       uint256[5] weight;
       uint256[5] option;
       uint256 totalBet;
    }
    
    struct Result {
        uint256[5] win;
        uint256[5] loose;
        uint256 totalWin;
        uint256 totalLoose;
    }

    uint256[5] public qPot;
    uint256 public totalPot;
    mapping(address => bool) public isBet;
    mapping(address => Bet) public bets;
    mapping(address => Result) public results;
    
    address[] public playerList;
    
    bool public matchAbandon;
    bool public matchEnd;
    
    event LogBet(uint matchId,address bettor, uint256 betAmount);
    event LogBetReset(uint matchId, address bettor, address adminAddress);
    event LogBetSwitch(uint matchId, address adminAddress, bool isHalted);
    event LogQuestionBetWin(uint matchId,uint questionId,address playerAddress,uint256 winningAmount,uint256 multiplier);
    event LogQuestionBetLoose(uint matchId,uint questionId,address playerAddress,uint256 loosingAmount);
    event LogWin(uint matchId,address playerAddress,uint256 winningAmount,uint256 loosingAmount,uint256 toalBet);
    event LogLoose(uint matchId,address playerAddress,uint256 winningAmount,uint256 loosingAmount,uint256 toalBet);
    
    function IPLMatch(uint _id, address _token){
        matchId = _id;
        token =  EIP20Interface (_token);
    }

    function bet(uint256[5] _weight, uint256[5] _option)
        payable
        onlyNotHalted
        canBet
        returns (bool ok)
    {
        require (!matchAbandon);
        
        if(!isBet[msg.sender]){
            playerList.push(msg.sender);
        }
        
        uint256 sum = 0;
        uint i;
        for(i=0;i<5;i++){
            bets[msg.sender].weight[i] = _weight[i];
            qPot[i] += _weight[i];
            bets[msg.sender].option[i] = _option[i];
            sum += _weight[i];
        }
        bets[msg.sender].totalBet = sum;
        totalPot+= sum;
        require(token.balanceOf(msg.sender) >= sum);
        token.minusTokens(msg.sender,sum);
        isBet[msg.sender] = true;
        emit LogBet(matchId,msg.sender,sum);

        return true;
    }
   
    
    //
    // frontend convenience getters
    //

   
    function getBetLength()
        constant
        returns (uint betLength)
    {
        return playerList.length;
    }
    
    //
    // Utility Functions
    //
    
    function endMatch(uint[5] options) onlyOwner onlyHalted returns (bool ok){
        
            uint i;
            
            for (i=0; i<playerList.length; i++){
                address playerAddress = playerList[i];
                uint profitTokens;
                Bet storage myBet = bets[msg.sender];
                
                //Send Regular Supply if totalBet > 60
                if(myBet.totalBet >59)
                {
                    profitTokens += 100;
                }
                
                for(i=0; i<5;i++){
                    if(myBet.option[i] == options[i])
                    {
                        uint amt;
                        amt = myBet.weight[i] * multiplier[i];
                        profitTokens+=amt;
                        results[playerAddress].win[i]=amt;
                        results[playerAddress].totalWin+=amt;
                        emit LogQuestionBetWin(matchId,i,playerAddress,amt,multiplier[i]);
                    }
                    else
                    {
                        uint amt1 = myBet.weight[i];
                        results[playerAddress].loose[i]=amt1;
                        results[playerAddress].totalLoose += amt1;
                        emit LogQuestionBetLoose(matchId,i,playerAddress,amt1);
                    }
                }
                if ((myBet.option[4] >= (options[4]-10)) && (myBet.option[4] <= (options[4]+10)) && (myBet.option[4] != options[4])){
                    uint amt2 = myBet.option[4] * multiplier[5];
                    profitTokens+= amt2;
                    results[playerAddress].win[4]+=amt2;
                    results[playerAddress].totalWin+=amt2;
                    results[playerAddress].loose[4]=0;
                        results[playerAddress].totalLoose -= myBet.weight[4];
                   emit LogQuestionBetWin(matchId,5,playerAddress,amt2,multiplier[5]);
                    
                }
                token.addTokens(playerAddress,profitTokens);
                if(results[playerAddress].totalWin > results[playerAddress].totalLoose){
                    emit LogWin(matchId,playerAddress,results[playerAddress].totalWin,results[playerAddress].totalLoose,myBet.totalBet);
                }
                else{
                    emit LogLoose(matchId,playerAddress,results[playerAddress].totalWin,results[playerAddress].totalLoose,myBet.totalBet);
                }
                
                
            }
                   
           return true;
    }
    
    function abandonMatch() onlyOwner {
        
    }
    
    function resetBet(address _who,address _bettor) onlyOwner returns (bool ok){
        uint i;
        uint256 sum;
        
        sum = bets[_bettor].totalBet;
        for(i=0;i<5;i++){
            qPot[i] -= bets[_bettor].weight[i];
        }
        delete bets[_bettor];
        totalPot -= sum ;
        token.addTokens(msg.sender,sum);
        
        emit LogBetReset (matchId, _bettor, _who);
        return true;
        
        
    }
    function haltSwitch(address _who, bool _isHalted)
        onlyOwner
        returns (bool ok)
    {
        require(isHalted != _isHalted);
        isHalted = _isHalted;
        emit LogBetSwitch(matchId,_who, _isHalted);
        return true;
    }
    
    

    // due to our multi-admin setup, it's probably useful to be able to specify the recipient
    // of the destroyed contract's funds.
    function kill(address recipient)
        onlyOwner
        onlyHalted
        returns (bool ok)
    {
        selfdestruct(recipient);
        return true;
    }

    function getMultipler() onlyOwner returns(uint[6] mulx){
        uint[6] memory mult;
        mult = multiplier;
        return mult;
    }
    
    function setMultiplier(uint256[6] mul) onlyOwner returns(bool ok){
        uint i;
        for(i=0;i<5;i++){
            multiplier[i] = mul[i];
        }
        return true;
    }
    //
    // modifiers
    //

    modifier onlyAdmin {
        IPredictionMarket mkt = IPredictionMarket(owner);
        require(mkt.isAdmin(msg.sender));
        _;
    }
    
    modifier canBet {
        require(bets[msg.sender].totalBet == 0);
        _;
    }

   
}