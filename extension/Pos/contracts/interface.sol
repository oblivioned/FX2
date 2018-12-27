pragma solidity >=0.4.22 <0.6.0;

import "./dbs.sol";

interface FX2_Externsion_Interface_PosSupport
{
  // 将可用余额参与POS
  function DespoitToPos(uint256 amount) external
  returns (bool success);

  // 获取所有Pos记录
  function GetPosRecordLists() external view
  returns (
    uint len,
    uint256[] memory amounts,
    uint256[] memory depositTimes,
    uint256[] memory lastWithDrawTimes,
    uint256[] memory profixs
    );

  // 提取参与Pos的余额与收益，解除合约
  function RescissionPosAt(uint posRecordIndex) external
  returns (
    uint256 posProfit,
    uint256 amount
    );

  // 一次性提取所有Pos参与记录的本金和收益
  function RescissionPosAll() external
  returns (
    uint256 amountTotalSum,
    uint256 profitTotalSum
    );

  // 获取当前参与Pos的数额总量
  function GetCurrentPosSum() external view
  returns (
    uint256 sum
    );

  // 获取当前所有Posout记录
  function GetPosoutLists() external view
  returns (
      uint  len,
      uint256[] memory posTotals,
      uint256[] memory posDecimals,
      uint256[] memory posEverCoinAmounts,
      uint256[] memory posoutTimes
      );

  function GetPosoutRecordCount() external view
  returns (uint count);

  // 提取指定Pos记录的收益
  function WithDrawPosProfit(uint posRecordIndex) external
  returns (
    uint256 profit,
    uint256 posAmount
    );

  // 提取所有Pos记录产生的收益
  function WithDrawPosAllProfit() external
  returns (
    uint256 profitSum,
    uint256 posAmountSum
    );


  // 设定日产出最大值，理论上每年仅调用一次，用于控制逐年递减
  function API_SetEverDayPosMaxAmount(uint256 maxAmount)
  external;

  // 增加一个Pos收益记录，理论上每日应该调用一次, time 为时间戳，而实际上是当前block的时间戳
  // 如果time设定为0，则回使用当前block的时间戳
  function API_CreatePosOutRecord()
  external
  returns (bool success);


  // Extern contract interface
  function API_ContractBalanceSendTo(address _to, uint256 _value)
  external;

  // 防止用户转入以太坊到合约，提供函数，提取合约下所有以太坊到Owner地址
  function API_WithDarwETH(uint256 value)
  external;

  function API_SetEnableWithDrawPosProfit(bool enable)
  external;

  function API_GetEnableWithDrawPosProfit()
  external view
  returns (bool enable);
}
