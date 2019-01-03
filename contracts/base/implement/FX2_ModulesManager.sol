/*
 *
 *《 Flying Feathers 》- Aya ETH Contract Frameworks
 * 版本:0.0.1
 * 作者:Martin.Ren（oblivioned)
 * 最后修改时间:2018-12-30
 * 项目地址:https://github.com/oblivioned/FX2
 *
 */

import "../FX2_FrameworkInfo.sol";

import "../modifier/FX2_PermissionCtl_Modifier.sol";

import "../interface/FX2_ModulesManager_Interface.sol";

pragma solidity >=0.5.0 <0.6.0;

/// @notice 合约扩展支持的Interface定义
/// @author Martin.Ren
contract FX2_ModulesManager is
FX2_FrameworkInfo,
FX2_ModulesManager_Interface,
FX2_PermissionCtl_Modifier
{
  constructor( FX2_PermissionCtl_Interface fx2_pcimpl ) public
  {
    FX2_PermissionCtl_Modifier_LinkIMPL(fx2_pcimpl);
  }

  /// @notice 内部实现会获取modulesAddress下是否是一个合法的FX2插件模块，并且检查对应插
  ///         件名称，如已经存在一个相同名称的插件，那么应该去使用“迁移”方法，而不是尝试增
  ///         加。
  ///         如果工作在“监督者”模式下，新增插件会生成一个等待审核的事件。“监督者”在通过审
  ///         批后就行权限开放，由于增加模块实际上本质的工作是对目标地址就行调用授权，如果
  ///         申请已经提交，但是被驳回，新部署的插件合约只能作为一个废弃不可用的状态，因为
  ///         没有插座合约授权他读写数据。
  /// @param  modulesAddress : 迁移的目标合约，必须是已经实现部署的插件合约，并且是一个
  ///         合法的FX2插件模块，可以是FX2提供的标准扩展模块，也可以是遵循FX2规则的自定义
  ///         插件。
  function AddExternsionModule( address modulesAddress )
  external
  NeedAdminPermission
  returns (bool success)
  {
    ( bool supportFX2, ModuleInfoData memory data ) = ReadInfoAt(modulesAddress);

    require( supportFX2 && bytes(data.FX2_ModulesName).length > 0, "AddExternsionModule:Invalid FX2 Modules");

    for (uint i = 0; i < modulesIMPLs.length; i++ )
    {
        if ( keccak256( bytes(modulesIMPLs[i].FX2_ModulesName) ) == keccak256( bytes(data.FX2_ModulesName)) )
        {
            return false;
        }
    }

    modulesIMPLs.push(data);

    return true;
  }


  /// @notice 开始进行子插件合约迁移或升级，内部实现会获取modulesAddress下是否是一个合法
  ///         的FX2插件模块，并且检查对应插件名称，对比当前合约中已经接入的插件合约，就行一
  ///         些必要的验证，比如尝试迁移一个不存在的模块。若验证通过，则会调用迁移工作函数就
  ///         就行迁移工作，如果工作在“监督者”模式下，则迁移工作会提交一个事件，等待“监督者”
  ///         就行批准后在完成迁移。
  ///         注意：在“监督者”模式下，迁移的新合约的状态条件设置为Disable状态，因为你可能
  ///              不知道“监督者”在什么时候通过了你的申请，导致一旦通过就接入合约造成一些
  ///              不好控制的时间，使用Disable在通过申请以后，不会马上生效，当你觉得具备
  ///              生效条件时候，自行调用SetContractState对插件进行启用是一个比较好的方
  ///              式。
  ///@param   modulesAddress : 迁移的目标合约，必须是已经实现部署的插件合约，并且是一个
  ///         合法的FX2插件模块，可以是FX2提供的标准扩展模块，也可以是遵循FX2规则的自定义
  ///         插件。
  function MigrateExternsionModule( address modulesAddress )
  external
  NeedAdminPermission
  returns (bool suucess)
  {
    ( bool supportFX2, ModuleInfoData memory data ) = ReadInfoAt(modulesAddress);

    require( supportFX2 && bytes(data.FX2_ModulesName).length > 0, "AddExternsionModule:Invalid FX2 Modules");

    uint originIndex = 0;
    for (; originIndex < modulesIMPLs.length; originIndex++ )
    {
      if ( keccak256( bytes(modulesIMPLs[originIndex].FX2_ModulesName) ) == keccak256( bytes(data.FX2_ModulesName)) )
      {
        break;
      }
      else if ( originIndex == modulesIMPLs.length - 1 )
      {
        return false;
      }
    }

    (bool result, bytes memory returnData) =
    address(this).call(
        abi.encodeWithSignature("DoMigrateWorking(address,address)",
            modulesIMPLs[originIndex].FX2_ContractAddr,
            modulesAddress));

    bool returnDataToBool;
    assembly { mstore(returnDataToBool, returnData) }

    require( result && bool(returnDataToBool) );

    return true;
  }


  /// @notice 设置当前合约所接入的插件合约的起停状态,可以随时由有权账户就行设置起停
  /// @param  modulesAddress : 已经连接的插件合约地址
  /// @param  newState : 设置的新状态
  function SetExternsionModuleState( address modulesAddress, ModulesState newState )
  external
  NeedAdminPermission
  returns (bool sucecss)
  {
    ( bool supportFX2, ModuleInfoData memory data ) = ReadInfoAt(modulesAddress);

    require(supportFX2, "AddExternsionModule:Invalid FX2 Modules");

    for ( uint i = 0; i < modulesIMPLs.length; i++ )
    {
      if ( keccak256( bytes(modulesIMPLs[i].FX2_ModulesName) ) == keccak256( bytes(data.FX2_ModulesName)) )
      {
        FX2_ModulesManager_Interface(modulesAddress).ChangeContractState.gas(10000)( newState );
        return true;
      }
    }

    return false;
  }

  /// @notice 修改当前合约的状态，由于任何一个继承此合约的实例都有可能是一个插件合约，那么
  ///         插件对应的插座合约可能会对本插件合约就行状态的调整
  function ChangeContractState( ModulesState state )
  external
  NeedAdminPermission
  {
    require( msg.sender == parentModule || FX2_PCImpl.IsSuperOrAdmin( msg.sender ) );
    State = state;
  }

  /// @notice 合约处于外界不可调用的状态时候，比如Disable,Migrated原来具有管理员权限的
  ///         用户继续通行，即在链上保留一个可以调试的接口，用于debug。
  function IsDoctorProgrammer( address addr )
  external
  view
  returns ( bool ret )
  {
    return FX2_PCImpl.IsSuperOrAdmin( addr );
  }


  /*
  /// @notice 实现合约部署工作的方法，在通过所有权限验证后，会调用该方法，就行合约迁移，请
  ///         注意处理数据。注意originModules的模块名称必须与newImplAddress的模块名称
  ///         一致，否则将不会进入该函数就行迁移工作。DBS按理来说不支持迁移，因为数据的迁移
  ///         在FX2中属于一种不够公开的行为。
  /// @param  originModules : 原插件合约地址
  /// @param  newImplAddress : 迁移的目标插件地址
  function DoMigrateWorking( address originModules, address newImplAddress ) external returns (bool suucess);
  */


  /// @notice ConstractInterfaceMethod 函数修改器的实现函数，检测指定的地址是否是有权
  ///         限访问的模块地址
  function IsExistContractVisiter( address visiter )
  external
  view
  returns (bool exist)
  {

    for (uint i = 0; i < modulesIMPLs.length; i++ )
    {
      if ( modulesIMPLs[i].FX2_ContractAddr == visiter )
      {
        return true;
      }
    }

    return false;
  }

  /// @notice 查看当前合约已经连接的插件合约，每个FX2的PermissionInterface合约都可以作
  ///         为插座合约和插件合约，更具实际需求就行插件和插座的划分即可。
  function AllExtensionModules() external view returns (
      uint len,
      address[] memory addresses,
      ModulesState[] memory states
      )
  {
      len = modulesIMPLs.length;
      addresses   = new address[](len);
      states      = new ModulesState[](len);

      for ( uint i = 0; i < len; i++ )
      {
        addresses[i] = modulesIMPLs[i].FX2_ContractAddr;
        states[i] = FX2_ModulesManager_Interface(addresses[i]).State();
      }
  }


  function AllExtensionModuleHashNames()
  external
  view
  returns ( bytes32[] memory hashNames, address[] memory moduleAddress )
  {
    hashNames = new bytes32[](modulesIMPLs.length);
    moduleAddress = new address[](modulesIMPLs.length);

    for ( uint i = 0; i < modulesIMPLs.length; i++ )
    {
      hashNames[i] = modulesIMPLs[i].FX2_HashName;
      moduleAddress[i] = modulesIMPLs[i].FX2_ContractAddr;
    }
  }

  /*——————————————————————————————————————————————————————————————*/
  /*                         Stroage 变量定义                     */
  /*——————————————————————————————————————————————————————————————*/
  address                       parentModule;
  ModuleInfoData[]              modulesIMPLs;

  /*——————————————————————————————————————————————————————————————*/
  /*                          FX2 模块信息                         */
  /*——————————————————————————————————————————————————————————————*/
  string public FX2_ModulesName = "FX2.ModulesManager";
}
