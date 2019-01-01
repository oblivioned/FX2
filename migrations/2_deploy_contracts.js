var FX2_PermissionCtl = artifacts.require('./base/FX2_PermissionCtl.sol')
var FX2_FrameworkInfo = artifacts.require('./base/FX2_FrameworkInfo.sol')
var FX2_ModulesManager = artifacts.require('./base/FX2_ModulesManager.sol')

module.exports = function (deployer)
{
  deployer.deploy(FX2_PermissionCtl)
  deployer.deploy(FX2_FrameworkInfo)
  deployer.deploy(FX2_ModulesManager)
}
