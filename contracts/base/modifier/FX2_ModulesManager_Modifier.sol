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
        require (
            ( FX2_MMImpl.State() == FX2_ModulesManager_Interface.ModulesState.Healthy && FX2_MMImpl.IsExistContractVisiter(msg.sender) ) ||
            FX2_MMImpl.IsDoctorProgrammer(msg.sender)
            );
        _;
    }
}
