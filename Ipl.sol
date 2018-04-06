pragma solidity ^0.4.15;

import './IPLMatch.sol';
import './Haltable.sol';
import './MultiOwnable.sol';
import './AddressSetLib.sol';
import './EIP20Interface.sol';
import './RegistrationInterface.sol';

contract Ipl is MultiOwnable, Haltable
{
    // libs
    using AddressSetLib for AddressSetLib.AddressSet;
    EIP20Interface public token;
    RegistrationInterface public register;
    
    uint256 public dailyBonus;
    uint256 public threshold;

    // state
    AddressSetLib.AddressSet matches;
   
    // events
    
    event LogMatchAdded(uint indexed matchId);
    event LogDailyBonusChange(uint256 oldBonus, uint256 newBonus);
    event LogThresholdChange(uint256 oldThreshold,uint256 newThreshold);

    function Ipl(address _register, address _tokenAddress) {
        isAdmin[msg.sender] = true;
        register = RegistrationInterface(_register);
        token =  EIP20Interface (_tokenAddress);
        dailyBonus = 100;
        threshold = 60;
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
        
        
        IPLMatch match1 = new IPLMatch(_id, address(register), dailyBonus, threshold, address(token));
        match1.setMultiplier([uint256(2),uint256(3),uint256(4),uint256(5),uint256(6),uint256(7)]);
        token.addAdminX(address(match1));
        matches.add(address(match1));
        
        emit LogMatchAdded(_id);
        
        return (true, address(match1));
    }
    
    function addMatchManually(uint _id, address matchAddress)
        onlyAdmin
        onlyNotHalted
        returns(bool ok)
    {
        require(matches.size()+1 == _id);
        matches.add(matchAddress);
        token.addAdminX(matchAddress);
        
        emit LogMatchAdded(_id);
        
        return true;
    
    }

    
    
   function setTregisterAddress(address _registerAddress) onlyAdmin returns(bool ok){
        register = RegistrationInterface(_registerAddress);
        return true;
    }
    
    function setTokenAddress(address _tokenAddress) onlyAdmin returns(bool ok){
        token = EIP20Interface(_tokenAddress);
        return true;
    }
    
     function changeDailyBonus(uint256 newBonus) public onlyAdmin returns(bool ok){
        
        emit LogDailyBonusChange(dailyBonus,newBonus);
        dailyBonus = newBonus;
        return true;
    }
    
      function changeThreshold(uint256 newThreshold) public onlyAdmin returns(bool ok){
        
        emit LogThresholdChange(threshold,newThreshold);
        threshold = newThreshold;
        return true;
    }
    
    //
    // getters for the frontend
    //
    

    function numMatches()
        public
        constant
        returns (uint)
    {
        return matches.size();
    }

    function getMatchByIndex(uint i)
        public
        constant
        returns (address)
    {
        return matches.get(i);
    }

    function getAllMatchAddresses()
        public
        constant
        returns (address[])
    {
        return matches.values;
    }
    
  
}
