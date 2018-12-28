pragma solidity >=0.4.22 <0.6.0;

import "../../../base/interface/FX2_BaseDBS_Interface.sol";

contract FX2_Externsion_DBS_PosSupport_Interface is FX2_BaseDBS_Interface
{
    /// @notice add instance of pos record into the database object;
    /// @param  _owner : new record owner address.
    /// @param  _amount : Amount sum of number by min decimal. lg. '10 * 10 ** 8' or '10 * 10 ** decimal'.
    function AddPosRecord( address _owner, uint256 _amount )
    external
    returns (bool success);

    function UpdataPosRecordLastWithDrawTime( address _owner, uint _rIndex, uint256 newValue )
    external
    returns (bool success);

    /// @notice Get a pos record by record index.
    /// @param  _owner : target owner address.
    /// @param  _rIndex : record index.
    function GetPosRecord( address _owner, uint _rIndex )
    external
    view
    returns ( uint256 _amount, uint256 _depositTime, uint256 _lastWithDrawTime );


    /// @notice Remove a exist pos record by target owner address.
    /// @param  _owner : target owner address.
    /// @param  _rIndex : exist pos record index in db.
    function RemovePosRecord( address _owner, uint _rIndex )
    external
    returns (bool success);

    /// @notice Get all pos recoreds with owner address.
    /// @param  _owner : target owner address.
    function GetPosRecordList( address _owner )
    external
    view
    returns (
      uint  len,
      uint256[] memory _amounts,
      uint256[] memory _depositTimes,
      uint256[] memory _lastWithDrawTimes
      );

    function GetPosPoolTotalAmount()
    external
    view
    returns (uint256 totalSum);

    /// @notice Get a target owner address deposit pos pool total amount.
    /// @param  _owner : target owner address.
    function GetPosTotalAmount( address _owner )
    external
    view
    returns (uint256 posTotal);

    /// @notice Modifier posout record save max sizes,but can only add size.
    function SetPosoutRecordMaxSize (uint16 _maxSize)
    external;

    /// @notice Get max record size by posout record in this contract,
    ///         because of the limitation on the total number of records,
    ///         the revenue will disappear if the maximum interval is exceeded.
    ///         You can also adjust the "posOutRecordMaxSize" parameter to save
    ///         more records.
    function GetPosOutRecordMaxSize()
    external
    view
    returns (uint16 size);


    /// @notice Push a new posout record, if the size greater than "posOutRecordMaxSize",
    ///         pop the frist record and push this new record.
    function PushPosoutRecord(
      uint256 _posTotal,
      uint256 _posDecimal,
      uint256 _posEverCoinAmount,
      uint256 _posoutTime
      )
    external
    returns (bool success);
    
    /// @notice Get a posout record detail info by index.
    function GetPosoutRecord(uint _rindex)
    external
    view
    returns ( 
        uint256 posTotal, 
        uint256 posDecimal, 
        uint256 posEverCoinAmount, 
        uint256 posoutTime 
        );
    

    /// @notice Get all posout record detail list.
    function GetPosoutRecordList()
    external
    view
    returns (
      uint  len,
      uint256[] memory posTotals,
      uint256[] memory posDecimals,
      uint256[] memory posEverCoinAmounts,
      uint256[] memory posoutTimes
      );

    // 设定日产出最大值，理论上每年仅调用一次，用于控制逐年递减
    function API_SetEverDayPosMaxAmount(uint256 maxAmount)
    external;

    // 增加一个Pos收益记录，理论上每日应该调用一次, time 为时间戳，而实际上是当前block的时间戳
    // 如果time设定为0，则回使用当前block的时间戳
    function API_CreatePosOutRecord()
    external
    returns (bool success);

    function API_SetEnableWithDrawPosProfit(bool enable)
    external;

    function API_GetEnableWithDrawPosProfit()
    external
    view
    returns (bool enable);


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
}
