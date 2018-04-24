pragma solidity ^0.4.20;

import "./IPLMatch.sol";

contract abc{
    
    IPLMatch ipl;
    EIP20Interface token;
    event LogBet(address,uint256);
     struct Bet {
       uint256[5] weight;
       uint256[5] option;
       uint256 totalBet;
    }
    
    function abc(){
        ipl = IPLMatch(0xb3450bcb3ea7794bde0a5eb9586c083eff07cd84);
        token = EIP20Interface(0x419bd45f4a8289ed702a7ce33016f84f2b0c4dda);
    }
    
    struct Result{
        uint256[5] wonLost;
    }
    mapping(address => Result) results;
    
    struct MatchResult{
        uint[5] amtQuestionWinBet;
    }
    
    MatchResult matchResult;
    
     function calculateWinLoss(uint256[5] options)returns (bool ok){
        uint j;
        for(j=0;j<ipl.getPlayerLength();j++){
            address playerAddress = ipl.playerList(j);
            Bet memory myBet;
            (myBet.weight,myBet.option,myBet.totalBet) = ipl.getPlayerBet(playerAddress);
            uint i;
            for(i=0;i<5;i++){
                if(myBet.option[i] == options[i]){
                    results[playerAddress].wonLost[i]=1;
                    matchResult.amtQuestionWinBet[i] += myBet.weight[i];
                }
            }
            if ((myBet.option[4] >= (options[4]-10)) && (myBet.option[4] <= (options[4]+10)) && (myBet.option[4] != options[4])){
            
                results[playerAddress].wonLost[4]=2;
                matchResult.amtQuestionWinBet[4] += myBet.weight[4];
            }
        }
        return true;
    }
    
    function endMatch() returns (bool ok){
        uint j;
        for(j=0;j<ipl.getPlayerLength();j++){
            address playerAddress = ipl.playerList(j);
            Bet memory myBet;
            (myBet.weight,myBet.option,myBet.totalBet) = ipl.getPlayerBet(playerAddress);
            uint profitTokens;
            profitTokens = 0;
            uint i;
            for(i=0; i<5;i++)
            {
                if(results[playerAddress].wonLost[i] == 1){
                    uint amt;
                    uint bet = myBet.weight[i];
                    amt = 0;
                    if(matchResult.amtQuestionWinBet[i] != 0){
                    amt = ((bet * ipl.multiplier(i)) / 10) + bet + ((bet * ipl.qPot(i))/matchResult.amtQuestionWinBet[i]);
                    }
                    else
                    {
                        amt = ((bet * ipl.multiplier(i)) / 10) + bet;
                    }
                    profitTokens+=amt;
                }
                
            }
            if(results[playerAddress].wonLost[4] == 2){
                    uint amt1;
                    uint bet1 = myBet.weight[4];
                    amt1 = 0;
                     if(matchResult.amtQuestionWinBet[4] != 0){
                    amt1 = ((bet1 * ipl.multiplier(5)) / 10) + bet1 + ((bet1 * ipl.qPot(4))/ matchResult.amtQuestionWinBet[4]);
                     }
                     else
                     {
                       amt1 = ((bet1 * ipl.multiplier(5)) / 10) + bet1 ;  
                     }
                    profitTokens+=amt1;
                }
                
                LogBet(playerAddress,profitTokens);
                if(profitTokens > 0){
                token.addTokens(playerAddress,profitTokens);
                }
        
        }

    }
    
    function addTokens(){
        token.addTokens(msg.sender,10);
    }
}