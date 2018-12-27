pragma solidity >=0.4.22 <0.6.0;

import "./FX2_PermissionCtl.sol";

/// @title  ExtensionModules-Pos-DBS
/// @author Martin.Ren
contract FX2_BaseDBS is FX2_PermissionCtl
{
  function SetUintValue(string memory key, uint value)
  public
  ConstractInterfaceMethod
  {
    _uintHashMap[key] = value;
  }

  function ExistUintKey(string memory key)
  public
  view
  returns (bool isExist)
  {
    isExist = (_uintHashMap[key] == 0);
  }

  function GetUintValue(string memory key)
  public
  view
  returns (uint value)
  {
    value = _uintHashMap[key];
  }


  ////////////////// Int /////////////////////
  function SetIntValue(string memory key, int value)
  public
  ConstractInterfaceMethod
  {
    _intHashMap[key] = value;
  }

  function ExistIntKey(string memory key)
  public
  view
  returns (bool isExist)
  {
    isExist = (_intHashMap[key] == 0);
  }

  function GetIntValue(string memory key)
  public
  view
  returns (int value)
  {
    value = _intHashMap[key];
  }


  ////////////////// address /////////////////////
  function SetAddress(string memory key, address value)
  public
  ConstractInterfaceMethod
  {
    _addressHashMap[key] = value;
  }

  function ExistAddressKey(string memory key)
  public
  view
  returns (bool isExist)
  {
    isExist = (_addressHashMap[key] == address(0x0));
  }

  function GetAddress(string memory key)
  public
  view
  returns (address value)
  {
    value = _addressHashMap[key];
  }

  ////////////////// address ////////////////////
  function SetBoolValue(string memory key, bool value)
  public
  ConstractInterfaceMethod
  {
    _boolHashMap[key] = value;
  }

  function GetBoolValue(string memory key)
  public
  view
  returns (bool value)
  {
    value = _boolHashMap[key];
  }

  mapping (string => uint) _uintHashMap;
  mapping (string => int)  _intHashMap;
  mapping (string => address) _addressHashMap;
  mapping (string => bool) _boolHashMap;

}
