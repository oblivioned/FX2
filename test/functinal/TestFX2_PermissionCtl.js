var FX2_PermissionCtl = artifacts.require('./base/implement/FX2_PermissionCtl.sol')

contract('FX2_PermissionCtl', function (accounts) {

  var testContractInstance;

  it("Test [AddAdmin, RemoveAdmin, GetAllPermissionAddress]", function()
  {
    return FX2_PermissionCtl.deployed().then( function (instance) {
      testContractInstance = instance;

    }).then( function () {

      for ( var i = 0; i < accounts.length; i++ ) {
        testContractInstance.AddAdmin(accounts[i]);
      }
      return testContractInstance.GetAllPermissionAddress.call();

    }).then( function (ret) {

      assert.equal( ret[1].length, accounts.length, "AddAdmin Function Test Faild.");

    }).then( function() {

      for ( var i = 0; i < accounts.length; i++ ) {
        testContractInstance.RemoveAdmin(accounts[i]);
      }
      return testContractInstance.GetAllPermissionAddress.call();

    }).then( function(ret) {

      assert.equal(ret[1].length, 0, "RemoveAdmin Function Test Faild.");

    })

  })

  it("Test [IsSuperOrAdmin]", function ()
  {
    var superAddress = accounts[0];
    var adminAddress = accounts[1];

    return FX2_PermissionCtl.deployed().then( function (instance) {

      testContractInstance = instance;
      return testContractInstance.IsSuperOrAdmin.call(superAddress);

    }).then(function (checkRet) {

      assert.equal(checkRet, true, "Check Super Admin Permission Faild.");
      return testContractInstance.AddAdmin(adminAddress);

    }).then(function(){

      return testContractInstance.IsSuperOrAdmin.call(adminAddress);

    }).then(function( checkRet ){

      assert.equal(checkRet, true, "Check Admin Permission Faild.");

    });

  });

  it("Test [RequireSuper]", function() {

    var testContractInstance;

    return FX2_PermissionCtl.deployed().then( function (instance) {

      testContractInstance = instance;
      return testContractInstance.RequireSuper(accounts[0]);

    }).then( function( result ) {
      return testContractInstance.RequireAdmin(accounts[1]).catch( function (){} );
    }).then( function( result ) {
      return testContractInstance.AddAdmin(accounts[1]);
    }).then( function(){
      return testContractInstance.RequireAdmin(accounts[1]);
    }).then( function(){
      return testContractInstance.RemoveAdmin(accounts[1]);
    }).then( function() {
      return testContractInstance.RequireAdmin(accounts[1]).catch( function (){} );
    })
  })

})
