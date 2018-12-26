pragma solidity >=0.4.22 <0.6.0;

contract ERC20TokenInterface
{
    uint256 public totalSupply;
    string  public name;
    uint8   public decimals;
    string  public symbol;

    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    mapping (address => uint256) internal fx2_mapping_balances;
    mapping (address => mapping (address => uint256)) internal fx2_mapping_allowance;
}
