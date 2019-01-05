pragma solidity >=0.5.0 <0.6.0;

import "../../base/abstract/FX2_AbstractDBS.sol";

import "./interface/FX2_Externsion_POS_DBS_Interface.sol";

/// @title  ExtensionModules-Pos-DBS
/// @author Martin.Ren

interface ERC20DecimalsInterface
{
    function decimals() external view returns (uint8);
}

contract FX2_Externsion_POS_DBS is
FX2_AbstractDBS,
FX2_Externsion_POS_Events
{
    /// @notice Copy some variables that are not allowed to be modified
    ///         copy to TokenDBS data.
    uint8 decimals;

    FX2_ERC20TokenDBS_Interface FX2_TKDBS;

    constructor(
        FX2_PermissionCtl_Interface fx2_pcimpl,
        FX2_ModulesManager_Interface fx2_mmimpl,
        FX2_ERC20TokenDBS_Interface fx2_tokendbs
        ) public
    {
        FX2_PermissionCtl_Modifier_LinkIMPL( fx2_pcimpl );
        FX2_ModulesManager_Modifier_LinkIMPL( fx2_mmimpl );
        FX2_TKDBS = fx2_tokendbs;

        decimals = uint8( FX2_TKDBS.GetUintValue("decimals") );

        _uintHashMap["EverDayPosTokenAmount"] = 900000;
        _uintHashMap["MaxRemeberPosRecord"] = 30;
        _uintHashMap["JoinPosMinAmount"] = 10000000000;
        _uintHashMap["WithDrawPosProfitEnable"] = 1;
    }

    /// @notice add instance of pos record into the database object;
    /// @param  _owner : new record owner address.
    /// @param  _amount : Amount sum of number by min decimal. lg. '10 * 10 ** 8' or '10 * 10 ** decimal'.
    function AddPosRecord( address _owner, uint256 _amount )
    public
    ValidModuleAPI
    returns (bool success)
    {
        _db.dbs_pos[_owner].push( CreateNewPosRecord(_amount, now, 0) );

        _db.posAmountTotalSum += _amount;

        return true;
    }

    function UpdataPosRecordLastWithDrawTime( address _owner, uint _rIndex, uint256 newValue )
    public
    ValidModuleAPI
    returns (bool success)
    {
      if ( _rIndex < _db.dbs_pos[_owner].length )
      {
        _db.dbs_pos[_owner][_rIndex].lastWithDrawTime = newValue;
        return true;
      }

      return false;
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
    ValidModuleAPI
    returns (bool success)
    {
        PosRecord[] storage list = _db.dbs_pos[_owner];

        if ( _rIndex >= list.length )
        {

            return false;
        }

        _db.posAmountTotalSum -= list[_rIndex].amount;

        for (uint i = _rIndex; i < list.length - 1; i++)
        {
            list[i] = list[i + 1];
        }

        delete list[ list.length - 1 ];
        list.length --;

        return true;
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
    ValidModuleAPI
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
    ValidModuleAPI
    returns (bool success)
    {
      if ( _db.dbs_out.length >= _db.posOutRecordMaxSize )
      {
        for (uint i = 0; i < _db.dbs_out.length - 1; i++)
        {
          _db.dbs_out[i] = _db.dbs_out[i + 1];
        }

        delete _db.dbs_out[ _db.dbs_out.length - 1 ];
        _db.dbs_out.length --;

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

    // 设定日产出最大值，理论上每年仅调用一次，用于控制逐年递减
    function API_SetEverDayPosMaxAmount(uint256 maxAmount)
    public
    NeedAdminPermission
    {
        SetUintValue("EverDayPosTokenAmount", maxAmount);
    }

    // 增加一个Pos收益记录，理论上每日应该调用一次, time 为时间戳，而实际上是当前block的时间戳
    // 如果time设定为0，则回使用当前block的时间戳
    function API_CreatePosOutRecord()
    public
    NeedAdminPermission
    returns (bool success)
    {
        (
        uint len,
        ,
        ,
        ,
        uint256[] memory posoutTimes
        ) = GetPosoutRecordList();


        // 获取最后一条posout记录的时间，添加之前与当前时间比较，必须超过1 days，才允许添加
        uint256 lastRecordPosoutTimes = 0;
        uint256 time;

        if ( len != 0 )
        {
            // 有数据
            lastRecordPosoutTimes = posoutTimes[len - 1];
        }

        require ( now - lastRecordPosoutTimes >= 1 days, "posout time is not up." );
        require ( GetPosPoolTotalAmount() > 0, "Not anymore amount in the pos pool." );

        // 转换时间到整点 UTC标准时间戳
        time = (now / 1 days) * 1 days;

        uint256 everDayPosN = GetUintValue("EverDayPosTokenAmount") * 10 ** uint256((decimals * 2));
        uint256 profitValue = everDayPosN / (GetPosPoolTotalAmount() / 10 ** uint256(decimals));

        success = PushPosoutRecord(
            everDayPosN,
            decimals * 2,
            profitValue,
            time
            );

        if (success)
        {
          emit OnCreatePosoutRecord(
            everDayPosN,
            decimals * 2,
            profitValue,
            time
            );
        }
    }

    function API_SetEnableWithDrawPosProfit(bool enable)
    public
    NeedAdminPermission
    {
        SetBoolValue("WithDrawPosProfitEnable", enable);
    }

    function API_GetEnableWithDrawPosProfit()
    public
    view
    NeedAdminPermission
    returns (bool enable)
    {
        return GetBoolValue("WithDrawPosProfitEnable");
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

    /////////////////// FX2Framework infomation //////////////////
    string    public FX2_ModulesName = "FX2.Extension.Pos.DBS";

}
