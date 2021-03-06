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

import "../../../base/abstract/FX2_AbstractDBS.sol";

/// @title  BalanceDBS
/// @author Martin.Ren
contract FX2_ERC20TokenDBS_Interface is FX2_AbstractDBS
{
    /// @notice 获取余额组成的详情
    /// @param  owner             ：对应获取的地址
    /// @return availBalance      : 可用余额数量
    /// @return len               : 后续返回数据中数组的元素长度
    /// @return investmentAddress : 投入到的合约地址
    /// @return amounts           : 投入数量
    /// @return hashNames         : 模块名称的Hash值
    function GetBalanceDetails(address owner) external view returns ( uint256 availBalance, uint256 len, address[] memory investmentAddress, uint256[] memory amounts, bytes32[] memory hashNames);

    /// @notice 获取对应地址在该插座合约的余额
    /// @param  owner   : 获取余额指定的地址
    /// @return balance : 余额(最大精度 即 10 ** decimals)
    function GetAddressBalance(address owner) external view returns (uint256 balance);

    /// @notice 将msg.sender指定的数量转移到某个子插件合约中，就行投资，一般来说调用后成功后进行
    ///         插件合约的逻辑。比如增加投资记录等，但是余额失踪记录在插件合约地址中。
    /// @param  _modules : 合约模块地址，必须是已经接入的插件合约，不支持用名称标示。
    /// @param  _investAmount : 投入的数量
    /// @return balance : 就行投资后msg.sender的剩余数量(最大精度 即 10 ** decimals)
    function InvestmentAmountTo( address _modules, uint256 _investAmount ) external returns (uint256 balance);

    /// @notice 将msg.sender指定的数量从已经投资插件合约中提取已经投入的余额
    /// @param  _modules : 合约模块地址，必须是已经接入的插件合约，不支持用名称标示。
    /// @param  _divestAmount : 撤资的数量
    /// @return balance : 撤资后msg.sender的剩余数量(最大精度 即 10 ** decimals)
    function DivestmentAmountFrom( address _modules, uint256 _divestAmount ) external returns (uint256 balance);

    /// @notice 从未产出的矿池中转出对应的数量到指定的owner地址中
    /// @param  _owner : 接受数量的地址
    /// @param  _addAmount : 增加的数量
    /// @return balance : 增加后owner地址中的余额(最大精度 即 10 ** decimals)
    function TransferBalanceFromContract(address _owner, uint256 _addAmount) external returns (uint256 balance);

    /// @notice 用户间转账功能,若不成功一定会产生断言
    /// @param  _owner : 转出方地址
    /// @param  _to : 接收方地址
    /// @param _amount : 交易数量
    function TransferBalance( address _owner, address _to, uint256 _amount) external;

    /// @notice 设置赏金
    /// @param  _owner      : 赏金发放地址，一般为msg.sender
    /// @param  _spender    : 发放赏金的目标地址
    /// @param  _value      : 发放赏金数量
    /// @return success     : 发放结果
    function SetAllowanceTo( address _owner, address _spender, uint256 _value ) external returns (bool success);

    /// @notice 获取赏金数量
    /// @param  _owner      : 赏金发放地址
    /// @param  _spender    ：打赏人地址
    /// @return allowance   : 可提取的赏金数量
    function GetAllowance( address _owner, address _spender ) external view returns (uint256 allowance);

    /// @notice 交易赏金
    /// @param  _owner  : 即sender
    /// @param  _from   : 提取赏金的地址
    /// @param  _to     : 赏金提取的目标地址
    /// @param _amount  : 提取数量
    function TransferAllowance( address _owner, address _from, address _to, uint256 _amount ) external;

}
