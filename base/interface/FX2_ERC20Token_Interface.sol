pragma solidity >=0.4.22 <0.6.0;

contract FX2_ERC20TokenInterface
{
    function totalSupply() public view returns ( uint256 );
    function name() public view returns ( string memory );
    function decimals() public view returns ( uint8 );
    function symbol() public view returns ( string memory );
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /* I don't want implementation any method to support allowance modules. by martin*/
    /* function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value); */
}
