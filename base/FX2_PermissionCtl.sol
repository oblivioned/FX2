pragma solidity >=0.4.22 <0.6.0;

import "./FX2_FrameworkInfo.sol";

contract FX2_PermissionCtl is FX2_FrameworkInfo
{
  struct Table
  {
    address superOwner;
    address[] admins;
  }

  Table PermissionUsers;

  modifier OnlyOnwer()
  {
    RequireSuper(msg.sender);
    _;
  }

  modifier OwerAndAdmin()
  {
    RequireSuper(msg.sender);
    RequireAdmin(msg.sender);
    _;
  }

  function IsSuperOrAdmin(address _sender) public view returns (bool exist)
  {
    if ( _sender == PermissionUsers.superOwner )
    {
      return true;
    }

    for (uint i = 0; i < PermissionUsers.admins.length; i++ )
    {
      if ( PermissionUsers.admins[i] == _sender )
      {
        return true;
      }
    }
  }



  function GetAllPermissionAddress()
  public
  view
  OwerAndAdmin
  returns ( address superAdmin, address[] memory admins )
  {
    return ( PermissionUsers.superOwner, PermissionUsers.admins );
  }

  constructor() public
  {
    PermissionUsers.superOwner = msg.sender;
  }

  function RequireSuper(address _sender) public view
  {
    require(_sender == PermissionUsers.superOwner);
  }

  function RequireAdmin(address _sender) public view
  {
    if ( _sender == PermissionUsers.superOwner )
    {
      return;
    }

    bool exist = false;

    for (uint i = 0; i < PermissionUsers.admins.length; i++ )
    {
      if ( PermissionUsers.admins[i] == _sender )
      {
        exist = true;
        break;
      }
    }

    require(exist);
  }

  function AddAdmin(address admin)
  public
  OnlyOnwer
  returns (bool success)
  {
    for (uint i = 0; i < PermissionUsers.admins.length; i++ )
    {
      if (PermissionUsers.admins[i] == admin)
      {
        return false;
      }
    }

    PermissionUsers.admins.push(admin);
  }

  function RemoveAdmin(address admin)
  public
  OnlyOnwer
  returns (bool success)
  {
    for (uint i = 0; i < PermissionUsers.admins.length; i++ )
    {
      if (PermissionUsers.admins[i] == admin)
      {
        for (uint j = i; j < PermissionUsers.admins.length - 1; j++)
        {
          PermissionUsers.admins[j] = PermissionUsers.admins[j + 1];
        }

        delete PermissionUsers.admins[ PermissionUsers.admins.length - 1 ];
        PermissionUsers.admins.length --;

        return true;
      }
    }

    return false;
  }

  string public FX2_VersionInfo = "{'Symbol':'Aya','Ver':'0.0.1 Release 2018-12-28','Modules':'FX2_PermissionCtl'}";
}
