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

import "../interface/FX2_AbstractDBS_Interface.sol";

/// @title  FX2提供的基础DBS合约，提供基础的数据读写和一个支持 uint，bool，address的KV（key-value）的小型数据库
///         所有关于数据控制村粗的在使用时需要继承此合约。
/// @author Martin.Ren
contract FX2_AbstractDBS is
FX2_FrameworkInfo,
FX2_AbstractDBS_Interface,
FX2_PermissionCtl_Modifier,
FX2_ModulesManager_Modifier
{
  /* constructor( FX2_PermissionCtl_Interface fx2_pcimpl, FX2_ModulesManager_Interface fx2_mmimpl ) public
  {
    FX2_PermissionCtl_Modifier_LinkIMPL( fx2_pcimpl );
    FX2_ModulesManager_Modifier_LinkIMPL( fx2_mmimpl );
  } */

  /// @notice 设置一个Uint值
  /// @param  key 键名
  /// @param  value 键值

  function SetUintValue(string memory key, uint value)
  public
  ValidModuleAPI
  {
    _uintHashMap[key] = value;
  }


  /// @notice 检测键名是否存在
  /// @param  key 键名
  /// @return true 存在，false：不存在
  function ExistUintKey(string memory key)
  public
  view
  returns (bool isExist)
  {
    isExist = (_uintHashMap[key] == 0);
  }


  /// @notice 获取键名对应的值
  /// @param  key 键名
  /// @return 键名存在则返回实值，若不存在则返回0（在返回0时候，无法确认键值是否存在）
  function GetUintValue(string memory key)
  public
  view
  returns (uint value)
  {
    value = _uintHashMap[key];
  }

  /// @notice 设置一个Uint值
  /// @param  key 键名
  /// @param  value 键值
  function SetIntValue(string memory key, int value)
  public
  ValidModuleAPI
  {
    _uintHashMap[key] = uint256(value);
  }


  /// @notice 检测键名是否存在
  /// @param  key 键名
  /// @return true 存在，false：不存在
  function ExistIntKey(string memory key)
  public
  view
  returns (bool isExist)
  {
    isExist = (_uintHashMap[key] == 0);
  }

  /// @notice 获取键名对应的值
  /// @param  key 键名
  /// @return 键名存在则返回实值，若不存在则返回0（在返回0时候，无法确认键值是否存在）
  function GetIntValue(string memory key)
  public
  view
  returns (int value)
  {
    value = int(_uintHashMap[key]);
  }


  /// @notice 设置一个Uint值
  /// @param  key 键名
  /// @param  value 键值
  function SetAddress(string memory key, address value)
  public
  ValidModuleAPI
  {
    _uintHashMap[key] = uint256(value);
  }

  /// @notice 检测键名是否存在
  /// @param  key 键名
  /// @return true 存在，false：不存在
  function ExistAddressKey(string memory key)
  public
  view
  returns (bool isExist)
  {
    isExist = (_uintHashMap[key] == 0);
  }

  /// @notice 获取键名对应的值
  /// @param  key 键名
  /// @return 键名存在则返回实值，若不存在则返回0（在返回0时候，无法确认键值是否存在）
  function GetAddress(string memory key)
  public
  view
  returns (address value)
  {
    value = address(_uintHashMap[key]);
  }


  /// @notice 设置一个Uint值
  /// @param  key 键名
  /// @param  value 键值
  function SetBoolValue(string memory key, bool value)
  public
  ValidModuleAPI
  {
    _uintHashMap[key] = value ? 1 : 0;
  }


  /// @notice 获取键名对应的值
  /// @param  key 键名
  /// @return 键名存在则返回实值，若不存在则返回0（在返回0时候，无法确认键值是否存在）
  function GetBoolValue(string memory key)
  public
  view
  returns (bool value)
  {
    value = _uintHashMap[key] > 0 ? true : false;
  }


  /*——————————————————————————————————————————————————————————————*/
  /*                         Stroage 变量定义                      */
  /*——————————————————————————————————————————————————————————————*/
  mapping (string => uint) _uintHashMap;


  /*——————————————————————————————————————————————————————————————*/
  /*                          FX2 模块信息                         */
  /*——————————————————————————————————————————————————————————————*/
  string public FX2_ModulesName = "FX2.BaseDBS";
}
