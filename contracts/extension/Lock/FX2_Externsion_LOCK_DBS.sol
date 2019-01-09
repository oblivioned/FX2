pragma solidity >=0.5.0 <0.6.0;

import "./interface/FX2_Externsion_LOCK_DBS_Interface.sol";

/// @title  ExtensionModules-Pos-DBS
/// @author Martin.Ren
contract FX2_Externsion_LOCK_DBS is
FX2_AbstractDBS
{
    using FX2_Externsion_LOCK_DBTABLE for FX2_Externsion_LOCK_DBTABLE.DBTable;

    FX2_Externsion_LOCK_DBTABLE.DBTable LockDBTable;

    constructor(
        FX2_PermissionCtl_Interface fx2_pcimpl,
        FX2_ModulesManager_Interface fx2_mmimpl
        ) public
    {
        FX2_PermissionCtl_Modifier_LinkIMPL( fx2_pcimpl );
        FX2_ModulesManager_Modifier_LinkIMPL( fx2_mmimpl );

        _uintHashMap["UnlockDataTime"] = 0;
    }

    //获取sender的所有锁定余额记录
    function GetLockRecords()
    public
    view
    returns (
      uint len,
      uint256[] memory totalAmounts,
      uint256[] memory drawedAmount,
      uint256[] memory lastdrawTime,
      uint16[]  memory lockDays,
      uint256[] memory createTime
      )
    {
        FX2_Externsion_LOCK_DBTABLE.Record[] memory records = LockDBTable.GetRecordList(msg.sender);

        len = records.length;
        totalAmounts = new uint256[](len);
        drawedAmount = new uint256[](len);
        lastdrawTime = new uint256[](len);
        lockDays = new uint16[](len);
        createTime = new uint256[](len);

        for (uint i = 0; i < len; i++)
        {
          totalAmounts[i] = records[i].totalAmount;
          drawedAmount[i] = records[i].withdrawAmount;
          lastdrawTime[i] = records[i].lastWithdrawTime;
          lockDays[i] = records[i].lockDays;
          createTime[i] = records[i].createTime;
        }
    }

    // 获取用户对应记录当前可以提取的收益数量
    function GetLockRecordProfit( address _owner, uint _rid )
    internal
    view
    returns (uint256 profit)
    {
        FX2_Externsion_LOCK_DBTABLE.Record memory record = LockDBTable.GetRecord(_owner, _rid);

        // 未开始释放，无任何收益，或有需要已经被暂停
        if ( GetUintValue("UnlockDataTime") == 0 )
        {
            return 0;
        }
        else
        {
            // 自释放日起，到当前时间，总共释放经过的时间戳
            uint256 unlockTimes;

            if ( record.createTime > GetUintValue("UnlockDataTime") )
            {
                //记录增加时间在释放开始时间之后，说明记录为ICO轮锁仓
                unlockTimes = now - record.createTime;
            }
            else
            {
                //记录创建时间位于释放时间开始之前，说明该记录为天使轮锁仓
                unlockTimes = now - GetUintValue("UnlockDataTime");
            }

            // 总共释放了多少天
            uint256 unlcokTotalDays = unlockTimes / 1 days;

            // 当前应该获得到总释放量
            uint256 unlockTotalAmount;

            if ( unlcokTotalDays >= record.lockDays )
            {
                // 不能直接使用 ”unlockTotalAmount = record.totalAmount“，某些数值会存在余数。
                unlockTotalAmount = record.lockDays * (record.totalAmount / record.lockDays);
            }
            else
            {
                unlockTotalAmount = unlcokTotalDays * (record.totalAmount / record.lockDays);
            }

            // 减去已经提取到量等于本次可以提取到量
            uint256 profitRet = unlockTotalAmount - record.withdrawAmount;

            // 如果已经是超过最大释放天数，并且锁定量和释放量中有部分余数，则在锁仓天数+1时，提取
            if ( unlcokTotalDays >= record.lockDays && record.totalAmount - (profitRet + record.withdrawAmount) > 0 )
            {
                return profitRet + (record.totalAmount - (profitRet + record.withdrawAmount));
            }

            return profitRet;
        }
    }

    // 设置开始解仓时间
    function API_SetUnlockAmountEnable(uint256 _startTime)
    public
    NeedAdminPermission
    {
        SetUintValue("UnlockDataTime", _startTime);
    }

    // 发放锁仓余额
    function API_SendLockBalanceTo(address _to, uint256 _lockAmountTotal, uint16 _lockDays)
    public
    NeedAdminPermission
    returns (bool success)
    {
        FX2_Externsion_LOCK_DBTABLE.Record memory newRecord = FX2_Externsion_LOCK_DBTABLE.Record( _lockAmountTotal, 0, 0, _lockDays, now );

        if ( LockDBTable.AddRecord(_to, newRecord) )
        {
            return true;
        }

        return false;
    }
}
