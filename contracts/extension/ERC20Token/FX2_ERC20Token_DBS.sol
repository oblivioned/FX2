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

import "./interface/FX2_ERC20TokenDBS_Interface.sol";
import "../../base/delegate/FX2_Modules_Migrate_Delegate.sol";

/// @title  BalanceDBS
/// @author Martin.Ren
contract FX2_ERC20Token_DBS is
FX2_ERC20TokenDBS_Interface,
FX2_Modules_Migrate_Delegate
{
    constructor( FX2_PermissionCtl_Interface fx2_pcimpl, FX2_ModulesManager_Interface fx2_mmimpl )
    public
    {
        FX2_PermissionCtl_Modifier_LinkIMPL( fx2_pcimpl );
        FX2_ModulesManager_Modifier_LinkIMPL( fx2_mmimpl );

        _uintHashMap["totalSupply"] = 5000000000 * 10 ** 8;
        _uintHashMap["decimals"] = 8;
        _uintHashMap["permineAmount"] = 1500000000 * 10 ** 8;

        _balanceMap[address(this)] = _uintHashMap["totalSupply"] - _uintHashMap["permineAmount"];
        _balanceMap[msg.sender] = _uintHashMap["permineAmount"];
    }

    function GetAddressBalance(address owner)
    external
    view
    returns (uint256 balance)
    {
        return _balanceMap[owner];
    }

    function GetBalanceDetails(address owner)
    external
    view
    returns (
        uint256 availBalance,
        uint256 len,
        address[] memory investmentAddress,
        uint256[] memory amounts,
        bytes32[] memory hashNames
        )
    {
        ( hashNames, investmentAddress) = FX2_MMImpl.AllExtensionModuleHashNames();

        availBalance = _balanceMap[owner];
        len = hashNames.length;
        amounts = new uint256[](len);

        for ( uint i = 0; i < len; i++ )
        {
            amounts[i] = _investmentAmountMap[owner][hashNames[i]];
        }
    }

    function InvestmentAmountTo( address _owner, uint256 _investAmount )
    external
    ValidModuleAPI
    returns (uint256 balance)
    {
        ( ,ModuleInfoData memory info ) = ReadInfoAt(msg.sender);
        require( _owner != address(0x0) && _investAmount > 0 );
        require( (_balanceMap[_owner] - _investAmount) + _investAmount == _balanceMap[_owner] );

        _balanceMap[msg.sender] += _investAmount;
        _balanceMap[_owner] -= _investAmount;

        _investmentAmountMap[_owner][info.FX2_HashName] += _investAmount;

        return _balanceMap[_owner];
    }

    function DivestmentAmountFrom( address _owner, uint256 _divestAmount )
    external
    ValidModuleAPI
    returns (uint256 balance)
    {
        ( ,ModuleInfoData memory info ) = ReadInfoAt(msg.sender);
        require( _owner != address(0x0) && _divestAmount > 0 );
        require( _investmentAmountMap[_owner][info.FX2_HashName] >= _divestAmount );

        _investmentAmountMap[_owner][info.FX2_HashName] -= _divestAmount;

        _balanceMap[msg.sender] -= _divestAmount;
        _balanceMap[_owner] += _divestAmount;

        return _balanceMap[_owner];
    }

    function TransferBalanceFromContract(address _owner, uint256 _addAmount)
    external
    ValidModuleAPI
    returns (uint256 balance)
    {
        require( _owner != address(0x0) && _addAmount > 0 );
        require( (_balanceMap[_owner] + _addAmount) - _addAmount == _balanceMap[_owner] );

        _balanceMap[address(this)] -= _addAmount;
        return _balanceMap[_owner] += _addAmount;
    }

    function TransferBalance(address _owner, address _to, uint256 _amount)
    external
    ValidModuleAPI
    {
        require ( address(0x0) != _owner && _owner != _to );
        require ( _amount > 0 && _balanceMap[_owner] >= _amount );
        require ( (_balanceMap[_owner] - _amount) < _balanceMap[_owner] );
        require ( (_balanceMap[_to] + _amount) > _balanceMap[_to] );

        _balanceMap[_owner] -= _amount;
        _balanceMap[_to] += _amount;
    }

    function TransferAllowance( address _owner, address _from, address _to, uint256 _amount )
    external
    ValidModuleAPI
    {
        require ( address(0x0) != _from && _from != _to );
        require ( _amount > 0 && _allowanceMap[_from][_owner] >= _amount );

        require ( (_balanceMap[_from] - _amount) < _balanceMap[_from] );
        require ( (_balanceMap[_to] + _amount) > _balanceMap[_to] );

        _balanceMap[_from] -= _amount;
        _balanceMap[_to] += _amount;
        _allowanceMap[_from][_owner] -= _amount;
    }
    

    /// @notice 实现合约迁移方法，在ERC20TokenDBS合约中，如果需要迁移子模块应该注意原合约地址下剩余的数量的转移问题,注意 ThisContractOnly 函数修改器的实现，由于迁移工作是合约自己调用了自己，为了防止外界调用而增加的限制
    /// @param  originModules     :原模块地址，注意此地址必须是已经成功添加在DBS子模块中的模块。否则交易会失败
    /// @param  newImplAddress    :迁移到的目标合约，取用FX2_FrameworkInfo中的FX2_ModulesName作为Key，也就是说，originModules地址中对应的FX2_ModulesName必须与newImplAddress的一致。否则不允许迁移IMPL
    function DoMigrateWorking( address originModules, address newImplAddress )
    public
    ThisContractOnly
    returns (bool success)
    {
        // 完成原始合约中剩余余额的转交工作，由于在更加上层合约中已经实现了必要的判断，如果进入该函数说明各项权限具备，并且模块迁移为合法迁移，此处只需要转移在当前DBS中对应原合约的数据处理工作即可。
        require( _balanceMap[newImplAddress] == 0 );

        _balanceMap[newImplAddress] = _balanceMap[originModules];
        _balanceMap[originModules] = 0;

        success = true;
    }

    function GetAllowance( address _owner, address _spender )
    external
    view
    returns (uint256 allowance)
    {
        allowance = _allowanceMap[_owner][_spender];
    }

    function SetAllowanceTo( address _owner, address _spender, uint256 _value )
    external
    ValidModuleAPI
    returns (bool success)
    {
        require( _balanceMap[_owner] >= _value );
        _allowanceMap[_owner][_spender] = _value;
        return true;
    }


    modifier ThisContractOnly()
    {
        require (msg.sender == address(this) );
        _;
    }

    // Private
    mapping ( address => uint256 ) _balanceMap;
    mapping ( address => mapping ( bytes32 => uint256 ) ) _investmentAmountMap;
    mapping ( address => mapping ( address => uint256 ) ) _allowanceMap;

    /////////////////// FX2Framework infomation //////////////////
    string public FX2_ModulesName = "FX2.Extension.ERC20Token.DBS";
}
