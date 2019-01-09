pragma solidity >=0.5.0 <0.6.0;

import "../../../base/interface/FX2_AbstractDBS_Interface.sol";
import "../../ERC20Token/interface/FX2_ERC20TokenDBS_Interface.sol";
import "../library/FX2_Externsion_LOCK_DBTABLE.sol";

contract FX2_Externsion_LOCK_DBS_Interface
is FX2_AbstractDBS_Interface
{
    /// @notice 获取sender的所有锁定余额记录
    /// @return totalAmounts : 记录的总数量
    /// @return drawedAmount : 本记录中已经提取的数量
    /// @return lastdrawTime : 最后一次提取的时间戳
    /// @return lockDays : 锁定时间（天）
    /// @return createTime : 记录创建时间
    function GetLockRecords() public view returns ( uint len, uint256[] memory totalAmounts, uint256[] memory drawedAmount, uint256[] memory lastdrawTime, uint16[]  memory lockDays, uint256[] memory createTime );


    /// @notice 提取锁仓记录的释放量
    /// @param  _rid : 记录的检索号
    /// @return profit : 成功提取的数量
    function WithDrawLockRecordProFit(uint _rid) public returns (uint256 profit);


    /// @notice 提取所有锁仓记录的释放收益
    /// @return profitTotal : 成功提取的数量总和
    function WithDrawLockRecordAllProfit() public returns (uint256 profitTotal);


    /// @notice 获取指定用户的指定检索号当前可以提取的收益数量
    /// @param  _owner : 查询的用户
    /// @param  _rid : 用户对应锁仓记录的检索号
    /// @return profit : 计算结果
    function GetLockRecordProfit( address _owner, uint _rid ) public view returns (uint256 profit);


    /// @notice 管理员API接口，设置锁仓记录开始释放的时间
    /// @param  _startTime : 设置的时间戳，一般来说设置到某日的0点整较为合适
    function API_SetUnlockAmountEnable( uint256 _startTime ) public;


    /// @notice 管理员API接口，为对应对地址设置锁仓记录
    /// @param _to : 设置锁仓的用户地址
    /// @param _lockAmountTotal : 设置的记录对应的锁定数量
    /// @param _lockDays : 设置提取需要使用的总天数
    function API_SendLockBalanceTo( address _to, uint256 _lockAmountTotal, uint16 _lockDays ) public returns (bool success);
}
