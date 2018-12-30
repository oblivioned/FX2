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

  /// @notice 合约部署时间
  uint256   public FX2_DeployTime       = now;

  /// @notice 插件版本,可重写，否则使用FX2框架版本作为插件版本号
  string    public FX2_ContractVer      = "0.0.1";

  /// @notice 插件模块名称
  string    public FX2_ModulesName;

  /// @notice 插件模块中子组成构建合约的标识符
  string    public FX2_ExtensionID;

  struct InfoData
  {
    string  FX2_VersionInfo;
    uint256 FX2_DeployTime;
    string  FX2_ContractVer;
    string  FX2_ModulesName;
    string  FX2_ExtensionID;
    address FX2_ContractAddr;
  }

  /// @notice 读取指定地址的合约，检测是否支持FX2，若支持继续读取基本信息
  /// @param  target : 读取目标合约地址
  /// @return supportFX2 : 是否支持FX2
  /// @return data : 其他信息
  function ReadInfoAt(address target) internal view returns ( bool supportFX2, InfoData memory data )
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
            data = InfoData("",0,"","","",target);
        }
    }

    supportFX2 = true;
    data.FX2_DeployTime  = FX2_FrameworkInfo(target).FX2_DeployTime();
    data.FX2_ContractVer = FX2_FrameworkInfo(target).FX2_ContractVer();
    data.FX2_ModulesName = FX2_FrameworkInfo(target).FX2_ModulesName();
    data.FX2_ExtensionID = FX2_FrameworkInfo(target).FX2_ExtensionID();
  }
}
