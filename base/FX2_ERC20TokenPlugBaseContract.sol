pragma solidity >=0.4.22 <0.6.0;

import "./interface/FX2_ERC20Token_Interface.sol";
import "./interface/FX2_ERC20TokenDBS_Interface.sol";

contract FX2_ERC20TokenPlugBaseContract is FX2_ERC20Token_Interface
{
  FX2_ERC20TokenDBS_Interface DBS_ERC20Token;

  constructor( FX2_ERC20TokenDBS_Interface tokenDBSAddr ) public payable
  {
    DBS_ERC20Token = FX2_ERC20TokenDBS_Interface(tokenDBSAddr);
  }

  function totalSupply() public view returns ( uint256 )
  {
    return DBS_ERC20Token.totalSupply();
  }

  function name() public view returns ( string memory )
  {
    return DBS_ERC20Token.name();
  }

  function decimals() public view returns ( uint8 )
  {
    return uint8(DBS_ERC20Token.decimals());
  }

  function symbol() public view returns ( string memory )
  {
    return DBS_ERC20Token.symbol();
  }

  function balanceOf(address _owner) public view returns (uint256 balance)
  {
    return DBS_ERC20Token.BalanceOf(_owner);
  }

  function transfer(address _to, uint256 _value) public returns (bool success)
  {
    DBS_ERC20Token.TransferBalance(msg.sender, _to, _value);

    return true;
  }

}
