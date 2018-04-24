pragma solidity ^0.4.20;

import './MultiOwnable.sol';
import './Haltable.sol';
import './EIP20Interface.sol';
import './RegistrationInterface.sol';

contract AddAdditionalBounty is MultiOwnable,Haltable {
    
    RegistrationInterface public register;
    EIP20Interface public token;
    
    
    constructor (address _register, address _token) public{
        isAdmin[msg.sender] =  true;
        register = RegistrationInterface(_register);
        token = EIP20Interface(_token);
    }
    
    function addBounty(uint256 _bounty) public onlyAdmin{
        uint i;
        address[] memory myPlayerList = register.getPlayerList();
        for(i=0;i<register.getNumberPlayers();i++){
            token.addTokens(myPlayerList[i],_bounty);
        }
        
    }
    
    function subBounty(uint256 _bounty) public onlyAdmin{
        uint i;
        address[] memory myPlayerList = register.getPlayerList();
        for(i=0;i<register.getNumberPlayers();i++){
            token.minusTokens(myPlayerList[i],_bounty);
        }
        
    }
    
}