pragma solidity >=0.5.0 <0.6.0;

interface FX2_Externsion_LOCK_IMPL_Interface
{
    /// @notice 提取锁仓记录的释放量
    /// @param  _rid : 记录的检索号
    /// @return profit : 成功提取的数量
    function WithDrawLockRecordProFit(uint _rid) external returns (uint256 profit);

    /// @notice 提取所有锁仓记录的释放收益
    /// @return profitTotal : 成功提取的数量总和
    function WithDrawLockRecordAllProfit() external returns (uint256 profitTotal);
}
