pragma solidity >=0.4.22 <0.6.0;

import "../../../base/modules/FX2_BaseDBS.sol";

/// @title  ExtensionModules-Pos-DBS
/// @author Martin.Ren
contract FX2_Externsion_DBS_PosSupport is FX2_BaseDBS
{
    constructor() public payable
    {
        SetUintValue("EverDayPosTokenAmount", 900000);
        SetUintValue("MaxRemeberPosRecord", 30);
        SetUintValue("JoinPosMinAmount", 10000000000);
        SetBoolValue("WithDrawPosProfitEnable", false);
    }

    /// @notice add instance of pos record into the database object;
    /// @param  _owner : new record owner address.
    /// @param  _amount : Amount sum of number by min decimal. lg. '10 * 10 ** 8' or '10 * 10 ** decimal'.
    function AddPosRecord( address _owner, uint256 _amount )
    public
    ConstractInterfaceMethod
    returns (bool success)
    {
        _db.dbs_pos[_owner].push( CreateNewPosRecord(_amount, now, 0) );

        _db.posAmountTotalSum += _amount;

        return true;
    }

    function UpdataPosRecordLastWithDrawTime( address _owner, uint _rIndex, uint256 newValue )
    public
    ConstractInterfaceMethod
    returns (bool success)
    {
      if ( _rIndex < _db.dbs_pos[_owner].length )
      {
        _db.dbs_pos[_owner][_rIndex].lastWithDrawTime = newValue;
        return true;
      }

      return false;
    }


    /// @notice Get all pos recoreds with owner address.
    /// @param  _owner : target owner address.
    function GetPosRecordList( address _owner )
    public
    view
    returns (
      uint  len,
      uint256[] memory _amounts,
      uint256[] memory _depositTimes,
      uint256[] memory _lastWithDrawTimes
      )
    {
        len = _db.dbs_pos[_owner].length;

        _amounts = new uint256[](len);
        _depositTimes = new uint256[](len);
        _lastWithDrawTimes = new uint256[](len);

        for (uint i = 0; i < len; i++)
        {
            _amounts[i] = _db.dbs_pos[_owner][i].amount;
            _depositTimes[i] = ( _db.dbs_pos[_owner][i].depositTime );
            _lastWithDrawTimes[i] = ( _db.dbs_pos[_owner][i].lastWithDrawTime );
        }
    }


    /// @notice Get a pos record by record index.
    /// @param  _owner : target owner address.
    /// @param  _rIndex : record index.
    function GetPosRecord( address _owner, uint _rIndex )
    public
    view
    returns ( uint256 _amount, uint256 _depositTime, uint256 _lastWithDrawTime )
    {
        PosRecord storage record = _db.dbs_pos[_owner][_rIndex];

        return (record.amount, record.depositTime, record.lastWithDrawTime);
    }


    /// @notice Remove a exist pos record by target owner address.
    /// @param  _owner : target owner address.
    /// @param  _rIndex : exist pos record index in db.
    function RemovePosRecord( address _owner, uint _rIndex )
    public
    ConstractInterfaceMethod
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

    function GetPosPoolTotalAmount()
    public
    view
    returns (uint256 totalSum)
    {
      return _db.posAmountTotalSum;
    }

    /// @notice Get a target owner address deposit pos pool total amount.
    /// @param  _owner : target owner address.
    function GetPosTotalAmount( address _owner )
    public
    view
    returns (uint256 posTotal)
    {
        PosRecord[] storage list = _db.dbs_pos[_owner];

        for (uint i = 0; i < list.length; i++)
        {
            posTotal += list[i].amount;
        }
    }

    /// @notice Modifier posout record save max sizes,but can only add size.
    function SetPosoutRecordMaxSize (uint16 _maxSize)
    public
    ConstractInterfaceMethod
    {
        require( _db.posOutRecordMaxSize < _maxSize, "PosOutRecordMaxSize allows only additional records, not fewer" );

        _db.posOutRecordMaxSize = _maxSize;
    }

    /// @notice Get max record size by posout record in this contract,
    ///         because of the limitation on the total number of records,
    ///         the revenue will disappear if the maximum interval is exceeded.
    ///         You can also adjust the "posOutRecordMaxSize" parameter to save
    ///         more records.
    function GetPosOutRecordMaxSize()
    public
    view
    returns (uint16 size)
    {
      return _db.posOutRecordMaxSize;
    }


    /// @notice Push a new posout record, if the size greater than "posOutRecordMaxSize",
    ///         pop the frist record and push this new record.
    function PushPosoutRecord(
      uint256 _posTotal,
      uint256 _posDecimal,
      uint256 _posEverCoinAmount,
      uint256 _posoutTime
      )
    public
    ConstractInterfaceMethod
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

      PosoutRecord memory _record = CreateNewPosoutRecord( _posTotal, _posDecimal, _posEverCoinAmount, _posoutTime );
      _db.dbs_out.push(_record);

      return true;
    }


    /// @notice Get a posout record detail info by index.
    function GetPosoutRecord(uint _rindex)
    public
    view
    returns ( uint256 posTotal, uint256 posDecimal, uint256 posEverCoinAmount, uint256 posoutTime )
    {
        PosoutRecord storage record = _db.dbs_out[_rindex];

        return (record.posTotal, record.posDecimal, record.posEverCoinAmount, record.posoutTime);
    }

    /// @notice Get all posout record detail list.
    function GetPosoutRecordList()
    public
    view
    returns (
      uint  len,
      uint256[] memory posTotals,
      uint256[] memory posDecimals,
      uint256[] memory posEverCoinAmounts,
      uint256[] memory posoutTimes
      )
    {
        len = _db.dbs_out.length;

        posTotals = new uint256[](len);
        posDecimals = new uint256[](len);
        posEverCoinAmounts = new uint256[](len);
        posoutTimes = new uint256[](len);

        for ( uint i = 0; i < len; i++ )
        {
            PosoutRecord storage record = _db.dbs_out[i];

            posTotals[i] = record.posTotal;
            posDecimals[i] = record.posDecimal;
            posEverCoinAmounts[i] = record.posEverCoinAmount;
            posoutTimes[i] = record.posoutTime;
        }
    }


    //////////////////////
    /// Private method ///
    //////////////////////
    function CreateNewPosRecord( uint256 amount, uint256 depositTime, uint256 lastWithDrawTime )
    internal
    pure
    returns (PosRecord memory _record)
    {
        _record.amount = amount;
        _record.depositTime = depositTime;
        _record.lastWithDrawTime = lastWithDrawTime;
    }


    function CreateNewPosoutRecord( uint256 posTotal, uint256 posDecimal, uint256 posEverCoinAmount, uint256 posoutTime )
    internal
    pure
    returns ( PosoutRecord memory _record )
    {
        _record.posTotal = posTotal;
        _record.posDecimal = posDecimal;
        _record.posEverCoinAmount = posEverCoinAmount;
        _record.posoutTime = posoutTime;
    }

    struct PosRecord
    {
        uint256 amount;
        uint256 depositTime;
        uint256 lastWithDrawTime;
    }

    struct PosoutRecord
    {
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

    DB _db;
}
