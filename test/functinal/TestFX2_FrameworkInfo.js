var FX2_PermissionCtl           = artifacts.require('./base/implement/FX2_PermissionCtl.sol')

var FX2_ModulesManager_Token    = artifacts.require('./base/implement/FX2_ModulesManager.sol')
var FX2_ERC20Token_DBS          = artifacts.require('./extension/ERC20Token/FX2_ERC20Token_DBS.sol')
var FX2_ERC20Token_IMPL         = artifacts.require('./extension/ERC20Token/FX2_ERC20Token_IMPL.sol')

var FX2_ModulesManager_POS      = artifacts.require('./base/implement/FX2_ModulesManager.sol')
var FX2_POS_DBS                 = artifacts.require('./extension/Pos/FX2_Externsion_POS_DBS.sol')
var FX2_POS_IMPL                = artifacts.require('./extension/Pos/FX2_Externsion_POS_IMPL.sol')


var FX2_Version_Info_Str = "Powerby FX2 Aya 0.0.1 Release 2018-12-28";
var ModulesArr = [];

contract('FX2_FrameworkInfo', function (accounts) {

  GetFx2InfoMation = function(text, contract){
    it( text, function(){
      return contract.deployed().then(function(instance){
        return instance.FX2_ModulesName.call()
      })
      .then(function(info){
        ModulesArr.push(info);
      })
    })
  }

  GetFx2InfoMation("Get Infomation FX2_PermissionCtl ", FX2_PermissionCtl);

  GetFx2InfoMation("Get Infomation FX2_ModulesManager_Token", FX2_ModulesManager_Token);
  GetFx2InfoMation("Get Infomation FX2_ERC20Token_DBS", FX2_ERC20Token_DBS);
  GetFx2InfoMation("Get Infomation FX2_ERC20Token_IMPL", FX2_ERC20Token_IMPL);

  GetFx2InfoMation("Get Infomation FX2_ModulesManager_POS", FX2_ModulesManager_POS);
  GetFx2InfoMation("Get Infomation FX2_POS_DBS", FX2_POS_DBS);
  GetFx2InfoMation("Get Infomation FX2_POS_IMPL", FX2_POS_IMPL);

})
