pragma solidity >=0.4.22 <0.6.0;

import "./FX2_PermissionCtl.sol";

library FX2_Config
{
  enum SupportConfigType
  {
    SupportConfigType_Uint,
    SupportConfigType_Int,
    SupportConfigType_Bool,
    SupportConfigType_Address
  }

  struct Config {
    string            configKey;
    bytes             configValue;
    SupportConfigType configType;
  }

  struct DB {
    Config[] _dbs;
  }

  function StringHashIsEqul(string a, string b)
  internal
  pure
  returns (bool isEqul)
  {
    bytes memory bytesWithA = bytes(a);
    bytes memory bytesWithB = bytes(b);

    if ( bytesWithA.length != bytesWithB.length )
    {
      return false;
    }

    return keccak256(bytesWithA) == keccak256(bytesWithB);
  }

  function GetConfigList( DB storage _db)
  internal
  view
  returns (Config[] stroage lists)
  {
    lists = _db._dbs;
  }

  function GetConfig( DB storage _db, string _configKey)
  internal
  view
  returns (Config memory config)
  {

    for (uint i = 0; i < _db._dbs.length; i++)
    {
      Config storage subConfig = _db._dbs[i];

      if ( StringHashIsEqul(subConfig.configKey, _configKey) )
      {
        config = subConfig;
        return ;
      }
    }

    require(false, "FX2_FX2_Config:config key is not exist.");
  }

  function SetConfig( DB storage _db, Config memory _config )
  internal
  returns (bool replaced)
  {
    int isKeyExistAtIndex = -1;

    for ( uint i = 0; i < _db._dbs.length; i++ )
    {
      if ( !StringHashIsEqul( _db._dbs[i].configKey, _config.configKey ) )
      {
          continue;
      }
      else
      {
        isKeyExistAtIndex = int(i);
        break;
      }
    }

    if ( isKeyExistAtIndex != -1 )
    {
      _db._dbs.push(_config);

      replaced = false;
    }
    else
    {
      _db._dbs[uint(isKeyExistAtIndex)] = _config;
      replaced = true;
    }
  }
}


contract FX2_BaseConfig
{
  using FX2_Config for FX2_Config.DB;
  FX2_Config.DB ConfigDBS;



}
