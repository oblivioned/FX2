pragma solidity >=0.5.0 <0.6.0;

import "../ERC20Token/interface/FX2_ERC20TokenDBS_Interface.sol";
import "./interface/FX2_Externsion_POS_DBS_Interface.sol";
import "./contracts/FX2_Externsion_POS_Events.sol";

contract FX2_Externsion_POS_IMPL is
FX2_Externsion_POS_Events
{
  // Implements FX2_Investable_Delegate.
  string  public InvestIdentifier = "FX2.Externsion.PosInvest";

  constructor(
      address posSupportDBS,
      address tokenAddressDBS
      )
      public
      payable
  {
    DBS_Pos = FX2_Externsion_POS_DBS_Interface(posSupportDBS);
    DBS_Token = FX2_ERC20TokenDBS_Interface(tokenAddressDBS);

    readOnlyTokenDecimals = uint8(DBS_Token.GetUintValue("decimals"));
  }

  // 将可用余额参与POS
  function DespoitToPos(uint256 amount) public returns (bool success)
  {
    require( DBS_Token.GetAddressBalance(msg.sender) >= amount && amount >= DBS_Pos.GetUintValue("JoinPosMinAmount") );

    DBS_Token.InvestmentAmountTo(msg.sender, amount);

    if ( success = DBS_Pos.AddPosRecord(msg.sender, amount)  )
    {
        emit OnCreatePosRecord(amount);
    }
  }

  // 获取记录中的Pos收益
  function getPosRecordProfit(address _owner, uint recordId)
  internal
  view
  returns (uint256 profit, uint256 amount, uint256 lastPosoutTime)
  {
    FX2_Externsion_POS_DBS_Interface.PosRecord memory pRecord;

    // 获取 Pos记录
    (
      pRecord.amount,
      pRecord.depositTime,
      pRecord.lastWithDrawTime
    ) = DBS_Pos.GetPosRecord(_owner, recordId);

    // 获取 Posout列表
    (
      uint len,
      ,
      uint256[] memory posDecimals,
      uint256[] memory posEverCoinAmounts,
      uint256[] memory posoutTimes
    ) = DBS_Pos.GetPosoutRecordList();

    amount = pRecord.amount;

    for ( uint ri = len; ri > 0; ri-- )
    {
      uint i = ri - 1;

      // 首次可以提取的时间，为投入时间 + 1 日即 24小时后的当天可以计算收益
      uint256 fristWithdrawTime = pRecord.depositTime + 1 days;

      if ( ( pRecord.lastWithDrawTime > fristWithdrawTime ? pRecord.lastWithDrawTime : fristWithdrawTime  )  < posoutTimes[i] )
      {
        // 未领取，增加收益
        uint256 subProfit = (pRecord.amount / (10 ** readOnlyTokenDecimals)) * posEverCoinAmounts[i];

        subProfit /= 10 ** (posDecimals[i] - readOnlyTokenDecimals);

        // 如果收益大于 0.003% 则强行计算为 0.003%收益
        if ( subProfit > pRecord.amount * 3 / 1000 )
        {
          subProfit = pRecord.amount * 3 / 1000;
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
      DBS_Token.DivestmentAmountFrom(msg.sender, amount);

      if ( DBS_Pos.GetBoolValue("WithDrawPosProfitEnable") )
      {
        DBS_Token.TransferBalanceFromContract(msg.sender, posProfit);

        emit OnRescissionPosRecord(
            amount,
            posProfit,
            DBS_Pos.GetBoolValue("WithDrawPosProfitEnable")
            );
      }
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

        DBS_Token.DivestmentAmountFrom(msg.sender, amount);

        if ( DBS_Pos.GetBoolValue("WithDrawPosProfitEnable") )
        {
            DBS_Token.TransferBalanceFromContract(msg.sender, posProfit);
        }
      }
    }

    if ( amountTotalSum > 0 )
    {
      emit OnRescissionPosRecordAll(
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
        DBS_Token.TransferBalanceFromContract(msg.sender, profit);
    }

    emit OnWithdrawPosRecordPofit(
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
        DBS_Token.TransferBalanceFromContract(msg.sender, posProfit);
      }

      profitSum += posProfit;
      posAmountSum += amount;

      emit OnWithdrawPosRecordPofitAll(
          posAmountSum,
          profitSum,
          DBS_Pos.GetBoolValue("WithDrawPosProfitEnable")
          );
    }
  }

  FX2_Externsion_POS_DBS_Interface   DBS_Pos;

  FX2_ERC20TokenDBS_Interface               DBS_Token;

  // token dbs seted decimals.
  uint256 readOnlyTokenDecimals;

  /////////////////// FX2Framework infomation //////////////////
  string    public FX2_ContractVer = "0.0.1 Release 2018-12-30";
  string    public FX2_ModulesName = "FX2.Extension.Pos.IMPL";
  string    public FX2_ExtensionID = "Pos";
}
