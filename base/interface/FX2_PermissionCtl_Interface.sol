pragma solidity >=0.4.22 <0.6.0;

import "./FX2_Examination_Interface.sol";

contract FX2_PermissionCtl is FX2_Examination_Interface
{
  struct Table
  {
    address superOwner;
    address[] admins;
    address[] managers;
    address[] constractVisiters;
  }

  Table DBTable;
  
  function GetContractState()
  public
  view
  returns ( DBSContractState state )
  {
    return ContractState;
  }
  
  function ChangeContractStateToUpgrading()
  public
  NeedAdminPermission()
  {
    ContractState = DBSContractState.Upgrading;
  }
  
  /// @notice override super contract function
  function IsDoctorProgrammer(address addr) 
  internal 
  view 
  returns (bool ret)
  {
    if ( addr == DBTable.superOwner )
    {
        return true;
    }
    
    for ( uint a = 0; a < DBTable.admins.length; a++ )
    {
        if ( DBTable.admins[a] == addr )
        {
            return true;
        }
    }
    
    return false;
  }

  function GetAllVisterConstract()
  public
  view
  NeedAdminPermission
  returns ( address[] memory contracts )
  {
    return DBTable.constractVisiters;
  }

  function GetAllPermissionAddress()
  public
  view
  NeedAdminPermission
  returns (address superAdmin, address[] memory admins, address[] memory managers)
  {
    return (DBTable.superOwner, DBTable.admins, DBTable.managers);
  }

  constructor() public
  {
    DBTable.superOwner = msg.sender;
    DBTable.admins.push(msg.sender);
    DBTable.managers.push(msg.sender);
  }

  modifier ConstractInterfaceMethod()
  {
    if ( IsExistContractVisiter(msg.sender) || msg.sender == DBTable.superOwner )
    {
      _;
    }

    return ;
  }

  modifier NeedSuperPermission()
  {
    require(msg.sender == DBTable.superOwner);
    _;
    return;
  }

  modifier NeedAdminPermission()
  {
    if (msg.sender == DBTable.superOwner)
    {
      _;
      return;
    }

    bool exist = false;

    for (uint i = 0; i < DBTable.admins.length; i++ )
    {
      if (DBTable.admins[i] == msg.sender)
      {
        exist = true;
        break;
      }
    }

    require(exist);
    _;
    return;
  }

  modifier NeedManagerPermission()
  {
    if (msg.sender == DBTable.superOwner)
    {
      _;
      return;
    }

    bool exist = false;

    for (uint i = 0; i < DBTable.managers.length; i++ )
    {
      if (DBTable.managers[i] == msg.sender)
      {
        exist = true;

        break;
      }
    }

    // 如果存在管理员地址，则直接通过验证，否则继续查找是否属于更高权限的账号
    if (exist)
    {
      _;
      return;
    }

    for (uint j = 0; j < DBTable.admins.length; j++ )
    {
      if (DBTable.admins[j] == msg.sender)
      {
        exist = true;
        break;
      }
    }

    require(exist);
    _;
    return;
  }

  function GetSuperOwner()
  public
  view
  returns (address superOwnerAddress)
  {
    return DBTable.superOwner;
  }

  function AddManager(address manager)
  public
  NeedAdminPermission
  returns (bool success)
  {
    for (uint i = 0; i < DBTable.managers.length; i++ )
    {
      if (DBTable.managers[i] == manager)
      {
        return false;
      }
    }

    DBTable.managers.push(manager);
  }

  function AddAdmin(address admin)
  public
  NeedSuperPermission
  returns (bool success)
  {
    for (uint i = 0; i < DBTable.admins.length; i++ )
    {
      if (DBTable.admins[i] == admin)
      {
        return false;
      }
    }

    DBTable.admins.push(admin);
  }

  function RemoveManager(address manager)
  public
  NeedAdminPermission
  returns (bool success)
  {
    for (uint i = 0; i < DBTable.managers.length; i++ )
    {
      if (DBTable.managers[i] == manager)
      {
        for (uint j = i; j < DBTable.managers.length - 1; j++)
        {
          DBTable.managers[j] = DBTable.managers[j + 1];
        }

        delete DBTable.managers[DBTable.managers.length - 1];
        DBTable.managers.length --;

        return true;
      }
    }

    return false;
  }

  function RemoveAdmin(address admin)
  public
  NeedSuperPermission
  returns (bool success)
  {
    for (uint i = 0; i < DBTable.admins.length; i++ )
    {
      if (DBTable.admins[i] == admin)
      {
        for (uint j = i; j < DBTable.admins.length - 1; j++)
        {
          DBTable.admins[j] = DBTable.admins[j + 1];
        }

        delete DBTable.admins[DBTable.admins.length - 1];
        DBTable.admins.length --;

        return true;
      }
    }

    return false;
  }

  function IsExistContractVisiter( address visiter )
  public
  view
  returns (bool exist)
  {
    for (uint i = 0; i < DBTable.constractVisiters.length; i++ )
    {
      if (DBTable.constractVisiters[i] == visiter)
      {
        return true;
      }
    }

    return false;
  }

  function AddConstractVisiter( address visiter )
  public
  NeedAdminPermission
  returns (bool success)
  {
    for (uint i = 0; i < DBTable.constractVisiters.length; i++ )
    {
      if (DBTable.constractVisiters[i] == visiter)
      {
        return false;
      }
    }

    DBTable.constractVisiters.push(visiter);

    return true;
  }
}
