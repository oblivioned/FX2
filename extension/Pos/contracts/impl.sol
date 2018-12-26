pragma solidity >=0.4.22 <0.6.0;

import "./lib.sol";
import "./interface.sol";
import "./events.sol";
import "../../../base/interface/ERC20TokenInterface.sol";
import "../../../base/interface/PermissionCtl.sol";

contract FX2_Externsion_IMPL_PosSupport is 
ERC20TokenInterface, 
PermissionCtl,
FX2_Externsion_Interface_PosSupport, 
FX2_Externsion_Events_PosSupport
{
  uint256 public everDayPosTokenAmount = 900000;
  uint16  public maxRemeberPosRecord = 30;
  uint256 public joinPosMinAmount = 10000000000;
  bool enableWithDrawPosProfit = false;

  // 主数据结构存储表
  using FX2_Externsion_Library_PosSupport for FX2_Externsion_Library_PosSupport.DB;
  FX2_Externsion_Library_PosSupport.DB PosDBTable;

  constructor() public payable
  {
    PosDBTable.posOutRecordMaxSize = maxRemeberPosRecord;
  }

  // 将可用余额参与POS
  function DespoitToPos(uint256 amount) public returns (bool success)
  {
    require( fx2_mapping_balances[msg.sender] >= amount && amount >= joinPosMinAmount );

    fx2_mapping_balances[msg.sender] -= amount;

    FX2_Externsion_Library_PosSupport.PosRecord memory newRecord = FX2_Externsion_Library_PosSupport.PosRecord(amount, now, 0);

    success = PosDBTable.AddRecord(msg.sender, newRecord);

    emit FX2_Externsion_Events_PosSupport.OnCreatePosRecord(amount);
  }

  // 获取记录中的Pos收益
  function getPosRecordProfit(address _owner, uint recordId)
  internal
  constant
  returns (uint256 profit, uint256 amount, uint256 lastPosoutTime)
  {
    FX2_Externsion_Library_PosSupport.PosRecord[] storage posRecords = PosDBTable.dbs_pos[_owner];
    FX2_Externsion_Library_PosSupport.PosoutRecord[] storage posoutRecords = PosDBTable.dbs_out;

    amount = posRecords[recordId].amount;

    for ( uint ri = posoutRecords.length; ri > 0; ri-- )
    {
      uint i = ri - 1;

      FX2_Externsion_Library_PosSupport.PosoutRecord storage subrecord = posoutRecords[i];

      // 首次可以提取的时间，为投入时间 + 1 日即 24小时后的当天可以计算收益
      uint256 fristWithdrawTime = posRecords[recordId].depositTime + 1 days;

      if ( ( posRecords[recordId].lastWithDrawTime > fristWithdrawTime ? posRecords[recordId].lastWithDrawTime : fristWithdrawTime  )  < subrecord.posoutTime )
      {
        // 未领取，增加收益
        uint256 subProfit = (posRecords[recordId].amount / (10 ** uint256(decimals))) * subrecord.posEverCoinAmount;

        subProfit /= 10 ** (subrecord.posDecimal - decimals);

        // 如果收益大于 0.003% 则强行计算为 0.003%收益
        if ( subProfit > posRecords[recordId].amount * 3 / 1000 )
        {
          subProfit = posRecords[recordId].amount * 3 / 1000;
        }

        if ( subrecord.posoutTime > lastPosoutTime )
        {
          lastPosoutTime = subrecord.posoutTime;
        }

        profit += subProfit;
      }
    }
  }

  // 获取所有Pos参与记录
  function GetPosRecordCount()
  public
  constant
  returns (uint recordCount)
  {
    return PosDBTable.dbs_pos[msg.sender].length;
  }

  // 获取指定记录的详情
  function GetPosRecordInfo(uint index)
  public
  constant
  returns ( uint256 amount, uint256 depositTime, uint256 lastWithDrawTime, uint prefix )
  {
    FX2_Externsion_Library_PosSupport.PosRecord memory record = PosDBTable.GetRecord(msg.sender, index);

    (uint256 posProfit, uint256 posamount, ) = getPosRecordProfit(msg.sender, index);

    return ( posamount, record.depositTime, record.lastWithDrawTime, posProfit );
  }

  // 提取参与Pos的余额与收益，解除合约
  function RescissionPosAt(uint posRecordIndex)
  public
  returns (uint256 posProfit, uint256 amount, uint256 distantPosoutTime)
  {
    (posProfit, amount, distantPosoutTime) = getPosRecordProfit(msg.sender, posRecordIndex);

    PosDBTable.dbs_pos[msg.sender][posRecordIndex].lastWithDrawTime = distantPosoutTime;

    if ( PosDBTable.RemoveRecord(msg.sender, posRecordIndex) )
    {
      fx2_mapping_balances[msg.sender] += amount;

      if (enableWithDrawPosProfit)
      {
        fx2_mapping_balances[msg.sender] += posProfit;
        fx2_mapping_balances[this] -= posProfit;
      }
    }

    emit FX2_Externsion_Events_PosSupport.OnRescissionPosRecord(
        amount,
        PosDBTable.dbs_pos[msg.sender][posRecordIndex].depositTime,
        PosDBTable.dbs_pos[msg.sender][posRecordIndex].lastWithDrawTime,
        posProfit,
        enableWithDrawPosProfit);
  }

  // 一次性提取所有Pos参与记录的本金和收益
  function RescissionPosAll()
  public
  returns (uint256 amountTotalSum, uint256 profitTotalSum)
  {
    uint recordCount = PosDBTable.dbs_pos[msg.sender].length;

    for (uint i = 0; i < recordCount; i++)
    {
      (uint256 posProfit, uint256 amount, ) = getPosRecordProfit(msg.sender, 0);

      if ( PosDBTable.RemoveRecord(msg.sender, 0) )
      {
        amountTotalSum += amount;
        profitTotalSum += posProfit;

        fx2_mapping_balances[msg.sender] += amount;

        if (enableWithDrawPosProfit)
        {
          fx2_mapping_balances[this] -= posProfit;
          fx2_mapping_balances[msg.sender] += posProfit;
        }
      }
    }

    emit FX2_Externsion_Events_PosSupport.OnRescissionPosRecordAll(amountTotalSum, profitTotalSum, enableWithDrawPosProfit);
  }

  // 获取当前参与Pos的数额总量
  function GetCurrentPosSum()
  public
  constant
  returns (uint256 sum)
  {
    return PosDBTable.posAmountTotalSum;
  }

  // 获取当前所有Posout记录
  function GetPosoutLists()
  public
  constant
  returns (
    uint256[] posouttotal,
    uint256[] profitByCoin,
    uint256[] posoutTime
    )
  {
    uint recordCount = PosDBTable.dbs_out.length;

    posouttotal = new uint256[](recordCount);
    profitByCoin = new uint256[](recordCount);
    posoutTime = new uint256[](recordCount);

    for (uint i = 0; i < recordCount; i++)
    {
      posouttotal[i] = PosDBTable.dbs_out[i].posTotal;
      profitByCoin[i] = PosDBTable.dbs_out[i].posEverCoinAmount;
      posoutTime[i] = PosDBTable.dbs_out[i].posoutTime;
    }
  }

  function GetPosoutRecordCount()
  public
  constant
  returns (uint256 count)
  {
    return PosDBTable.dbs_out.length;
  }

  // 提取指定Pos记录的收益
  function WithDrawPosProfit(uint posRecordIndex)
  public
  returns (uint256 profit, uint256 posAmount)
  {
    uint256 distantPosoutTime;

    (profit, posAmount, distantPosoutTime) = getPosRecordProfit(msg.sender, posRecordIndex);

    PosDBTable.dbs_pos[msg.sender][posRecordIndex].lastWithDrawTime = distantPosoutTime;

    if (enableWithDrawPosProfit)
    {
      fx2_mapping_balances[this] -= profit;
      fx2_mapping_balances[msg.sender] += profit;
    }

    emit FX2_Externsion_Events_PosSupport.OnWithdrawPosRecordPofit(
        posAmount,
        PosDBTable.dbs_pos[msg.sender][posRecordIndex].depositTime,
        distantPosoutTime,
        profit,
        enableWithDrawPosProfit
        );
  }

  // 提取所有Pos记录产生的收益
  function WithDrawPosAllProfit()
  public
  returns (uint256 profitSum, uint256 posAmountSum)
  {
    for (uint ri = 0; ri < PosDBTable.dbs_pos[msg.sender].length; ri++)
    {
      (uint256 posProfit, uint256 amount, uint256 distantPosoutTime) = getPosRecordProfit(msg.sender, ri);

      PosDBTable.dbs_pos[msg.sender][ri].lastWithDrawTime = distantPosoutTime;

      if (enableWithDrawPosProfit)
      {
        fx2_mapping_balances[this] -= posProfit;
        fx2_mapping_balances[msg.sender] += posProfit;
      }

      profitSum += posProfit;
      posAmountSum += amount;

      emit FX2_Externsion_Events_PosSupport.OnWithdrawPosRecordPofitAll(
          posAmountSum,
          profitSum,
          enableWithDrawPosProfit
          );
    }
  }

  // 设定日产出最大值，理论上每年仅调用一次，用于控制逐年递减
  function API_SetEverDayPosMaxAmount(uint256 maxAmount)
  public
  NeedAdminPermission()
  {
    everDayPosTokenAmount = maxAmount;
    PosDBTable.posAmountTotalSum = everDayPosTokenAmount;
  }

  // 增加一个Pos收益记录，理论上每日应该调用一次, time 为时间戳，而实际上是当前block的时间戳
  // 如果time设定为0，则回使用当前block的时间戳
  function API_CreatePosOutRecord()
  public
  NeedManagerPermission()
  returns (bool success)
  {
    // 获取最后一条posout记录的时间，添加之前与当前时间比较，必须超过1 days，才允许添加
    uint256 lastRecordPosoutTimes = 0;
    uint256 time;

    if ( PosDBTable.dbs_out.length != 0 )
    {
      // 有数据
      lastRecordPosoutTimes = PosDBTable.dbs_out[PosDBTable.dbs_out.length - 1].posoutTime;
    }

    require ( now - lastRecordPosoutTimes >= 1 days, "posout time is not up." );
    require ( PosDBTable.posAmountTotalSum > 0, "Not anymore amount in the pos pool." );

    // 转换时间到整点 UTC标准时间戳
    time = (now / 1 days) * 1 days;

    uint256 everDayPosN = everDayPosTokenAmount * 10 ** uint256((decimals * 2));

    FX2_Externsion_Library_PosSupport.PosoutRecord memory newRecord = FX2_Externsion_Library_PosSupport.PosoutRecord(
      everDayPosN,
      decimals * 2,
      everDayPosN / (PosDBTable.posAmountTotalSum / 10 ** uint256(decimals)),
      time
      );

    return PosDBTable.PushPosoutRecord(newRecord);
  }


  // Extern contract interface
  function API_ContractBalanceSendTo(address _to, uint256 _value)
  public
  NeedAdminPermission()
  {
    require( fx2_mapping_balances[this] >= _value && _value > 0);

    fx2_mapping_balances[this] -= _value;
    fx2_mapping_balances[_to] += _value;
  }

  // 防止用户转入以太坊到合约，提供函数，提取合约下所有以太坊到Owner地址
  function API_WithDarwETH(uint256 value)
  public
  NeedSuperPermission()
  {
    msg.sender.transfer(value);
  }

  function API_SetEnableWithDrawPosProfit(bool state)
  public
  NeedSuperPermission()
  {
    enableWithDrawPosProfit = state;
  }

  function API_GetEnableWithDrawPosProfit(bool state)
  public
  constant
  NeedSuperPermission()
  {
    state = enableWithDrawPosProfit;
  }
}