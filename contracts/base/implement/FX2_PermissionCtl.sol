/*
 *
 *《 Flying Feathers 》- Aya ETH Contract Frameworks
 * 版本:0.0.1
 * 作者:Martin.Ren（oblivioned)
 * 最后修改时间:2018-12-30
 * 项目地址:https://github.com/oblivioned/FX2
 *
 */

pragma solidity >=0.5.0 <0.6.0;

import "../FX2_FrameworkInfo.sol";

/// @notice 权限控制合约，即可以操作插座模块和插件模块的权限控制地址管理。
/// @author Martin.Ren
contract FX2_PermissionCtl is
FX2_FrameworkInfo
{
  constructor() public
  {
    PermissionUsers.superOwner = msg.sender;
  }

  /// @notice 检测对应的地址是否具备super或者admin权限
  /// @param  _sender : 检测的目标地址
  /// @return 检测结果
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
    
    return false;
  }

  /// @notice 获取所有已经配置的具备权限的用户和权限类型
  /// @return superAdmin : 超级权限，合约部署者，最高权限
  ///         admins     : 其他管理员，具备大部分权限
  function GetAllPermissionAddress()
  public
  view
  returns ( address superAdmin, address[] memory admins )
  {
    return ( PermissionUsers.superOwner, PermissionUsers.admins );
  }

  /// @notice 函数形式校验超级权限，如果校验不通过会使用require断言中断执行。
  function RequireSuper(address _sender) public view
  {
    require(_sender == PermissionUsers.superOwner);
  }

  /// @notice 函数形式校验管理权限，如果校验不通过会使用require断言中断执行。
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
        return;
      }
    }

    require(exist);
  }

  /// @notice 添加管理权限账户，实现逻辑中限定了只能由超级权限添加
  /// @return 添加的结果
  function AddAdmin(address admin)
  public
  returns (bool success)
  {
    require ( msg.sender == PermissionUsers.superOwner );
    
    for (uint i = 0; i < PermissionUsers.admins.length; i++ )
    {
      if (PermissionUsers.admins[i] == admin)
      {
        return false;
      }
    }

    PermissionUsers.admins.push(admin);
  }

  /// @notice 移除管理权限账户，实现逻辑中限定了只能由超级权限添加
  /// @return 添加的结果
  function RemoveAdmin(address admin)
  public
  returns (bool success)
  {
    require ( msg.sender == PermissionUsers.superOwner );

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


  /*——————————————————————————————————————————————————————————————*/
  /*                         Stroage 变量定义                      */
  /*——————————————————————————————————————————————————————————————*/
  struct Table
  {
    address superOwner;
    address[] admins;
  }

  Table PermissionUsers;

  /*——————————————————————————————————————————————————————————————*/
  /*                          FX2 模块信息                         */
  /*——————————————————————————————————————————————————————————————*/
  string public FX2_ModulesName = "FX2.PermissionCtl";
}
