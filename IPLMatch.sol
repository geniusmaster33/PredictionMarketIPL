pragma solidity ^0.4.15;

import './SafeMath.sol';
import './Interfaces.sol';
import './Ownable.sol';
import './Haltable.sol';
import './EIP20Interface.sol';


contract Match is Haltable, Ownable
{
    using SafeMath for uint;

    EIP20Interface token =  EIP20Interface (0x35ef07393b57464e93deb59175ff72e6499450cf);
    
    uint public matchId;
    uint256[6] public multiplier;

    struct Bet {
       uint256[5] weight;
       uint256[5] option;
       uint totalBet;
    }
    
    struct Result {
        uint256 win;
        uint256 loose;
        
    }

    uint256[5] public qPot;
    uint256 public totalPot;
    mapping(adress => bool) public isBet;
    mapping(address => Bet) public bets;
    address[] playerList;
   
    bool public matchAbandon;
    bool public matchEnd;
    
    event LogBet(uint matchId,address bettor, uint256 betAmount);
    event LogBetReset(uint matchId, address bettor, address adminAddress);
    event LogBetSwitch(uint matchId, address adminAddress, bool isHalted);
    function Match(uint _id){
        matchId = _id;
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
            qPot[i] += _weight[i]
            bets[msg.sender].option[i] = _option[i];
            sum += _weight[i];
        }
        bets[msg.sender].totalBet = sum;
        totalPot+= sum;
        token.minusToken(msg.sender,sum);

        emit LogBet(matchId,msg.sender,sum);

        return true;
    }
   
    
    //
    // frontend convenience getters
    //

    function getMetadata()
        constant
        returns (string _questionStr, uint _betDeadlineBlock, uint _voteDeadlineBlock, uint _yesVotes, uint _noVotes, uint _yesFunds, uint _noFunds)
    {
        return (questionStr, betDeadlineBlock, voteDeadlineBlock, yesVotes, noVotes, yesFunds, noFunds);
    }
    
    //
    // Utility Functions
    //
    
    function endMatch(uint[5] options) onlyOwner onlyHalted returns (bool ok){
        
            
                   
           return true;
    }
    
    function abandonMatch() onlyOwner {
        
    }
    
    function resetBet(adress _who,address _bettor) onlyOwner returns (bool ok){
        uint i;
        uint256 sum;
        
        sum = bets[_better].totalBet
        for(i=0;i<5;i++){
            qPot[i] -= bets[_bettor].weight[i];
        }
        delete bets[_bettor];
        totalPot -= sum ;
        token.addToken(msg.sender,sum);
        
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
        
    }
    
    function setMultiplier
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