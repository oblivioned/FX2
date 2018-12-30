pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/MetaCoin.sol";

contract TestMetacoin {

  function testInitialBalanceUsingDeployedContract() public {
    MetaCoin meta = MetaCoin(DeployedAddresses.MetaCoin());

    uint expected = 10000;

    Assert.equal(meta.getBalance(tx.origin), expected, "Owner should have 10000 MetaCoin initially");
  }

  function testInitialBalanceWithNewMetaCoin() public {
    MetaCoin meta = new MetaCoin();

    uint expected = 10000;

    Assert.equal(meta.getBalance(tx.origin), expected, "Owner should have 10000 MetaCoin initially");
  }

}



/*
pragma solidity >=0.5.0 <0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/FX2/base/FX2_PermissionCtl.sol";

contract TestFX2_PermissionCtl
{
  FX2_PermissionCtl CTL;

  function test_InitPermissionCtl() public
  {
    CTL = FX2_PermissionCtl(DeployedAddresses.FX2_PermissionCtl());
  }

  function test_IsSuperOrAdmin() public
  {
    bool ret = true;
    Assert.equal( CTL.IsSuperOrAdmin(address(this)), ret, "超级权限检测失败" );
  }

  function test_AddAdmin() public
  {
    address testRetAddr = address(this);

    for ( uint i = 0; i < 100; i++ )
    {
      CTL.AddAdmin( address(0x0 + i) );
    }

    ( address superAdmin, address[] memory admins ) = CTL.GetAllPermissionAddress();


    Assert.equal( superAdmin, testRetAddr, "GetAllPermissionAddress:返回的超级权限地址不正确" );
    Assert.equal( admins.length, 100, "AddAdmin:添加100个管理地址后获取的数量不正确");
  }

}


*/
