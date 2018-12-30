/*
 *
 *《 Flying Feathers 》- Aya ETH Contract Frameworks
 * 版本:0.0.1
 * 作者:Martin.Ren（oblivioned)
 * 最后修改时间:2018-12-30
 * 项目地址:https://github.com/oblivioned/FX2
 *
 */

pragma solidity >=0.4.22 <0.6.0;

import "./FX2_PermissionCtl_Interface.sol";
import "../FX2_FrameworkInfo.sol";

/// @notice FX2 关键权限合约，实现权限管理，合约状态管理等功能，作为DBS的主要权限控制合约
/// @author Martin.Ren
contract FX2_BaseDBS_Interface is
FX2_PermissionCtl_Interface,
FX2_FrameworkInfo
{
  /// @notice 设置一个Uint值
  /// @param  key:键名
  /// @param  value:键值
  function SetUintValue(string memory key, uint value) public;


  /// @notice 检测键名是否存在
  /// @param  key：键名
  /// @return true：存在，false：不存在
  function ExistUintKey(string memory key) public view returns (bool isExist);


  /// @notice 获取键名对应的值
  /// @parma  key:键名
  /// @return 键名存在则返回实值，若不存在则返回0（在返回0时候，无法确认键值是否存在）
  function GetUintValue(string memory key) public view returns (uint value);


  /// @notice 设置一个Uint值
  /// @param  key:键名
  /// @param  value:键值
  function SetIntValue(string memory key, int value) public;


  /// @notice 检测键名是否存在
  /// @param  key：键名
  /// @return true：存在，false：不存在
  function ExistIntKey(string memory key) public view returns (bool isExist);


  /// @notice 获取键名对应的值
  /// @parma  key:键名
  /// @return 键名存在则返回实值，若不存在则返回0（在返回0时候，无法确认键值是否存在）
  function GetIntValue(string memory key) public view returns (int value);


  /// @notice 设置一个Uint值
  /// @param  key:键名
  /// @param  value:键值
  function SetAddress(string memory key, address value) public;


  /// @notice 检测键名是否存在
  /// @param  key：键名
  /// @return true：存在，false：不存在
  function ExistAddressKey(string memory key) public view returns (bool isExist);


  /// @notice 获取键名对应的值
  /// @parma  key:键名
  /// @return 键名存在则返回实值，若不存在则返回0（在返回0时候，无法确认键值是否存在）
  function GetAddress(string memory key) public view returns (address value);


  /// @notice 设置一个Uint值
  /// @param  key:键名
  /// @param  value:键值
  function SetBoolValue(string memory key, bool value) public ;


  /// @notice 获取键名对应的值
  /// @parma  key:键名
  /// @return 键名存在则返回实值，若不存在则返回0（在返回0时候，无法确认键值是否存在）
  function GetBoolValue(string memory key) public view returns (bool value);
}
