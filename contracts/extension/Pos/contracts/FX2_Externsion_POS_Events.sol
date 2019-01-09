pragma solidity >=0.5.0 <0.6.0;

interface FX2_Externsion_POS_Events
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
        uint256 posAmount,
        address sender
    );

    /* 提取Pos池中投入的记录，提取并且删除记录，返回本金时发起 */
    event OnWithdrawalPosProfix
    (
        // 记录对应的数额
        uint256 posAmount,
        // 提取时候残留一并读取的收益
        uint256 posProfit,
        // 是否已经发送代币作为收益
        bool    sendedPosProfitToken,
        // 是否提取了本金
        bool    withdrawalAmount
    );

    /* 提取所有pos记录，提取并且删除记录，返回本金时发起 */
    event OnWithdrawalPosProfixAll
    (
        uint256 amountSum,
        uint256 profitSum,
        // 是否已经发送代币作为收益
        bool    sendedPosProfitToken,
        // 是否提取了本金
        bool    withdrawalAmount

    );

    /*********************************************/
    /************** Pos相关事件 *******************/
    /*********************************************/
}
