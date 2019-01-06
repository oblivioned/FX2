pragma solidity >=0.5.0 <0.6.0;

interface FX2_ERC20Token_Events
{
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}
