var FX2_ModulesManager = artifacts.require('./base/implement/FX2_ModulesManager.sol')
var FX2_PermissionCtl = artifacts.require('./base/implement/FX2_PermissionCtl.sol')

contract('FX2_ModulesManager', function (accounts) {

  it("Test [AddAdmin, RemoveAdmin, GetAllPermissionAddress]", function()
  {
    var FX2_PCIMPL;
    var testContractInstance;

    var Test = function()
    {
        console.log("Step2")
        testContractInstance = testInstance;
        testContractInstance.ChangeContractState( FX2_ModulesManager.ModulesState.Disable )
        .then( function() {
          console.log("Step2")
          assert.equal(ret, FX2_ModulesManager.ModulesState.Disable, "ChangeContractState TestFailed.");
        })
    }

    FX2_PermissionCtl.deployed()
    .then( function (instance) {
      FX2_PCIMPL = instance
      FX2_ModulesManager.deployed(FX2_PCIMPL.address).then(Test);
    });
  })

})
