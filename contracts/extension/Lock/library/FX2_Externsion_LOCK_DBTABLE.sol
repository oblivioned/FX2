pragma solidity >=0.5.0 <0.6.0;

library FX2_Externsion_LOCK_DBTABLE
{
  // 锁仓记录
  struct Record
  {
    // 锁定的总量
    uint256 totalAmount;

    // 已经提取的总量
    uint256 withdrawAmount;

    // 上一次提取的时间
    uint256 lastWithdrawTime;

    // 锁定天数
    uint16 lockDays;

    // 记录创建时间
    uint256 createTime;
  }

  struct DBTable
  {
    mapping (address => Record[]) recordMapping;
  }

  function AddRecord(DBTable storage _db, address _owner, Record memory record)
  internal
  returns (bool success)
  {
    if ( !(record.totalAmount > 0 && record.withdrawAmount == 0 && record.lockDays > 0 && record.createTime > 0 ) )
    {
      return false;
    }

    Record[] storage list = _db.recordMapping[_owner];

    list.push(record);

    return true;
  }

  function GetRecordList(DBTable storage _db, address _owner)
  internal
  view
  returns (Record[] memory list)
  {
    return _db.recordMapping[_owner];
  }

  function GetRecord(DBTable storage _db, address _owner, uint index)
  internal
  view
  returns (Record memory record)
  {
    return _db.recordMapping[_owner][index];
  }

  function RemoveRecord(DBTable storage _db, address _owner, uint index)
  internal
  returns (bool success)
  {
    Record[] storage list = _db.recordMapping[_owner];

    require(index > 0 && index < list.length);

    for (uint i = index; i < list.length - 1; i++)
    {
      list[i] = list[i + 1];
    }

    delete list[list.length - 1];
    list.length --;

    return true;
  }

  function GetTotalAmount(DBTable storage _db, address _owner)
  internal
  view
  returns (uint256 posTotal)
  {
    Record[] storage list = _db.recordMapping[_owner];

    uint256 ret = 0;

    for (uint i = 0; i < list.length; i++)
    {
      Record storage record = list[i];

      ret += record.totalAmount;
    }

    return ret;
  }
}
