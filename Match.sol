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
     uint[5] public multiplier;

    struct Bet {
       uint[5] weight;
       uint[5] option;
       uint totalBet;
    }

    uint public totalPot;
    uint[5] public qPot;
    mapping(address => Bet) public bets;
    address[] playerList;
   
    
    event LogBet(address bettor, Vote vote, uint betAmount);
    event LogVote(address trustedSource, Vote vote);
    event LogWithdraw(address who, uint amount);

    function Match() {
    }

    function haltSwitch(address _who, bool _isHalted)
        onlyAdmin
        returns (bool ok)
    {
        return _haltSwitch(_who, _isHalted);
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

    function bet(uint[5] weight, uint[5] option)
        payable
        onlyNotHalted
        canBet
        returns (bool ok)
    {
        

       

        LogBet(msg.sender, betVote, msg.value);

        return true;
    }

    // this method is intended to be called by contracts inheriting from BinaryQuestion, hence why
    // it's marked `internal`.  this helps us account for the different ways of "voting" on a question
    // (human trusted sources, an oracle, etc.)
    function vote(address voter, bool yesOrNo)
        internal
        returns (bool ok)
    {
        require(block.number > betDeadlineBlock);
        require(block.number <= voteDeadlineBlock);
        require(votes[voter] == Vote.None);

        Vote voteValue;
        if (yesOrNo == true) {
            yesVotes = yesVotes.safeAdd(1);
            voteValue = Vote.Yes;
        } else {
            noVotes = noVotes.safeAdd(1);
            voteValue = Vote.No;
        }

        votes[voter] = voteValue;

        LogVote(voter, voteValue);

        return true;
    }

    function withdraw()
        returns (bool ok)
    {
        require(block.number > voteDeadlineBlock);

        Bet storage theBet = bets[msg.sender];
        require(theBet.amount > 0);
        require(theBet.withdrawn == false);

        theBet.withdrawn = true;

        // if nobody voted, or the vote was a tie, the bettors are allowed to simply withdraw their bets
        if (yesVotes == noVotes) {
            msg.sender.transfer(theBet.amount);

            LogWithdraw(msg.sender, theBet.amount);
            return true;
        }

        uint winningVoteFunds;
        if (yesVotes > noVotes) {
            require(theBet.vote == Vote.Yes);
            winningVoteFunds = yesFunds;
        } else if (noVotes > yesVotes) {
            require(theBet.vote == Vote.No);
            winningVoteFunds = noFunds;
        }

        uint totalFunds = yesFunds.safeAdd(noFunds);
        uint withdrawAmount = totalFunds.safeMul(theBet.amount).safeDiv(winningVoteFunds);

        msg.sender.transfer(withdrawAmount);

        LogWithdraw(msg.sender, withdrawAmount);
        return true;
    }

    // onlyAdmin calls back to the PredictionMarket contract that spawned this question to ensure
    // that msg.sender is an admin.  it's much easier and cheaper to centralize storage of our
    // list of admins.
    modifier onlyAdmin {
        IPredictionMarket mkt = IPredictionMarket(owner);
        require(mkt.isAdmin(msg.sender));
        _;
    }
    
    modifier canBet {
        require(bets[msg.sender].totalBet == 0);
        _;
    }

 

    function vote(bool yesOrNo)
        onlyTrustedSource
        returns (bool ok)
    {
        return BinaryQuestion.vote(msg.sender, yesOrNo);
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
    // modifiers
    //

   
}