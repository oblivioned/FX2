pragma solidity >=0.5.0 <0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/base/interface/FX2_PermissionCtl_Interface.sol";

contract TestFX2_PermissionCtl
{
  /* DiviesInterface constant private Divies = DiviesInterface(0xc7029Ed9EBa97A096e72607f4340c34049C7AF48); */
  FX2_PermissionCtl_Interface private CTL = FX2_PermissionCtl_Interface(0x59EDdAcF8026B9CD0cBEfF9Fb6F6cE16d4995ebE);

  // 检测超级权限是否正确
  function test_IsSuperOrAdmin() public
  {
    /* Assert.equal( CTL.IsSuperOrAdmin(address(this)), true, "超级权限检测失败" ); */
    Assert.equal( CTL.IsSuperOrAdmin(msg.sender), false, "超级权限检测失败" );
  }

  function test_RequireSuper() public
  {
    CTL.RequireSuper(address(this));
  }

  // 测试增加账号，数量是否正确
  function test_AddAdmin() public
  {
    CTL.AddAdmin( msg.sender );

    ( address superAdmin, address[] memory admins ) = CTL.GetAllPermissionAddress();

    Assert.equal( superAdmin, address(this), "AddAdmin:获取所有管理员地址中返回的超级权限地址不正确");
    Assert.equal( admins.length, 1, "AddAdmin:添加地址后数量不正确");
    Assert.equal( admins[0], msg.sender, "AddAdmin:地址不正确");
  }


  function test_RequireAdmin() public
  {
    Assert.equal( CTL.IsSuperOrAdmin(msg.sender), true, "管理权限检测失败" );
    CTL.RequireAdmin(msg.sender);
  }

  // 测试移除管理员
  function test_RemoveAdmin() public
  {
    CTL.RemoveAdmin(msg.sender);
    Assert.equal( CTL.IsSuperOrAdmin(msg.sender), false, "超级权限检测失败" );
  }

}
