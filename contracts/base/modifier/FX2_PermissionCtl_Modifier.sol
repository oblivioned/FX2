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

import "../interface/FX2_PermissionCtl_Interface.sol";

contract FX2_PermissionCtl_Modifier
{
  FX2_PermissionCtl_Interface internal FX2_PCImpl;

  function FX2_PermissionCtl_Modifier_LinkIMPL( FX2_PermissionCtl_Interface fx2_pcimpl )
  internal
  {
      FX2_PCImpl = fx2_pcimpl;
  }

  modifier NeedSuperPermission()
  {
      FX2_PCImpl.RequireSuper(msg.sender);
      _;
  }

  /// @notice 调用外部权限CTL检测管理员权限，主要用于限制当前合约的一些关键API的调用权限。
  modifier NeedAdminPermission()
  {
      FX2_PCImpl.RequireAdmin(msg.sender);
      _;
  }
}
