pragma solidity >=0.4.22 <0.6.0;

interface FX2_Externsion_POS_IMPL_Interface
{

  
  /// @notice 将可用余额加入Pos池
  /// @param  amount  : 参与的数量
  /// @return success : 投入结果
  function DespoitToPos(uint256 amount) external returns (bool success);


  /// @notice 获取我加入pos池的记录
  /// @return len                 : 返回的数据数量
  /// @return amounts             : 对应的参与pos的数量
  /// @return depositTimes        : 参与的时间
  /// @return lastWithDrawTimes   : 最后提取收益的时间
  /// @return profixs             : 当前时间可以领取的收益
  function GetPosRecordLists( ) external view returns ( uint len, uint256[] memory amounts, uint256[] memory depositTimes, uint256[] memory lastWithDrawTimes, uint256[] memory profixs );


  /// @notice 提取参与Pos的余额与收益，解除合约,本金与收益一并提出
  /// @param  posRecordIndex      : 解约的Pos记录记录号
  /// @return posProfit           : 获得的收益
  /// @return amount              : 提取的本金
  function RescissionPosAt(uint posRecordIndex) external returns ( uint256 posProfit, uint256 amount );


  /// @notice 一次性提取所有Pos参与记录的本金和收益,解除合约,本金与收益一并提出
  /// @return amountTotalSum      : 提出的本金总数
  /// @return profitTotalSum      : 提取的收益总数
  function RescissionPosAll() external returns (uint256 amountTotalSum, uint256 profitTotalSum);


  /// @notice 获取当前所有用户参与Pos的数量总和
  /// @return sum  : 总数量
  function GetCurrentPosSum() external view returns (uint256 sum);


  /// @notice 获取当前存在于合约中的产出记录条数，默认保存最新的30天
  /// @return len                 : 返回的数据数量
  /// @return posTotals           : 日产出数量
  /// @return posDecimals         : 计算时使用的精度
  /// @return posEverCoinAmounts  : 每个最小精度获得的收益，如 decimals = 8 则是 10 ** 8个数量获得的收益
  /// @return posoutTimes         : 计算产出的时间
  function GetPosoutLists() external view returns ( uint  len, uint256[] memory posTotals, uint256[] memory posDecimals, uint256[] memory posEverCoinAmounts, uint256[] memory posoutTimes );

  /// @notice 提取参与Pos的收益，不提取本金
  /// @param  posRecordIndex      : 参与pos的记录号
  /// @return posProfit           : 成功提取的收益数量
  /// @return posAmount           : 对应的记录的本金
  function WithDrawPosProfit(uint posRecordIndex) external returns (uint256 profit, uint256 posAmount);

  /// @notice 提取所有参与Pos的记录的收益，不提取本金
  /// @param  posRecordIndex      : 参与pos的记录号
  /// @return profitSum           : 成功提取的收益总和
  /// @return posAmount           : 对应的记录的本金总和
  function WithDrawPosAllProfit() external returns (uint256 profitSum, uint256 posAmountSum);

}
