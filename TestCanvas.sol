pragma solidity ^0.4.15;
pragma experimental ABIEncoderV2;

contract Test
{
    struct Bet {
        //mapping(uint => uint) q;
        //mapping(uint => uint) option;
        uint[5] q;
        uint[5] o;
        uint totalBet;
        address better;
    }
    
    struct Check{
        uint a;
        uint b;
        uint c;
    }
    
    mapping(address => Bet) public bets;
    mapping(address => Check) public checks;
    
    function placeBet(uint[5] q, uint[5]  option) public returns (bool ok)
    {
        uint i;
        for(i=0; i<=4; i++){
            bets[msg.sender].q[i] = q[i];
            bets[msg.sender].o[i] = option[i];    
        }
        bets[msg.sender].better = msg.sender;
        return true;
    }
    
    function placeCheck(uint _a,uint _b, uint _c) {
        checks[msg.sender].a =_a;
        checks[msg.sender].b =_b;
        checks[msg.sender].c =_c;
    }
    
    function myBet() public view returns(uint[5] o, uint[5] q){
        uint[5] memory option;
        uint[5] memory question;
        option = bets[msg.sender].o;
        question = bets[msg.sender].q;
        return (option, question);
        
    }
    function calc(uint256 abc) returns (uint256 a){
        return abc/2+abc;
    }
    function del(){
        delete bets[msg.sender];
    }
    function getCheck() constant returns(Bet myBet){
        return bets[msg.sender];
    } 
    
}