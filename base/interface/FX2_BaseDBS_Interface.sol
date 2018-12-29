pragma solidity >=0.4.22 <0.6.0;

import "./FX2_PermissionCtl_Interface.sol";
import "../FX2_FrameworkInfo.sol";

/// @title  ExtensionModules-Pos-DBS
/// @author Martin.Ren

contract FX2_BaseDBS_Interface is 
FX2_PermissionCtl_Interface,
FX2_FrameworkInfo
{
  function SetUintValue(string memory key, uint value)
  public;

  function ExistUintKey(string memory key)
  public
  view
  returns (bool isExist);

  function GetUintValue(string memory key)
  public
  view
  returns (uint value);


  ////////////////// Int /////////////////////
  function SetIntValue(string memory key, int value)
  public;

  function ExistIntKey(string memory key)
  public
  view
  returns (bool isExist);

  function GetIntValue(string memory key)
  public
  view
  returns (int value);


  ////////////////// address /////////////////////
  function SetAddress(string memory key, address value)
  public;

  function ExistAddressKey(string memory key)
  public
  view
  returns (bool isExist);

  function GetAddress(string memory key)
  public
  view
  returns (address value);

  ////////////////// address ////////////////////
  function SetBoolValue(string memory key, bool value)
  public;

  function GetBoolValue(string memory key)
  public
  view
  returns (bool value);
}
