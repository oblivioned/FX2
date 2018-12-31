pragma solidity >=0.5.0 <0.6.0;

import "../contracts/base/implement/FX2_PermissionInterface.sol";
import "../contracts/base/interface/FX2_PermissionCtl_Interface.sol";

contract TestFX2_PermissionInterface is FX2_PermissionInterface
{
  FX2_PermissionCtl_Interface CTLInterface = FX2_PermissionCtl_Interface(0x59EDdAcF8026B9CD0cBEfF9Fb6F6cE16d4995ebE);

  function test_InitPermissionInterface_OnwerIsThisContract() public
  {
    /// 使用DeployedAddresses创建合约，可以使msg.sender修改为测试的第一个地址，而非本合约
    /// 主要用于隔离权限，让当前测试合约地址不具备超级权限
    /* CTL_SuperOwnerIsSender = FX2_PermissionCtl(DeployedAddresses.FX2_PermissionCtl()); */
    /* CTL_SuperOwnerIsThis = */
    ContractState = DBSContractState.Healthy;
  }

  /// 该用例使用的CTL的超级权限是合约本身，即msg.sender不具备任何管理权限
  function test_BetterThanExecutedHealthy_OnwerIsThisContract() public
  BetterThanExecuted(DBSContractState.Error)
  BetterThanExecuted(DBSContractState.Sicking)
  BetterThanExecuted(DBSContractState.Healthy)
  BetterThanExecuted(DBSContractState.AnyTimes)
  {
    require( uint8(ContractState) == uint8(DBSContractState.Healthy) );
    ContractState = DBSContractState.Sicking;
  }


  /// 该用例使用的CTL的超级权限是合约本身，即msg.sender不具备任何管理权限
  function test_BetterThanExecutedSicking_OnwerIsThisContract() public
  BetterThanExecuted(DBSContractState.Error)
  BetterThanExecuted(DBSContractState.Sicking)
  BetterThanExecuted(DBSContractState.AnyTimes)
  {
    require( uint8(ContractState) == uint8(DBSContractState.Sicking) );
    ContractState = DBSContractState.Error;
  }

  /*
  /// 该用例使用的CTL的超级权限是合约本身，即msg.sender不具备任何管理权限
  function test_BetterThanExecutedError_OnwerIsThisContract() public
  BetterThanExecuted(DBSContractState.Error)
  BetterThanExecuted(DBSContractState.AnyTimes)
  {
    Assert.equal( uint8(ContractState) == uint8(DBSContractState.Error), true, "");
    ContractState = DBSContractState.Disable;
  }

  /// 该用例使用的CTL的超级权限是合约本身
  function test_BeforNeedAdminPermission() public
  {
    CTLInterface.AddAdmin(msg.sender);
  }

  /// 该用例使用的CTL的超级权限是合约本身
  /// 上一个用例添加了msg.sender作为管理员
  function test_BeforNeedAdminPermission_OnwerIsThisContract() public
  NeedAdminPermission
  {
    Assert.equal( IsExistContractVisiter(msg.sender), true, "用例已经添加了msg.sender作为管理员，但是方法IsExistContractVisiter检测权限失败");
    ContractState = DBSContractState.Disable;
  }

  /// 该用例使用的CTL的超级权限是合约本身
  /// 上一个用例已经设置了msg.sender作为管理员，msg.sender发送到消息应该可以正常到通过
  /// ConstractInterfaceMethod 函数修改器到权限检测
  function test_ConstractInterfaceMethod_OwnerIsThisContract() public
  ConstractInterfaceMethod
  {
    Assert.equal( IsExistContractVisiter(msg.sender), true, "用例已经添加了msg.sender作为管理员，但是方法IsExistContractVisiter检测权限失败");
  }

  /// 该用例使用的CTL的超级权限是合约本身
  /// 前面用例将合约状态设置到了“禁用”，对于无管理权限到用户，将无法通过合约状态检测
  /// 而对于拥有管理员权限的地址，将不受限制,应该正常调用
  function test_IsDoctorProgrammer_OwnerIsThisContract() public
  BetterThanExecuted(DBSContractState.Healthy)
  {
    Assert.equal( uint8(ContractState) == uint8(DBSContractState.Disable), true, "");
    Assert.equal( CTLInterface.RemoveAdmin(msg.sender), true, "移除msg.sender的管理员权限失败");
    Assert.equal( IsExistContractVisiter(msg.sender), false, "移除msg.sender的管理权限成功后，检测到msg.sender到管理权限依然存在");
  } */

  /* /// 切换权限控制合约，使msg.sender拥有超级权限
  function test_InitSuperManagerTestInstance() public
  {
    /// 此处使用new生成权管合约后，由于msg.sender 使本合约，所以此行以后的，合约的身份会变为超级管理员
    CTLInterface = FX2_PermissionCtl_Interface(address(CTL_SuperOwnerIsSender));
    ContractState = DBSContractState.Migrated;
  }

  /// 该用例 msg.sender 为超级权限拥有者
  /// 上一个用例将合约状态设置到了“已经迁移”，对于无管理权限到用户，将无法通过合约状态检测
  /// 而对于拥有管理员权限的地址，将不受限制,应该正常调用
  function test_IsDoctorProgrammer_InOwnerIsSender() public
  BetterThanExecuted(DBSContractState.Healthy)
  {
    Assert.equal( uint8(ContractState) == uint8(DBSContractState.Migrated), true, "");
  }

  /// 该用例 msg.sender 为超级权限拥有者
  function test_NeedSuperPermission_InOwnerIsSender() public
  NeedSuperPermission
  {
    Assert.equal( IsExistContractVisiter(msg.sender), true, "");
  } */
}
