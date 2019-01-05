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

/// @notice 合约扩展支持的Interface定义
/// @author Martin.Ren
interface FX2_Modules_Migrate_Delegate
{
  function DoMigrateWorking( address originModules, address newImplAddress ) external returns (bool success);
}
