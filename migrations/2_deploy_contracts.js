var FX2_PermissionCtl     = artifacts.require('./base/implement/FX2_PermissionCtl.sol')
var FX2_ModulesManager    = artifacts.require('./base/implement/FX2_ModulesManager.sol')
var FX2_ERC20Token_DBS    = artifacts.require('./extension/ERC20Token/FX2_ERC20Token_DBS.sol')
var FX2_ERC20Token_IMPL   = artifacts.require('./extension/ERC20Token/FX2_ERC20Token_IMPL.sol')
var FX2_POS_DBS           = artifacts.require('./extension/Pos/FX2_Externsion_POS_DBS.sol')
var FX2_POS_IMPL          = artifacts.require('./extension/Pos/FX2_Externsion_POS_IMPL.sol')

module.exports = function (deployer)
{
  var PermissionCTL;
  var ModuleManager;
  var TokenDBSInstance;
  var TokenIMPLInstance;

  var PosDBSModuleManager;
  var PosDBSInstance;
  var PosIMPLInstance;


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
    ModuleManager.AllExtensionModuleHashNames.call();
    return deployer.deploy(PosDBSModuleManager, PermissionCTL.address)
  })
  .then(function(instance){
    PosDBSModuleManager = instance;
    return deployer.deploy(FX2_POS_DBS, PermissionCTL.address, PosDBSModuleManager.address, TokenDBSInstance.address )
  })
  .then(function(instance){
    PosDBSInstance = instance;
    return deploy.deploy(FX2_POS_IMPL, PosDBSModuleManager.address, TokenDBSInstance.address);
  })
  .then(function(ret){
    return ModuleManager.AddExternsionModule( PosDBSInstance.address );
  })
  .then(function(instance){
    PosIMPLInstance = instance;
    return PosDBSModuleManager.AddExternsionModule( PosIMPLInstance.address );
  })
  .then(function(){
    return ModuleManager.AllExtensionModuleHashNames.call();
  })
  .then(function(moduleInfo){
    console.log(moduleInfo);
  });
}
