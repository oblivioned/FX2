pragma solidity >=0.5.0 <0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/base/FX2_FrameworkInfo.sol";

contract TestFX2_FrameworkInfo is FX2_FrameworkInfo
{
  FX2_FrameworkInfo INFO;

  function test_Inited() public
  {
    INFO = new FX2_FrameworkInfo();
  }

  function test_ReadThisInfo() public
  {
    (bool supportFX2, FX2_FrameworkInfo.InfoData memory data) = ReadInfoAt(address(this));

    Assert.equal( supportFX2, true, "supportFX2 返回错误");
    Assert.equal( keccak256(bytes(data.FX2_VersionInfo)), keccak256(bytes(FX2_VersionInfo)), "FX2_VersionInfo 返回错误");
    Assert.equal( keccak256(bytes(data.FX2_ContractVer)), keccak256(bytes(FX2_ContractVer)), "FX2_ContractVer 返回错误");
    Assert.equal( keccak256(bytes(data.FX2_ModulesName)), keccak256(bytes(FX2_ModulesName)), "FX2_ModulesName 返回错误");
    Assert.equal( keccak256(bytes(data.FX2_ExtensionID)), keccak256(bytes(FX2_ExtensionID)), "FX2_ExtensionID 返回错误");

    Assert.equal( data.FX2_DeployTime, FX2_DeployTime, "FX2_DeployTime 返回错误");
    Assert.equal( data.FX2_ContractAddr, address(this), "FX2_ContractAddr 返回错误");
  }

  function test_ReadOtherInfo() public
  {
    (bool supportFX2, FX2_FrameworkInfo.InfoData memory data) = ReadInfoAt( address(INFO) );

    Assert.equal( supportFX2, true, "supportFX2 返回错误");
    Assert.equal( keccak256(bytes(data.FX2_VersionInfo)), keccak256(bytes(FX2_VersionInfo)), "FX2_VersionInfo 返回错误");
    Assert.equal( keccak256(bytes(data.FX2_ContractVer)), keccak256(bytes(FX2_ContractVer)), "FX2_ContractVer 返回错误");
    Assert.equal( keccak256(bytes(data.FX2_ModulesName)), keccak256(bytes(FX2_ModulesName)), "FX2_ModulesName 返回错误");
    Assert.equal( keccak256(bytes(data.FX2_ExtensionID)), keccak256(bytes(FX2_ExtensionID)), "FX2_ExtensionID 返回错误");

    Assert.equal( data.FX2_DeployTime, FX2_DeployTime, "FX2_DeployTime 返回错误");
    Assert.equal( data.FX2_ContractAddr, address(INFO), "FX2_ContractAddr 返回错误");
  }

}
