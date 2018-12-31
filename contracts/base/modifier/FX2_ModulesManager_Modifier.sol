/*
 *
 *《 Flying Feathers 》- Aya ETH Contract Frameworks
 * 版本:0.0.1
 * 作者:Martin.Ren（oblivioned)
 * 最后修改时间:2018-12-30
 * 项目地址:https://github.com/oblivioned/FX2
 *
 */

pragma solidity >=0.5.0 <0.6.0;

import "../interface/FX2_ModulesManager_Interface.sol";

contract FX2_ModulesManager_Modifier
{
    FX2_ModulesManager_Interface FX2_MMImpl;

    function FX2_ModulesManager_Modifier_LinkIMPL ( FX2_ModulesManager_Interface fx2_mmimpl )
    internal
    {
        FX2_MMImpl = fx2_mmimpl;
    }

    modifier ValidModuleAPI()
    {
      require ( FX2_MMImpl.IsExistContractVisiter(msg.sender) );
      _;
    }

    /// @notice 此函数修改器可以增加在任何支持FX2_PermissionInterface的合约函数内，配合
    ///         提供的断言函数，切换合约状态，该修改器定义为，情况比state更加好转的情况下可
    ///         以执行例如，BetterThanExecuted(DBSContractState.Sicking)那么在合约
    ///         状态为Sicking和Healthy时候可以执行。
    /// @param  _betterThanState  : 最差可以继续执行的状态
    modifier BetterThanExecuted( FX2_ModulesManager_Interface.ModulesState _betterThanState )
    {
      if ( _betterThanState == FX2_ModulesManager_Interface.ModulesState.AnyTimes )
      {
        _;
        return ;
      }

      if ( FX2_MMImpl.IsDoctorProgrammer(msg.sender) )
      {
        _;
        return ;
      }

      require( FX2_MMImpl.State() != FX2_ModulesManager_Interface.ModulesState.Disable, "The contract is being Disable.");
      require( FX2_MMImpl.State() != FX2_ModulesManager_Interface.ModulesState.Migrated, "The contract has been discarded and moved to the new contract.");
      require( FX2_MMImpl.State() <= _betterThanState, "Failure of health examination." );
      _;
    }
}
