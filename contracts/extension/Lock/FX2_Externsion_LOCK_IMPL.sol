pragma solidity >=0.5.0 <0.6.0;

import "./interface/FX2_Externsion_LOCK_IMPL_Interface.sol";

contract FX2_Externsion_LOCK_IMPL_Interface is
FX2_Externsion_LOCK_IMPL_Interface
{
    // 提取锁仓记录的释放量
    function WithDrawLockRecordProFit(uint _rid)
    public
    ValidModuleAPI
    returns (uint256 profit)
    {
        profit = GetLockRecordProfit(msg.sender, _rid);

        FX2_Externsion_LOCK_DBTABLE.Record storage lockRecord = LockDBTable.recordMapping[msg.sender][_rid];

        if ( profit > 0 )
        {
            lockRecord.withdrawAmount += profit;
            lockRecord.lastWithdrawTime = now;
        }
    }

    // 提取所有锁仓记录的释放量
    function WithDrawLockRecordAllProfit()
    public
    ValidModuleAPI
    returns (uint256 profitTotal)
    {
        FX2_Externsion_LOCK_DBTABLE.Record[] storage list = LockDBTable.recordMapping[msg.sender];

        uint lockAmountTotalSum = 0;

        for (uint i = 0; i < list.length; i++)
        {
            uint256 profitRet = GetLockRecordProfit(msg.sender, i);

            lockAmountTotalSum += list[i].totalAmount;

            if ( profitRet > 0 )
            {
                list[i].withdrawAmount += profitRet;
                list[i].lastWithdrawTime = now;

                profitTotal += profitRet;
            }
        }
    }
}
