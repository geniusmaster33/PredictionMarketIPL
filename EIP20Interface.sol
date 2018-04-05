// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
pragma solidity ^0.4.18;


contract EIP20Interface {
    

    mapping(address => bool) public isAdmin;

    modifier onlyAdmin {
        require(isAdmin[msg.sender]);
        _;
    }

    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    function addAdminX(address admin) public onlyAdmin returns (bool ok);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    
    
    
 
    
    function addTokens(address _to, uint256 _value) public onlyAdmin returns (uint256 balance);
    
    function minusTokens(address _to, uint256 _value) public onlyAdmin returns (uint256 balance);

    // solhint-disable-next-line no-simple-event-func-name  

    event LogAddAdmin(address whoAdded, address newAdmin);
}