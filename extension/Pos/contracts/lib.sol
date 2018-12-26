pragma solidity >=0.4.22 <0.6.0;

library FX2_Externsion_Library_PosSupport {

    struct PosRecord 
    {
        uint256 amount;
        uint256 depositTime;
        uint256 lastWithDrawTime;
    }

    struct PosoutRecord {
        
      uint256 posTotal;
      uint256 posDecimal;
      uint256 posEverCoinAmount;
      uint256 posoutTime;
    }


    struct DB
    {
        mapping (address => PosRecord[]) dbs_pos;
        
        PosoutRecord[] dbs_out;

        // 参与Pos的总数量
        uint256 posAmountTotalSum;
        uint16  posOutRecordMaxSize;
    }

    function AddRecord( DB storage _db, address _owner, PosRecord memory _record )
    internal
    returns (bool success)
    {
        if ( _record.amount <= 0 || _record.lastWithDrawTime > 0 )
        {
        return false;
        }
    
        _db.dbs_pos[_owner].push(_record);

        _db.posAmountTotalSum += _record.amount;

        return true;
    }

    function GetRecordList( DB storage _db, address _owner )
    internal
    constant
    returns ( PosRecord[] list )
    {
        return _db.dbs_pos[_owner];
    }

    function GetRecord(DB storage _db, address _owner, uint _rIndex)
    internal
    constant
    returns ( PosRecord record )
    {
        return _db.dbs_pos[_owner][_rIndex];
    }

    function RemoveRecord(DB storage _db, address _owner, uint _rIndex)
    internal
    returns (bool success)
    {
        PosRecord[] storage list = _db.dbs_pos[_owner];

        if ( _rIndex >= list.length )
        {
            return false;
        }

        PosRecord storage record = list[_rIndex];

        for (uint i = _rIndex; i < list.length - 1; i++)
        {
            list[i] = list[i + 1];
        }

        delete list[list.length --];
        
        _db.posAmountTotalSum -= record.amount;

        return true;
    }

    function GetPosTotalAmount(DB storage _db, address _owner)
    internal
    constant
    returns (uint256 posTotal)
    {
        PosRecord[] storage list = _db.dbs_pos[_owner];

        for (uint i = 0; i < list.length; i++)
        {
            posTotal += list[i].amount;
        }
    }
  
  
    function GetRecordMaxSize(DB storage _db)
    internal
    constant
    returns (uint16 size)
    {
      return _db.posOutRecordMaxSize;
    }

    function PushPosoutRecord(DB storage _db, PosoutRecord memory _record)
    internal
    returns (bool success)
    {
      if ( _db.dbs_out.length >= _db.posOutRecordMaxSize )
      {
        for (uint i = 0; i < _db.dbs_out.length - 1; i++)
        {
          _db.dbs_out[i] = _db.dbs_out[i + 1];
        }

        delete _db.dbs_out[_db.dbs_out.length --];
      }

      _db.dbs_out.push(_record);

      return true;
    }
}
