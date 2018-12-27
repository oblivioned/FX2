pragma solidity >=0.4.22 <0.6.0;

contract FX2_PermissionCtl
{
  struct Table
  {
    address superOwner;
    address[] admins;
    address[] managers;
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
        exist = true;
        return;
      }
    }
  }

  

  function GetAllPermissionAddress()
  public
  view
  OwerAndAdmin
  returns (address superAdmin, address[] memory admins, address[] memory managers)
  {
    return (PermissionUsers.superOwner, PermissionUsers.admins, PermissionUsers.managers);
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

  function RequireManager(address _sender) public view
  {
    if (_sender == PermissionUsers.superOwner)
    {
      return;
    }

    bool exist = false;

    for (uint i = 0; i < PermissionUsers.managers.length; i++ )
    {
      if (PermissionUsers.managers[i] == _sender)
      {
        exist = true;

        break;
      }
    }

    // 如果存在管理员地址，则直接通过验证，否则继续查找是否属于更高权限的账号
    if (exist)
    {
      return;
    }

    for (uint j = 0; j < PermissionUsers.admins.length; j++ )
    {
      if (PermissionUsers.admins[j] == _sender)
      {
        exist = true;
        break;
      }
    }

    require(exist);
    return;
  }

  function AddManager(address manager)
  public
  OwerAndAdmin
  returns (bool success)
  {
    for (uint i = 0; i < PermissionUsers.managers.length; i++ )
    {
      if (PermissionUsers.managers[i] == manager)
      {
        return false;
      }
    }

    PermissionUsers.managers.push(manager);
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

  function RemoveManager(address manager)
  public
  OwerAndAdmin
  returns (bool success)
  {
    for (uint i = 0; i < PermissionUsers.managers.length; i++ )
    {
      if (PermissionUsers.managers[i] == manager)
      {
        for (uint j = i; j < PermissionUsers.managers.length - 1; j++)
        {
          PermissionUsers.managers[j] = PermissionUsers.managers[j + 1];
        }

        delete PermissionUsers.managers[PermissionUsers.managers.length - 1];
        PermissionUsers.managers.length --;

        return true;
      }
    }

    return false;
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

        delete PermissionUsers.admins[PermissionUsers.admins.length - 1];
        PermissionUsers.admins.length --;

        return true;
      }
    }

    return false;
  }

  
}
