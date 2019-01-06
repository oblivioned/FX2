var FX2_ERC20Token_DBS          = artifacts.require('./extension/ERC20Token/FX2_ERC20Token_DBS.sol')
var FX2_POS_DBS                 = artifacts.require('./extension/Pos/FX2_Externsion_POS_DBS.sol')

contract('FX2_ERC20Token_IMPL', function (accounts) {

  var AbstractDBSInstance;

  it("Test [SetBoolValue, GetBoolValue]", function(){
    return FX2_ERC20Token_DBS.deployed().then(function(instance){
      AbstractDBSInstance = instance
      return AbstractDBSInstance.SetBoolValue("TestSetBoolTrue", true)
    })
    .then(function(){
      return AbstractDBSInstance.GetBoolValue.call("TestSetBoolTrue")
    })
    .then(function(ret){
      assert.equal(ret, true, "Test Faild.")
      return AbstractDBSInstance.SetBoolValue("TestSetBoolTrue", false)
    })
    .then(function(){
      return AbstractDBSInstance.GetBoolValue.call("TestSetBoolTrue")
    })
    .then(function(ret){
      assert.equal(ret, false, "Test Faild.")
    })
  })

  it("Test [SetAddress, ExistAddressKey, GetAddress]", function(){
    return FX2_ERC20Token_DBS.deployed().then(function(instance){
      AbstractDBSInstance = instance
      return AbstractDBSInstance.SetAddress("TestSetAddress", accounts[1])
    })
    .then(function(){
      return AbstractDBSInstance.ExistAddressKey.call("TestSetAddressNoKey")
    })
    .then(function(exist){
      assert.equal(exist, false, "Test ExistAddressKey faild.")
      return AbstractDBSInstance.ExistAddressKey.call("TestSetAddress")
    })
    .then(function(exist){
      assert.equal(exist, true, "Test ExistAddressKey faild.")
      return AbstractDBSInstance.GetAddress("TestSetAddress")
    })
    .then(function(address){
      assert.equal(address, accounts[1], "Test GetAddress faild.")
      return AbstractDBSInstance.GetAddress("TestSetAddressNokey")
    })
    .then(function(address){
      assert.equal(address, 0, "Test GetAddress faild.")
    })
  })

  TestIntHashMap = function(testByValue){

    var TestSetKeys = "TestSetInt" + testByValue

    it("Test [SetIntValue, ExistIntKey, GetIntValue] : " + testByValue, function(){
      return FX2_ERC20Token_DBS.deployed().then(function(instance){
        AbstractDBSInstance = instance
        return AbstractDBSInstance.ExistIntKey.call(TestSetKeys);
      })
      .then(function(exist){
        assert.equal(exist, false, "Test ExistIntKey faild.")
        return AbstractDBSInstance.SetIntValue(TestSetKeys, testByValue);
      })
      .then(function(){
        return AbstractDBSInstance.ExistIntKey.call(TestSetKeys);
      })
      .then(function(exist){
        if ( testByValue == 0 )
        {
          /// 如果测试的数据是0，则试做不存在
          assert.equal(exist, false, "Test ExistIntKey faild.")
        }
        else
        {
          assert.equal(exist, true, "Test ExistIntKey faild.")
        }
        return AbstractDBSInstance.GetIntValue(TestSetKeys);
      })
      .then(function(value){
        if ( testByValue === "115792089237316195423570985008687907853269984665640564039457584007913129639935" ) {
          assert.equal(value.toString(), "-1", "Test GetIntValue faild.")
        }
        else {
          assert.equal(value.toString(), testByValue.toString(), "Test GetIntValue faild.")
        }
      })
    })
  }

  TestIntHashMap(-1);
  TestIntHashMap(0);
  TestIntHashMap(1);
  TestIntHashMap("115792089237316195423570985008687907853269984665640564039457584007913129639935");

  TestUIntHashMap = function(testByValue){

    var TestSetKeys = "TestSetUint" + testByValue

    it("Test [SetUintValue, ExistUintKey, GetUintValue] : " + testByValue, function(){
      return FX2_ERC20Token_DBS.deployed().then(function(instance){
        AbstractDBSInstance = instance
        return AbstractDBSInstance.ExistUintKey.call(TestSetKeys);
      })
      .then(function(exist){
        assert.equal(exist, false, "Test ExistUintKey faild.")
        return AbstractDBSInstance.SetUintValue(TestSetKeys, testByValue);
      })
      .then(function(){
        return AbstractDBSInstance.ExistUintKey.call(TestSetKeys);
      })
      .then(function(exist){
        if ( testByValue == 0 )
        {
          /// 如果测试的数据是0，则试做不存在
          assert.equal(exist, false, "Test ExistUintKey faild.")
        }
        else
        {
          assert.equal(exist, true, "Test ExistUintKey faild.")
        }
        return AbstractDBSInstance.GetUintValue(TestSetKeys);
      })
      .then(function(value) {
        if (testByValue === -1) {
          assert.equal(value.toString(), "115792089237316195423570985008687907853269984665640564039457584007913129639935", "Test GetUintValue faild.")
        }
        else {
          assert.equal(value.toString(), testByValue.toString(), "Test GetUintValue faild.")
        }
      })
    })
  }

  TestUIntHashMap(0);
  TestUIntHashMap(1);
  TestUIntHashMap(-1);

})
