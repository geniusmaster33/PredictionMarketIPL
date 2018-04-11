/*
Implements EIP20 token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
.*/


pragma solidity ^0.4.20;

import "./EIP20Interface.sol";
import "./MultiOwnable.sol";


contract EIP20 is MultiOwnable,EIP20Interface {

    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    uint public _totalSupply;
    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show.
    string public symbol;                 //An identifier: eg SBX

    function EIP20(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
    ) public {
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        _totalSupply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
        isAdmin[msg.sender]=true;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        return true;
    }
    
    function addTokens(address _to, uint256 _value) public onlyAdmin returns (uint256 balance) {
        balances[_to] += _value;
        _totalSupply += _value;
        emit Transfer(msg.sender, _to, _value); 
        return balances[_to];
    }
    
    function minusTokens(address _to, uint256 _value) public onlyAdmin returns (uint256 balance) {
        balances[_to] -= _value;
        _totalSupply -= _value;
        emit Transfer(_to, msg.sender, _value); 
        return balances[_to];
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }   
    
    function addAdmin(address admin)
        public
        onlyAdmin
        returns (bool ok)
    {
        require(isAdmin[admin] == false);
        isAdmin[admin] = true;

        emit LogAddAdmin(msg.sender, admin);
        return true;
    }
    
     function addAdminX(address admin)
        public
        onlyAdmin
        returns (bool ok)
    {
        require(isAdmin[admin] == false);
        isAdmin[admin] = true;

        emit LogAddAdmin(msg.sender, admin);
        return true;
    }
    
    function totalSupply() public constant returns (uint){
        return _totalSupply;
    }
    

}