var FX2_ERC20Token_IMPL   = artifacts.require('./extension/ERC20Token/FX2_ERC20Token_IMPL.sol');

var FX2_POS_DBS           = artifacts.require('./extension/Pos/FX2_Externsion_POS_DBS.sol')
var FX2_POS_IMPL          = artifacts.require('./extension/Pos/FX2_Externsion_POS_IMPL.sol')

contract('FX2_Externsion_POS_IMPL', function (accounts) {

  var ERC20Token_IMPL_Instance;
  var POS_IMPL_Instance;

  /*
  it("Test [DespoitToPos, GetPosRecordLists, GetCurrentPosSum, balanceOf]", function() {

    return FX2_ERC20Token_IMPL.deployed()
    .then(function(instance){
      ERC20Token_IMPL_Instance = instance;
      return ERC20Token_IMPL_Instance.transfer(accounts[1], "30000000000000000")
    })
    .then(function(){
      return ERC20Token_IMPL_Instance.transfer(accounts[2], "30000000000000000")
    })
    .then(function(){
      return ERC20Token_IMPL_Instance.transfer(accounts[3], "25000000000000000")
    })
    .then(function(){
      return ERC20Token_IMPL_Instance.transfer(accounts[4], "25000000000000000")
    })
    .then(function(){
      return ERC20Token_IMPL_Instance.balanceOf(accounts[0])
    })
    .then(function(balance){
      assert.equal(balance.toString(), "40000000000000000", "Use transfer faild.")
      return FX2_POS_IMPL.deployed()
    })
    .then(function(instance){
      POS_IMPL_Instance = instance;
      return POS_IMPL_Instance.DespoitToPos("30000000000000000", {from:accounts[0]})
    })
    .then(function(response){
      return POS_IMPL_Instance.DespoitToPos("30000000000000000", {from:accounts[1]})
    })
    .then(function(response){
      return POS_IMPL_Instance.DespoitToPos("20000000000000000", {from:accounts[2]})
    })
    .then(function(response){
      return POS_IMPL_Instance.DespoitToPos("25000000000000000", {from:accounts[3]})
    })
    .then(function(response){
      return POS_IMPL_Instance.DespoitToPos("5000000000000000", {from:accounts[4]})
    })
    .then(function(response){
      return POS_IMPL_Instance.DespoitToPos("5000000000000000", {from:accounts[4]})
    })
    .then(function(response){
      return POS_IMPL_Instance.DespoitToPos("5000000000000000", {from:accounts[4]})
    })
    .then(function(response){
      return POS_IMPL_Instance.DespoitToPos("10000000000000000", {from:accounts[4]})
    })
    .then(function(response){
      return ERC20Token_IMPL_Instance.balanceOf(accounts[0])
    })
    .then(function(balance){
      assert.equal(balance.toString(), "10000000000000000", "Test DespoitToPos Faild.")
      return ERC20Token_IMPL_Instance.balanceOf(accounts[1])
    })
    .then(function(balance){
      assert.equal(balance.toString(), "0", "Test DespoitToPos Faild.")
      return ERC20Token_IMPL_Instance.balanceOf(accounts[2])
    })
    .then(function(balance){
      assert.equal(balance.toString(), "10000000000000000", "Test DespoitToPos Faild.")
      return ERC20Token_IMPL_Instance.balanceOf(accounts[3])
    })
    .then(function(balance){
      assert.equal(balance.toString(), "0", "Test DespoitToPos Faild.")
      return ERC20Token_IMPL_Instance.balanceOf(accounts[4])
    })
    .then(function(balance){
      assert.equal(balance.toString(), "0", "Test DespoitToPos Faild.")
      return POS_IMPL_Instance.GetPosRecordLists.call({from:accounts[0]})
    })
    .then(function(response){
      assert.equal( response["len"], "1", "Test GetPosRecordLists Faild." );
      return POS_IMPL_Instance.GetPosRecordLists.call({from:accounts[4]})
    })
    .then(function(response){
      assert.equal( response["len"], "4", "Test GetPosRecordLists Faild." );
      return POS_IMPL_Instance.GetCurrentPosSum.call();
    })
    .then(function(totalSum){
      assert.equal( totalSum.toString(), "130000000000000000", "Test GetPosRecordLists Faild." );
    })
  })
  */

  it("Test [DespoitToPos,]", function(){

    return FX2_POS_IMPL.deployed().then(function(instance) {
      POS_IMPL_Instance = instance
      return POS_IMPL_Instance.DespoitToPos.call("150000000000000000")
    })
    .then(function(response){
      assert.equal(response, true, "Test DespoitToPos Faild.")
      return POS_IMPL_Instance.GetPosRecordLists();
    })
    .then(function(response){
      console.log(response);
      return POS_IMPL_Instance.RescissionPosAt.call(0)
    })
    .then(function(response){
      assert.equal( response.posProfit.toString(), "0", "Test RescissionPosAt Faild : posProfit returned error.")
      assert.equal( response.amount.toBeLessThan(), "150000000000000000", "Test RescissionPosAt Faild : amount returned error.")
    })

  })

  // it("Test [RescissionPosAt, RescissionPosAll, GetPosRecordLists, balanceOf]", function() {
  //
  //   return POS_IMPL_Instance.RescissionPosAt.call(0, {from:accounts[4]})
  //   .then(function(response){
  //     assert.equal(response.amount.toString(), "5000000000000000", "Test RescissionPosAt Faild : amount retured err");
  //     assert.equal(response.posProfit.toString(), "0", "Test RescissionPosAt 0 Faild : posProfit retured err.");
  //     return POS_IMPL_Instance.GetPosRecordLists.call({from:accounts[4]})
  //   })
  //   .then(function(response){
  //     console.log(response);
  //     assert.equal(response["len"], "3", "Test GetPosRecordLists Faild." );
  //     return POS_IMPL_Instance.RescissionPosAt.call(3, {from:accounts[4]})
  //   })
  //   .then(function(response){
  //     console.log(response.amount.toString());
  //     assert.equal(response.amount.toString(), "10000000000000000", "Test RescissionPosAt Faild : amount retured err");
  //     assert.equal(response.posProfit.toString(), "0", "Test RescissionPosAt 0 Faild : posProfit retured err.");
  //     return ERC20Token_IMPL_Instance.balanceOf.call(accounts[4]);
  //   })
  //   .then(function(response){
  //     assert.equal(response.toString(), "15000000000000000", "Test RescissionPosAt 0 Faild : balance error.");
  //     return POS_IMPL_Instance.GetPosRecordLists.call({from:accounts[4]})
  //   })
  //   .then(function(response){
  //     assert.equal( response["len"], "2", "Test GetPosRecordLists Faild." );
  //     return POS_IMPL_Instance.RescissionPosAll.call({from:accounts[4]})
  //   })
  //   .then(function(response){
  //     assert.equal(response.amountTotalSum.toString(), "10000000000000000", "Test RescissionPosAt Faild : amount retured err");
  //     assert.equal(response.profitTotalSum.toString(), "0", "Test RescissionPosAt 0 Faild : posProfit retured err.");
  //     return POS_IMPL_Instance.GetPosRecordLists.call({from:accounts[4]})
  //   })
  //   .then(function(response){
  //     assert.equal( response["len"], "0", "Test GetPosRecordLists Faild." );
  //     return ERC20Token_IMPL_Instance.balanceOf.call(accounts[4]);
  //   })
  //   .then(function(response){
  //     console.log(response);
  //     assert.equal(response.amount.toString(), "25000000000000000", "Test RescissionPosAt 0 Faild : balance error.");
  //   })
  //
  // })
});
