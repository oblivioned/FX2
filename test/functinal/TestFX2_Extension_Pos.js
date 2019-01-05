var FX2_ERC20Token_IMPL   = artifacts.require('./extension/ERC20Token/FX2_ERC20Token_IMPL.sol');

var FX2_POS_DBS           = artifacts.require('./extension/Pos/FX2_Externsion_POS_DBS.sol')
var FX2_POS_IMPL          = artifacts.require('./extension/Pos/FX2_Externsion_POS_IMPL.sol')

contract('FX2_Externsion_POS_IMPL', function (accounts) {

  var ERC20Token_IMPL_Instance;
  var POS_IMPL_Instance;

  /*
  ** 用例描述：将地址下所有的活动余额投入Pos池后在没有任何收益的情况下马上提取，严重经过投入和提取后余额的数量是否不变
  */
  it("Test [DespoitToPos, RescissionPosAt, balanceOf]", function(){

    return FX2_POS_IMPL.deployed().then(function(instance) {
      POS_IMPL_Instance = instance
      return POS_IMPL_Instance.DespoitToPos("150000000000000000").catch(function(){
        throw "Test DespoitToPos('150000000000000000') Faild."
      })
    })
    .then(function(response) {
      return POS_IMPL_Instance.RescissionPosAt(0);
    })
    .then(function(txHash) {
      return FX2_ERC20Token_IMPL.deployed()
    })
    .then(function(instance){
      return instance.balanceOf.call(accounts[0])
    })
    .then(function(balance){
      assert.equal( balance.toString(), "150000000000000000", "Test RescissionPosAt Faild : amount returned error.")
    })
  })

  /*
  ** 用例描述：将地址下所有的活动余额分不同的数量总共4次投入Pos池，并且首先提取第一条记录后
  **         检查余额，通过后在使用一次性提取所有Pos池投入的数量后验证最后账户余额是否与开
  **         始前一样，并且在通过后检查用户剩余的Pos记录，应当为“0”
  */
  it("Test [DespoitToPos, RescissionPosAt, RescissionPosAll, balanceOf, GetPosRecordLists]", function(){

    return FX2_POS_IMPL.deployed().then(function(instance) {
      POS_IMPL_Instance = instance;
      return FX2_ERC20Token_IMPL.deployed();
    })
    .then(function(instance){
      ERC20Token_IMPL_Instance = instance;
      return ERC20Token_IMPL_Instance.balanceOf.call(accounts[0])
    })
    .then(function(balance){
      assert.equal( balance.toString(), "150000000000000000", "Test balanceOf Account 0 Faild.")
      return POS_IMPL_Instance.DespoitToPos("90000000000000000")
    })
    .then(function(){
      return POS_IMPL_Instance.DespoitToPos("10000000000000000")
    })
    .then(function(){
      return POS_IMPL_Instance.DespoitToPos("20000000000000000")
    })
    .then(function(){
      return POS_IMPL_Instance.DespoitToPos("30000000000000000")
    })
    .then(function(){
      return ERC20Token_IMPL_Instance.balanceOf.call(accounts[0])
    })
    .then(function(balance){
      assert.equal( balance.toString(), "0", "Test balanceOf Account 0 Faild.")
      return POS_IMPL_Instance.RescissionPosAt(0);
    })
    .then(function(){
      return ERC20Token_IMPL_Instance.balanceOf.call(accounts[0])
    })
    .then(function(balance){
      assert.equal( balance.toString(), "90000000000000000", "Test balanceOf Account 0 Faild.")
      return POS_IMPL_Instance.RescissionPosAt(0);
    })
    .then(function(){
      return ERC20Token_IMPL_Instance.balanceOf.call(accounts[0])
    })
    .then(function(balance){
      assert.equal( balance.toString(), "100000000000000000", "Test balanceOf Account 0 Faild.")
      return POS_IMPL_Instance.RescissionPosAll();
    })
    .then(function(){
      return ERC20Token_IMPL_Instance.balanceOf.call(accounts[0])
    })
    .then(function(balance){
      assert.equal( balance.toString(), "150000000000000000", "Test balanceOf Account 0 Faild.")
      return POS_IMPL_Instance.GetPosRecordLists.call()
    })
    .then(function(response){
      assert.equal( response["len"].toString(), "0", "Test GetPosRecordLists Faild.")
    })
  })

});
