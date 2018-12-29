pragma solidity >=0.4.22 <0.6.0;

/// @title  BalanceDBS
/// @author Martin.Ren

interface FX2_Investable_Delegate
{
  function InvestIdentifier() external view returns (string memory identifier);
  function ProfitPoolTotal() external view returns (uint256 totalAmount);
}
