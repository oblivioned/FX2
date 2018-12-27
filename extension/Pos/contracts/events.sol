pragma solidity >=0.4.22 <0.6.0;

contract FX2_Externsion_Events_PosSupport
{
    /*********************************************/
    /************** Pos相关事件 *******************/
    /*********************************************/

    /* 系统用户增加了Posout记录时 */
    event OnCreatePosoutRecord
    (
      uint256 posTotal,
      uint256 posDecimal,
      uint256 posEverCoinAmount,
      uint256 posoutTime
    );

    /* 当用户投入可用余额进入Pos池中 */
    event OnCreatePosRecord
    (
      uint256 posAmount
    );

    /* 提取Pos池中投入的记录，提取并且删除记录，返回本金时发起 */
    event OnRescissionPosRecord
    (
      // 记录对应的数额
      uint256 posAmount,
      // 提取时候残留一并读取的收益
      uint256 posProfit,
      /* is send token profix to owner address. */
      bool    sendedPosProfitToken
    );

    /* 提取所有pos记录，提取并且删除记录，返回本金时发起 */
    event OnRescissionPosRecordAll
    (
      uint256 amountSum,
      uint256 profitSum,
      /* is send token profix to owner address. */
      bool    sendedPosProfitToken
    );

    /* 当用户提取Pos记录带来当收益 */
    event OnWithdrawPosRecordPofit
    (
      // pos记录对应的数额
      uint256 amount,
      // pos记录对应的创建时间
      uint256 depositTime,
      // pos记录最后一次提取的时间
      uint256 lastWithDrawTime,
      // 提取的收益数
      uint256 profit,
      /* is send token profix to owner address. */
      bool    sendedPosProfitToken
    );

    /* 一次提取所有pos记录的收益 */
    event OnWithdrawPosRecordPofitAll
    (
      uint256 amountSum,
      uint256 profitSum,
      /* is send token profix to owner address. */
      bool    sendedPosProfitToken
    );
    /*********************************************/
    /************** Pos相关事件 *******************/
    /*********************************************/
}
