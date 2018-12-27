pragma solidity >=0.4.22 <0.6.0;

import "../../../base/modules/interface/FX2_ERC20TokenInterface.sol";
import "../../../base/modules/FX2_PermissionCtl.sol";
import "../../../base/modules/FX2_ERC20TokenDBS.sol";
import "./dbs.sol";
import "./interface.sol";
import "./events.sol";

contract FX2_Externsion_IMPL_PosSupport is
FX2_PermissionCtl,
FX2_Externsion_Interface_PosSupport,
FX2_Externsion_Events_PosSupport
{
  FX2_Externsion_DBS_PosSupport DBS_Pos;
  FX2_ERC20TokenDBS             DBS_Token;

  constructor( address _dbsContractAddress, address tokenDBSAddress ) public payable
  {
    DBS_Pos = FX2_Externsion_DBS_PosSupport(_dbsContractAddress);
    DBS_Token = FX2_ERC20TokenDBS(tokenDBSAddress);
  }

  // 将可用余额参与POS
  function DespoitToPos(uint256 amount) public returns (bool success)
  {
    require( DBS_Token.BalanceOf(msg.sender) >= amount && amount >= DBS_Pos.GetUintValue("JoinPosMinAmount") );

    if ( success = ( DBS_Token.InvestmentAmountIntoCalledContract(msg.sender, amount) && DBS_Pos.AddPosRecord(msg.sender, amount) ) )
    {
        emit FX2_Externsion_Events_PosSupport.OnCreatePosRecord(amount);
    }
  }

  // 获取记录中的Pos收益
  function getPosRecordProfit(address _owner, uint recordId)
  internal
  view
  returns (uint256 profit, uint256 amount, uint256 lastPosoutTime)
  {
    // 获取 Pos记录
    (
      uint256 recordAmount,
      uint256 recordDepositTime,
      uint256 recordLastWithDrawTime
    ) = DBS_Pos.GetPosRecord(_owner, recordId);

    // 获取 Posout列表
    (
      uint len,
      ,
      uint256[] memory posDecimals,
      uint256[] memory posEverCoinAmounts,
      uint256[] memory posoutTimes
    ) = DBS_Pos.GetPosoutRecordList();

    amount = recordAmount;

    for ( uint ri = len; ri > 0; ri-- )
    {
      uint i = ri - 1;

      // 首次可以提取的时间，为投入时间 + 1 日即 24小时后的当天可以计算收益
      uint256 fristWithdrawTime = recordDepositTime + 1 days;

      if ( ( recordLastWithDrawTime > fristWithdrawTime ? recordLastWithDrawTime : fristWithdrawTime  )  < posoutTimes[i] )
      {
        // 未领取，增加收益
        uint256 subProfit = (recordAmount / (10 ** uint256(DBS_Token.decimals))) * posEverCoinAmounts[i];

        subProfit /= 10 ** (posDecimals[i] - DBS_Token.decimals);

        // 如果收益大于 0.003% 则强行计算为 0.003%收益
        if ( subProfit > recordAmount * 3 / 1000 )
        {
          subProfit = recordAmount * 3 / 1000;
        }

        if ( posoutTimes[i] > lastPosoutTime )
        {
          lastPosoutTime = posoutTimes[i];
        }

        profit += subProfit;
      }
    }
  }

  function GetPosRecordLists( )
  public
  view
  returns (
    uint len,
    uint256[] memory amounts,
    uint256[] memory depositTimes,
    uint256[] memory lastWithDrawTimes,
    uint256[] memory profixs
    )
  {
    // 获取记录
    (
      len,
      amounts,
      depositTimes,
      lastWithDrawTimes
    ) = DBS_Pos.GetPosRecordList(msg.sender);

    profixs = new uint256[](len);

    for ( uint i = 0; i < len; i++ )
    {
      (profixs[i],,) = getPosRecordProfit(msg.sender, i);
    }
  }

  // 提取参与Pos的余额与收益，解除合约
  function RescissionPosAt(uint posRecordIndex)
  public
  returns ( uint256 posProfit, uint256 amount )
  {
    uint256 distantPosoutTime;

    (posProfit, amount, distantPosoutTime) = getPosRecordProfit(msg.sender, posRecordIndex);

    require( DBS_Pos.UpdataPosRecordLastWithDrawTime(msg.sender, posRecordIndex, distantPosoutTime) );

    if ( DBS_Pos.RemovePosRecord(msg.sender, posRecordIndex) )
    {
      require ( DBS_Token.DivestmentAmountFromCalledContract(msg.sender, amount), "RescissionPosAt:DivestmentAmount faild." );

      if ( DBS_Pos.GetBoolValue("WithDrawPosProfitEnable") )
      {
        fx2_mapping_balances[msg.sender] += posProfit;
        fx2_mapping_balances[address(this)] -= posProfit;
      }

      emit FX2_Externsion_Events_PosSupport.OnRescissionPosRecord(
        amount,
        posProfit,
        DBS_Pos.GetBoolValue("WithDrawPosProfitEnable"));
    }
  }

  // 一次性提取所有Pos参与记录的本金和收益
  function RescissionPosAll()
  public
  returns (uint256 amountTotalSum, uint256 profitTotalSum)
  {
    // 获取记录
    (
      uint  len,
      ,
      ,
    ) = DBS_Pos.GetPosRecordList(msg.sender);

    for (uint i = 0; i < len; i++)
    {
      (uint256 posProfit, uint256 amount, ) = getPosRecordProfit(msg.sender, 0);

      if ( DBS_Pos.RemovePosRecord(msg.sender, 0) )
      {
        amountTotalSum += amount;
        profitTotalSum += posProfit;

        fx2_mapping_balances[msg.sender] += amount;

        if ( DBS_Pos.GetBoolValue("WithDrawPosProfitEnable") )
        {
          fx2_mapping_balances[address(this)] -= posProfit;
          fx2_mapping_balances[msg.sender] += posProfit;
        }
      }
    }

    if ( amountTotalSum > 0 )
    {
      emit FX2_Externsion_Events_PosSupport.OnRescissionPosRecordAll(
        amountTotalSum, profitTotalSum,
        DBS_Pos.GetBoolValue("WithDrawPosProfitEnable")
        );
    }

  }

  // 获取当前参与Pos的数额总量
  function GetCurrentPosSum()
  public
  view
  returns (uint256 sum)
  {
    return DBS_Pos.GetPosPoolTotalAmount();
  }

  // 获取当前所有Posout记录
  function GetPosoutLists()
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
    return DBS_Pos.GetPosoutRecordList();
  }

  function GetPosoutRecordCount()
  public
  view
  returns (uint count)
  {
    (count,,,,) = DBS_Pos.GetPosoutRecordList();
  }

  // 提取指定Pos记录的收益
  function WithDrawPosProfit(uint posRecordIndex)
  public
  returns (uint256 profit, uint256 posAmount)
  {
    uint256 distantPosoutTime;

    (, uint256 _depositTime, ) = DBS_Pos.GetPosRecord( msg.sender, posRecordIndex );

    (profit, posAmount, distantPosoutTime) = getPosRecordProfit(msg.sender, posRecordIndex);

    require( profit > 0, "not anymore profit in the pos pool in this time." );
    require( DBS_Pos.UpdataPosRecordLastWithDrawTime(msg.sender, posRecordIndex, distantPosoutTime) );

    if ( DBS_Pos.GetBoolValue("WithDrawPosProfitEnable") )
    {
      fx2_mapping_balances[address(this)] -= profit;
      fx2_mapping_balances[msg.sender] += profit;
    }

    emit FX2_Externsion_Events_PosSupport.OnWithdrawPosRecordPofit(
        posAmount,
        _depositTime,
        distantPosoutTime,
        profit,
        DBS_Pos.GetBoolValue("WithDrawPosProfitEnable")
        );
  }

  // 提取所有Pos记录产生的收益
  function WithDrawPosAllProfit()
  public
  returns (uint256 profitSum, uint256 posAmountSum)
  {
    (
      uint  len,
      ,
      ,
    ) = DBS_Pos.GetPosRecordList(msg.sender);

    for (uint ri = 0; ri < len; ri++)
    {
      (uint256 posProfit, uint256 amount, uint256 distantPosoutTime) = getPosRecordProfit(msg.sender, ri);

      require( DBS_Pos.UpdataPosRecordLastWithDrawTime(msg.sender, ri, distantPosoutTime) );

      if ( DBS_Pos.GetBoolValue("WithDrawPosProfitEnable") )
      {
        fx2_mapping_balances[address(this)] -= posProfit;
        fx2_mapping_balances[msg.sender] += posProfit;
      }

      profitSum += posProfit;
      posAmountSum += amount;

      emit FX2_Externsion_Events_PosSupport.OnWithdrawPosRecordPofitAll(
        posAmountSum,
        profitSum,
        DBS_Pos.GetBoolValue("WithDrawPosProfitEnable")
        );
    }
  }

  // 设定日产出最大值，理论上每年仅调用一次，用于控制逐年递减
  function API_SetEverDayPosMaxAmount(uint256 maxAmount)
  public
  NeedAdminPermission()
  {
    DBS_Pos.SetUintValue("EverDayPosTokenAmount", maxAmount);
  }

  // 增加一个Pos收益记录，理论上每日应该调用一次, time 为时间戳，而实际上是当前block的时间戳
  // 如果time设定为0，则回使用当前block的时间戳
  function API_CreatePosOutRecord()
  public
  NeedManagerPermission()
  returns (bool success)
  {

    (
      uint len,
      ,
      ,
      ,
      uint256[] memory posoutTimes
    ) = DBS_Pos.GetPosoutRecordList();


    // 获取最后一条posout记录的时间，添加之前与当前时间比较，必须超过1 days，才允许添加
    uint256 lastRecordPosoutTimes = 0;
    uint256 time;

    if ( len != 0 )
    {
      // 有数据
      lastRecordPosoutTimes = posoutTimes[len - 1];
    }

    require ( now - lastRecordPosoutTimes >= 1 days, "posout time is not up." );
    require ( DBS_Pos.GetPosPoolTotalAmount() > 0, "Not anymore amount in the pos pool." );

    // 转换时间到整点 UTC标准时间戳
    time = (now / 1 days) * 1 days;

    uint256 everDayPosN =  DBS_Pos.GetUintValue("EverDayPosTokenAmount") * 10 ** uint256((decimals * 2));
    uint256 profitValue = everDayPosN / (DBS_Pos.GetPosPoolTotalAmount() / 10 ** uint256(decimals));

    success = DBS_Pos.PushPosoutRecord(
      everDayPosN,
      decimals * 2,
      profitValue,
      time
      );

    if (success)
    {
      emit FX2_Externsion_Events_PosSupport.OnCreatePosoutRecord(
        everDayPosN,
        decimals * 2,
        profitValue,
        time
        );
    }
  }


  // Extern contract interface.
  function API_ContractBalanceSendTo(address _to, uint256 _value)
  public
  NeedAdminPermission()
  {
    require( fx2_mapping_balances[address(this)] >= _value && _value > 0);

    fx2_mapping_balances[address(this)] -= _value;
    fx2_mapping_balances[_to] += _value;
  }

  // 防止用户转入以太坊到合约，提供函数，提取合约下所有以太坊到Owner地址.
  function API_WithDarwETH(uint256 value)
  public
  NeedSuperPermission()
  {
    msg.sender.transfer(value);
  }

  function API_SetEnableWithDrawPosProfit(bool enable)
  public
  NeedSuperPermission()
  {
    DBS_Pos.SetBoolValue("WithDrawPosProfitEnable", enable);
  }

  function API_GetEnableWithDrawPosProfit()
  public
  view
  NeedSuperPermission()
  returns (bool enable)
  {
    return DBS_Pos.GetBoolValue("WithDrawPosProfitEnable");
  }
}
