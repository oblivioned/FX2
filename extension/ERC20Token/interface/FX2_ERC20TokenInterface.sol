pragma solidity >=0.4.22 <0.6.0;

import "../../../base/interface/FX2_BaseDBS_Interface.sol";

/// @title  BalanceDBS
/// @author Martin.Ren
contract FX2_ERC20TokenInterface is FX2_BaseDBS_Interface
{
  function GetAddressBalance(address owner) external view returns (uint256 balance);
  function InvestmentAmountTo( address _owner, uint256 _investAmount ) external returns (uint256 balance);
  function DivestmentAmountFrom( address _owner, uint256 _divestAmount ) external returns (uint256 balance);
  function TransferBalanceFromContract(address _owner, uint256 _addAmount) external returns (uint256 balance);
  function GetTokenTotalBalance() external view returns (uint256 totalBalance);
  function TransferBalance(address _from, address _to, uint256 _amount) external;
}
