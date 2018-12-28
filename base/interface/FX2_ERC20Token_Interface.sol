pragma solidity >=0.4.22 <0.6.0;

interface FX2_ERC20Token_Interface
{
    function totalSupply() external view returns ( uint256 );
    function name() external view returns ( string memory );
    function decimals() external view returns ( uint8 );
    function symbol() external view returns ( string memory );
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /* I don't want implementation any method to support allowance modules. by martin*/
    /* function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value); */
}
