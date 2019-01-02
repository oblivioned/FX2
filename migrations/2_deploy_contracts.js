var FX2_PermissionCtl     = artifacts.require('./base/implement/FX2_PermissionCtl.sol')
var FX2_ModulesManager    = artifacts.require('./base/implement/FX2_ModulesManager.sol')
var FX2_ERC20Token_DBS    = artifacts.require('./extension/ERC20Token/FX2_ERC20Token_DBS.sol')
var FX2_ERC20Token_IMPL   = artifacts.require('./extension/ERC20Token/FX2_ERC20Token_IMPL.sol')

module.exports = function (deployer)
{
  var PermissionCTL;
  var ModuleManager;
  var TokenDBSInstance;
  var TokenIMPLInstance;


  deployer.deploy(FX2_PermissionCtl)
  .then(function( instance ){
    PermissionCTL = instance;
    return deployer.deploy(FX2_ModulesManager, FX2_PermissionCtl.address)
  })
  .then(function( instance ) {
    ModuleManager = instance;
    return deployer.deploy(FX2_ERC20Token_DBS, FX2_PermissionCtl.address, FX2_ModulesManager.address)
  })
  .then(function( instance ) {
    TokenDBSInstance = instance;
    return deployer.deploy(FX2_ERC20Token_IMPL, FX2_ERC20Token_DBS.address)
  })
  .then(function( instance ) {
    TokenIMPLInstance = instance;
    return ModuleManager.AddExternsionModule( TokenIMPLInstance.address );
  })
  .then(function(){
    return TokenIMPLInstance.balanceOf.call( TokenDBSInstance.address.toString() );
  })
  .then(function(balance){
    console.log( balance.toString() );
    return ModuleManager.AllExtensionModuleHashNames.call();
  }).then(function(result){
    console.log(result)
  })

}
