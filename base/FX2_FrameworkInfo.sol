pragma solidity >=0.4.22 <0.6.0;

/// @title  BalanceDBS
/// @author Martin.Ren


contract FX2_FrameworkInfo
{
  string    public FX2_VersionInfo      = "Powerby FX2 Aya 0.0.1 Release 2018-12-28";
  uint256   public FX2_DeployTime       = now;
  
  string    public FX2_ContractVer;
  string    public FX2_ModulesName;
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