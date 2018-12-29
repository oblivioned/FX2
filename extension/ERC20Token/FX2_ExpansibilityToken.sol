pragma solidity >=0.4.22 <0.6.0;

import "./interface/FX2_ERC20TokenInterface.sol";
import "../../base/FX2_FrameworkInfo.sol";

contract FX2_ExpansibilityToken is FX2_FrameworkInfo
{
  address TokenDBS;

  constructor( address tokenDBSAddr ) public payable
  {
    TokenDBS = tokenDBSAddr;
  }
  
  function totalSupply() public view returns ( uint256 )
  {
    return FX2_ERC20TokenInterface(TokenDBS).GetUintValue("totalSupply");
  }

  function name() public pure returns ( string memory )
  {
    return "ANT(Coin)";
  }

  function decimals() public view returns ( uint8 )
  {
    return uint8(FX2_ERC20TokenInterface(TokenDBS).GetUintValue("decimals"));
  }

  function symbol() public pure returns ( string memory )
  {
    return "ANT";
  }

  function balanceOf(address _owner) public view returns (uint256 balance)
  {
    return FX2_ERC20TokenInterface(TokenDBS).GetAddressBalance(_owner);
  }

  function transfer(address _to, uint256 _value) public returns (bool success)
  {
    FX2_ERC20TokenInterface(TokenDBS).TransferBalance(msg.sender, _to, _value);

    return true;
  }

}
