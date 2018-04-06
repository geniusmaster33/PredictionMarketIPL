pragma solidity ^0.4.15;

import './Interfaces.sol';
import './Ownable.sol';
import './Haltable.sol';
import './EIP20Interface.sol';
import './RegistrationInterface.sol';


contract IPLMatch is Haltable, Ownable
{
    //using SafeMath for uint;

    EIP20Interface public token;
    RegistrationInterface public register;
    
    uint256 public dailyBonus;
    uint256 public threshold;
    
    uint public matchId;
    uint256[6] public multiplier;

    struct Bet {
       uint256[5] weight;
       uint256[5] option;
       uint256 totalBet;
    }
    
    struct Result {
        uint[5] wonLost;
        uint256[5] amtWon;
        uint256[5] amtLost;
        uint256 totalWon;
        uint256 totalLost;
        
    }
    
    struct MatchResult{
        uint256[5] numquestionWon;
        uint256[5] numquestionLost;
        uint256[5] amtQuestionWins;
        uint256[5] amtQuestionLost;
        uint256[5] amtQuestionWinBet;
        uint256 totalWin;
        uint256 totalLoose;
        
        
    }
    
    MatchResult public matchResult;

    uint256[5] public qPot;
    uint256 public totalPot;
    mapping(address => bool) public isBet;
    mapping(address => Bet) public bets;
    mapping(address => Result) public results;
    
    address[] public playerList;
   
    
    bool public matchAbandon;
    bool public matchEnd;
    bool public calculateWinLost;
    
    event LogBet(uint indexed matchId,address indexed bettor, uint256 betAmount);
    event LogBetReset(uint indexed matchId, address indexed bettor, address adminAddress);
    event LogBetSwitch(uint indexed matchId, address adminAddress, bool isHalted);
    event LogQuestionBetWin(uint indexed matchId,uint indexed questionId,address playerAddress,uint256 winningAmount,uint256 multiplier);
    event LogQuestionBetLoose(uint indexed matchId,uint indexed questionId,address indexed playerAddress,uint256 loosingAmount);
    event LogWin(uint indexed matchId,address indexed playerAddress,uint256 winningAmount,uint256 loosingAmount,uint256 toalBet);
    event LogLoose(uint indexed matchId,address indexed playerAddress,uint256 winningAmount,uint256 loosingAmount,uint256 toalBet);
    event LogDailyBonus(uint indexed matchId,address indexed playerAddress);
    
    function IPLMatch(uint _id, address _register, uint256 _dailyBonus, uint256 _threshold,address _tokenAddress){
        matchId = _id;
        register = RegistrationInterface(_register);
        token =  EIP20Interface (_tokenAddress);
        dailyBonus=_dailyBonus;
        threshold=_threshold;
        
        
    }

    function bet(uint[5] _weight, uint[5] _option)
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
        
        if(sum >= threshold)
        {
         token.addTokens(msg.sender,dailyBonus);
         emit LogDailyBonus(matchId,msg.sender);
        }
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
    
    function calculateWinLoss(uint256[5] options) onlyAdmin onlyHalted returns (bool ok){
        
        uint j;
        for(j=0;j<playerList.length;j++){
            address playerAddress = playerList[j];
            Bet storage myBet = bets[playerAddress];
            uint i;
            for(i=0;i<5;i++){
                if(myBet.option[i] == options[i]){
                    results[playerAddress].wonLost[i]=1;
                    matchResult.amtQuestionWinBet[i] += myBet.weight[i];
                    matchResult.totalWin++;
                }
            }
            if ((myBet.option[4] >= (options[4]-10)) && (myBet.option[4] <= (options[4]+10)) && (myBet.option[4] != options[4])){
            
                results[playerAddress].wonLost[4]=2;
                matchResult.amtQuestionWinBet[4] += myBet.weight[4];
            }
        }
        calculateWinLost = true;
        return true;
    }
    
    function endMatch() onlyAdmin onlyHalted returns (bool ok){
        require(calculateWinLost);
        uint j;
        for(j=0;j<playerList.length;j++){
            address playerAddress = playerList[j];
            Bet storage myBet = bets[playerAddress];
            uint profitTokens;
            profitTokens = 0;
            uint i;
            for(i=0; i<5;i++)
            {
                if(results[playerAddress].wonLost[i] == 1){
                    uint amt;
                    uint bet = myBet.weight[i];
                    amt = 0;
                    amt = (bet * multiplier[i] / 10) + bet + ((bet / matchResult.amtQuestionWinBet[i]) * qPot[i]);
                    profitTokens+=amt;
                }
                
            }
            if(results[playerAddress].wonLost[4] == 2){
                    uint amt1;
                    uint bet1 = myBet.weight[i];
                    amt1 = 0;
                    amt1 = (bet1 * multiplier[5] / 10) + bet1 + ((bet1 / matchResult.amtQuestionWinBet[i]) * qPot[i]);
                    profitTokens+=amt1;
                }
            token.addTokens(playerAddress,profitTokens);
        
        }
    }   
    
    /*
            uint i;
            
            for (i=0; i<playerList.length; i++){
                address playerAddress = playerList[i];
                uint profitTokens;
                Bet storage myBet = bets[msg.sender];
                
                for(i=0; i<5;i++){
                    if(myBet.option[i] == options[i])
                    {
                        uint amt;
                        amt = myBet.weight[i] * multiplier[i];
                        profitTokens+=amt;
                        results[playerAddress].win[i]=amt;
                        results[playerAddress].totalWin+=amt;
                       // emit LogQuestionBetWin(matchId,i,playerAddress,amt,multiplier[i]);
                    }
                    else
                    {
                        uint amt1 = myBet.weight[i];
                        results[playerAddress].loose[i]=amt1;
                        results[playerAddress].totalLoose += amt1;
                        //emit LogQuestionBetLoose(matchId,i,playerAddress,amt1);
                    }
                }
                if ((myBet.option[4] >= (options[4]-10)) && (myBet.option[4] <= (options[4]+10)) && (myBet.option[4] != options[4])){
                    uint amt2 = myBet.option[4] * multiplier[5];
                    profitTokens+= amt2;
                    results[playerAddress].win[4]+=amt2;
                    results[playerAddress].totalWin+=amt2;
                    results[playerAddress].loose[4]=0;
                        results[playerAddress].totalLoose -= myBet.weight[4];
                   //emit LogQuestionBetWin(matchId,5,playerAddress,amt2,multiplier[5]);
                    
                }
            }
                //token.addTokens(playerAddress,profitTokens);
                if(results[playerAddress].totalWin > results[playerAddress].totalLoose){
                    emit LogWin(matchId,playerAddress,results[playerAddress].totalWin,results[playerAddress].totalLoose,myBet.totalBet);
                }
                else{
                    emit LogLoose(matchId,playerAddress,results[playerAddress].totalWin,results[playerAddress].totalLoose,myBet.totalBet);
                }
                
                
            }
                   
           return true;
    }
    */
    function abandonMatch() onlyAdmin {
        
    }
    
    function getPlayerLength() view returns (uint len){
        return playerList.length;
    }
    function resetBet(address _who,address _bettor) onlyAdmin returns (bool ok){
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
    function haltSwitch(bool _isHalted)
        onlyAdmin
        returns (bool ok)
    {
        require(isHalted != _isHalted);
        isHalted = _isHalted;
        emit LogBetSwitch(matchId,msg.sender, _isHalted);
        return true;
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

    function getMultipler() view returns(uint[6] mulx){
        uint[6] memory mult;
        mult = multiplier;
        return mult;
    }
    

    function setMultiplier(uint256[6] mul) returns(bool ok){
        uint i;
        for(i=0;i<6;i++){
            multiplier[i] = mul[i];
        }
        return true;
    }
    
    function setTokenAddress(address _tokenAddress) onlyAdmin returns(bool ok){
        token = EIP20Interface(_tokenAddress);
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