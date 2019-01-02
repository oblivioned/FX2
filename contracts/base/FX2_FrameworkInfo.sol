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

/// @title  FX2 任意模块的信息基础合约，用于标示插件的基本信息和版本信息
/// @author Martin.Ren
contract FX2_FrameworkInfo
{
  /// @notice 版本信息
  string    public FX2_VersionInfo      = "Powerby FX2 Aya 0.0.1 Release 2018-12-28";

  /// @notice 插件模块名称
  string    public FX2_ModulesName;

  struct ModuleInfoData
  {
    string  FX2_VersionInfo;
    string  FX2_ModulesName;
    address FX2_ContractAddr;
    bytes32 FX2_HashName;
  }

  /// @notice 读取指定地址的合约，检测是否支持FX2，若支持继续读取基本信息
  /// @param  target : 读取目标合约地址
  /// @return supportFX2 : 是否支持FX2
  /// @return data : 其他信息
  function ReadInfoAt(address target) internal view returns ( bool supportFX2, ModuleInfoData memory data )
  {
    data.FX2_ContractAddr = target;
    data.FX2_VersionInfo = FX2_FrameworkInfo(target).FX2_VersionInfo();

    bytes memory s = bytes(FX2_VersionInfo);
    bytes memory t = bytes(data.FX2_VersionInfo);

    for ( uint i = 0; i < 11; i++ )
    {
        if ( s[i] == t[i] )
        {
            continue;
        }
        else
        {
            supportFX2 = false;
            data = ModuleInfoData("", "", target, "");
        }
    }

    supportFX2 = true;
    data.FX2_ModulesName = FX2_FrameworkInfo(target).FX2_ModulesName();
    data.FX2_HashName    = keccak256(bytes(data.FX2_ModulesName));
  }
}
