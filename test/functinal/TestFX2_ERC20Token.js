var FX2_ERC20Token_IMPL   = artifacts.require('./extension/ERC20Token/FX2_ERC20Token_IMPL.sol');

contract('FX2_ERC20Token_IMPL', function (accounts) {

  var instance;

  it("Test [totalSupply, name, decimals]", function(){

    return FX2_ERC20Token_IMPL.at(FX2_ERC20Token_IMPL.address).then(function(response){
      instance = response;
      return instance.totalSupply.call()
    }).then(function( response ){
      assert.equal( response.toString(), "500000000000000000", "test totalSupply() faild." )
      return instance.name.call()
    }).then(function( response ){
      assert.equal( response, "ANT(Coin)", "test name() faild." )
      return instance.decimals.call()
    }).then(function( response ){
      assert.equal( response.toString(), "8", "test decimals() faild." )
      return instance.symbol.call()
    }).then(function( response ){
      assert.equal( response.toString(), "ANT", "test symbol() faild.")
    })

  })


  it("Test [balanceOf, transfer]", function(){

    return FX2_ERC20Token_IMPL.at(FX2_ERC20Token_IMPL.address).then( function(response) {
      instance = response;
      return instance.balanceOf.call( accounts[0] );
    }).then(function(response){
      assert.equal(response.toString(), "150000000000000000", "test balanceOf owner faild.");
      return instance.transfer( accounts[1],"150000000000000000" )
    }).then(function(){
      return instance.balanceOf.call( accounts[0] );
    }).then(function(response){
      assert.equal(response.toString(), "0", "test transfer faild.");
      return instance.balanceOf.call( accounts[1] );
    }).then(function(response){
      assert.equal(response.toString(), "150000000000000000", "test transfer faild.");
    })

  })

});
