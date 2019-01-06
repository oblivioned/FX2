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

import "../interface/FX2_ModulesManager_Interface.sol";
import "../interface/FX2_PermissionCtl_Interface.sol";

import "../modifier/FX2_ModulesManager_Modifier.sol";
import "../modifier/FX2_PermissionCtl_Modifier.sol";

/// @title  FX2提供的基础DBS合约，提供基础的数据读写和一个支持 uint，bool，address的KV（key-value）的小型数据库
///         所有关于数据控制村粗的在使用时需要继承此合约。
/// @author Martin.Ren
contract FX2_AbstractDBS_Interface
{
    /// @notice 设置一个Uint值
    /// @param  key   : 键名
    /// @param  value : 键值
    function SetUintValue(string memory key, uint value) public;


    /// @notice 检测键名是否存在
    /// @param  key   ：键名
    /// @return true  ：存在，false：不存在
    function ExistUintKey(string memory key) public view returns (bool isExist);


    /// @notice 获取键名对应的值
    /// @param  key   :键名
    /// @return 键名存在则返回实值，若不存在则返回0（在返回0时候，无法确认键值是否存在）
    function GetUintValue(string memory key) public view returns (uint value);


    /// @notice 设置一个Uint值
    /// @param  key   :键名
    /// @param  value :键值
    function SetIntValue(string memory key, int value) public;


    /// @notice 检测键名是否存在
    /// @param  key   :键名
    /// @return true  :存在，false：不存在
    function ExistIntKey(string memory key) public view returns (bool isExist);


    /// @notice 获取键名对应的值
    /// @param  key   :键名
    /// @return 键名存在则返回实值，若不存在则返回0（在返回0时候，无法确认键值是否存在）
    function GetIntValue(string memory key) public view returns (int value);


    /// @notice 设置一个Uint值
    /// @param  key   :键名
    /// @param  value :键值
    function SetAddress(string memory key, address value) public;


    /// @notice 检测键名是否存在
    /// @param  key   :键名
    /// @return true  :存在，false：不存在
    function ExistAddressKey(string memory key) public view returns (bool isExist);


    /// @notice 获取键名对应的值
    /// @param  key   :键名
    /// @return 键名存在则返回实值，若不存在则返回0（在返回0时候，无法确认键值是否存在）
    function GetAddress(string memory key) public view returns (address value);


    /// @notice 设置一个Uint值
    /// @param  key   :键名
    /// @param  value :键值
    function SetBoolValue(string memory key, bool value) public ;


    /// @notice 获取键名对应的值
    /// @param  key   :键名
    /// @return 键名存在则返回实值，若不存在则返回0（在返回0时候，无法确认键值是否存在）
    function GetBoolValue(string memory key) public view returns (bool value);
}
