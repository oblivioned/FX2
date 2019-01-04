var FX2_PermissionCtl           = artifacts.require('./base/implement/FX2_PermissionCtl.sol')

var FX2_ModulesManager_Token    = artifacts.require('./base/implement/FX2_ModulesManager.sol')
var FX2_ERC20Token_DBS          = artifacts.require('./extension/ERC20Token/FX2_ERC20Token_DBS.sol')
var FX2_ERC20Token_IMPL         = artifacts.require('./extension/ERC20Token/FX2_ERC20Token_IMPL.sol')

var FX2_ModulesManager_POS      = artifacts.require('./base/implement/FX2_ModulesManager.sol')
var FX2_POS_DBS                 = artifacts.require('./extension/Pos/FX2_Externsion_POS_DBS.sol')
var FX2_POS_IMPL                = artifacts.require('./extension/Pos/FX2_Externsion_POS_IMPL.sol')

module.exports = function (deployer)
{
  var PermissionCTL_Instance;
  var ModulesManager_Token_Instance;
  var ERC20Token_DBS_Interface;
  var ERC20Token_IMPL_Instance;

  var ModulesManager_POS_Instance;
  var POS_DBS_Instance;
  var POS_IMPL_Instance;

  deployer.deploy(FX2_PermissionCtl)
  .then(function( instance ){
    PermissionCTL_Instance = instance;
    return deployer.deploy(FX2_ModulesManager_Token, PermissionCTL_Instance.address)
  })
  .then(function( instance ) {
    ModulesManager_Token_Instance = instance;
    return deployer.deploy(FX2_ERC20Token_DBS, PermissionCTL_Instance.address, ModulesManager_Token_Instance.address)
  })
  .then(function( instance ) {
    ERC20Token_DBS_Interface = instance;
    return deployer.deploy(FX2_ERC20Token_IMPL, ERC20Token_DBS_Interface.address)
  })
  .then(function(instance){
    ERC20Token_IMPL_Instance = instance;
    return deployer.deploy(FX2_ModulesManager_POS, PermissionCTL_Instance.address)
  })
  .then(function(instance){
    ModulesManager_POS_Instance = instance;
    return deployer.deploy(FX2_POS_DBS, PermissionCTL_Instance.address, ModulesManager_POS_Instance.address, ERC20Token_DBS_Interface.address )
  })
  .then(function(instance){
    POS_DBS_Instance = instance;
    return deployer.deploy(FX2_POS_IMPL, POS_DBS_Instance.address, ERC20Token_DBS_Interface.address);
  })
  // 添加模块之间的权限连接
  .then(function(instance){
    POS_IMPL_Instance = instance;
    return ModulesManager_Token_Instance.AddExternsionModule( ERC20Token_IMPL_Instance.address ).catch(function(err){
      console.log("   > ⚠️  AddExternsionModule Faild.");
    })
  })
  .then(function(){
    return ModulesManager_Token_Instance.AddExternsionModule( POS_DBS_Instance.address ).catch(function(err){
      console.log("   > ⚠️  AddExternsionModule Faild.");
    })
  })
  .then(function(){
    return ModulesManager_Token_Instance.AddExternsionModule( POS_IMPL_Instance.address ).catch(function(err){
      console.log("   > ⚠️  AddExternsionModule Faild.");
    })
  })
  .then(function(){
    return ModulesManager_Token_Instance.AllExtensionModuleHashNames.call();
  })
  .then(function(response){

    if ( response[1].length !== 3 ) {
      console.log("   > ⚠️  AllExtensionModuleHashNames Response Error.");
    }
    else {
      return ModulesManager_POS_Instance.AddExternsionModule( POS_IMPL_Instance.address ).catch( function( err ){
        console.log("   > ⚠️  AddExternsionModule Faild.");
        })
    }

  })
  .then(function() {
    return ModulesManager_POS_Instance.AllExtensionModuleHashNames.call();
  })
  .then(function(response) {
    if ( response[1].length !== 1 ) {
      console.log("   > ⚠️  AllExtensionModuleHashNames Response Error.");
    }
  })
}
