pragma solidity >=0.4.22 <0.6.0;

import "../../../base/interface/FX2_ERC20TokenDBS_Interface.sol";
import "../../../base/delegate/FX2_Investable_Delegate.sol";
import "./interface.sol";
import "./events.sol";

contract FX2_Externsion_IMPL_PosSupport is
FX2_Externsion_Events_PosSupport,
FX2_Investable_Delegate
{
  constructor(
      FX2_Externsion_DBS_PosSupport_Interface _dbsContractAddress,
      FX2_ERC20TokenDBS_Interface tokenDBSAddress
      )
      public
      payable
  {
    DBS_Pos = FX2_Externsion_DBS_PosSupport_Interface(_dbsContractAddress);
    DBS_Token = FX2_ERC20TokenDBS_Interface(tokenDBSAddress);

    readOnlyTokenDecimals = uint8(DBS_Token.decimals());
  }

  // 将可用余额参与POS
  function DespoitToPos(uint256 amount) public returns (bool success)
  {
    require( DBS_Token.BalanceOf(msg.sender) >= amount && amount >= DBS_Pos.GetUintValue("JoinPosMinAmount") );

    DBS_Token.InvestmentAmountTo(msg.sender, amount);

    if ( success = DBS_Pos.AddPosRecord(msg.sender, amount)  )
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
        uint256 subProfit = (recordAmount / (10 ** readOnlyTokenDecimals)) * posEverCoinAmounts[i];

        subProfit /= 10 ** (posDecimals[i] - readOnlyTokenDecimals);

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
      DBS_Token.DivestmentAmountFrom(msg.sender, amount);

      if ( DBS_Pos.GetBoolValue("WithDrawPosProfitEnable") )
      {
        DBS_Token.TransferBalanceFromContract(msg.sender, posProfit);

        emit FX2_Externsion_Events_PosSupport.OnRescissionPosRecord(
                amount,
                posProfit,
                DBS_Pos.GetBoolValue("WithDrawPosProfitEnable"));
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
        DBS_Token.TransferBalanceFromContract(msg.sender, profit);
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
        DBS_Token.TransferBalanceFromContract(msg.sender, posProfit);
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

  /// @notice Private code
  // implement delegate if not, can't use any abount Investment function.
  function InvestIdentifier() external view returns (string memory identifier)
  {
    return "FX2.Externsion.PosInvest";
  }

  ///
  function StatusDesc() external view returns (string memory desc)
  {
    return "Some desc for this invest..";
  }

  FX2_Externsion_DBS_PosSupport_Interface   DBS_Pos;

  FX2_ERC20TokenDBS_Interface               DBS_Token;

  // token dbs seted decimals.
  uint256 readOnlyTokenDecimals;
}
