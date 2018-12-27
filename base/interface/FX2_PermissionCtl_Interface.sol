pragma solidity >=0.4.22 <0.6.0;

import "./FX2_Examination_Interface.sol";

contract FX2_PermissionCtl_Interface is FX2_Examination_Interface
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
  returns ( DBSContractState state );
  
  function ChangeContractStateToUpgrading()
  public
  NeedAdminPermission();
  
  /// @notice override super contract function
  function IsDoctorProgrammer(address addr) 
  internal 
  view 
  returns (bool ret);

  function GetAllVisterConstract()
  public
  view
  NeedAdminPermission
  returns ( address[] memory contracts );

  function GetAllPermissionAddress()
  public
  view
  NeedAdminPermission
  returns (address superAdmin, address[] memory admins, address[] memory managers);
  
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
  returns (address superOwnerAddress);

  function AddManager(address manager)
  public
  NeedAdminPermission
  returns (bool success);

  function AddAdmin(address admin)
  public
  NeedSuperPermission
  returns (bool success);

  function RemoveManager(address manager)
  public
  NeedAdminPermission
  returns (bool success);
  
  
  function RemoveAdmin(address admin)
  public
  NeedSuperPermission
  returns (bool success);

  function IsExistContractVisiter( address visiter )
  public
  view
  returns (bool exist);

  function AddConstractVisiter( address visiter )
  public
  NeedAdminPermission
  returns (bool success);
  
}
