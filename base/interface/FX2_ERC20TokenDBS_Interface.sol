pragma solidity >=0.4.22 <0.6.0;

import "../interface/FX2_BaseDBS_Interface.sol";

/// @title  BalanceDBS
/// @author Martin.Ren
contract FX2_ERC20TokenDBS is FX2_BaseDBS_Interface
{
  uint256 public totalSupply = 5000000000 * 10 ** 8;
  string  public name = "ANT(Coin)";
  uint256 public decimals = 8;
  string  public symbol = "ANT";
  uint256 public perMinerAmount = 1500000000 * 10 ** 8;

  mapping ( address => uint256 ) _balanceMap;
  mapping ( address => mapping (address => uint256) ) _investmentAmountMap;

  /* I don't want implementation any method to support allowance modules. by martin*/
  /* mapping ( address => uint256 ) _allowance; */
  constructor( address perMinerAddress )
  public 
  payable
  {
    _balanceMap[address(this)] = totalSupply - perMinerAmount;
    _balanceMap[perMinerAddress] = perMinerAmount;
  }

  function BalanceOf(address owner)
  public
  view
  BetterThanExecuted(DBSContractState.AnyTimes)
  returns (uint256 balance);

  function InvestmentAmountIntoCalledContract( address _owner, uint256 _investAmount )
  public
  ConstractInterfaceMethod
  BetterThanExecuted(DBSContractState.Healthy)
  returns (uint256 balance);

  function DivestmentAmountFromCalledContract( address _owner, uint256 _divestAmount )
  public
  ConstractInterfaceMethod
  BetterThanExecuted(DBSContractState.Healthy)
  returns (uint256 balance);

  function TransferBalanceFromContract(address _owner, uint256 _addAmount)
  public
  ConstractInterfaceMethod
  BetterThanExecuted(DBSContractState.Serious)
  returns (uint256 balance);

  function GetTokenTotalBalance()
  public
  view
  BetterThanExecuted(DBSContractState.AnyTimes)
  returns (uint256 totalBalance);

  function TransferBalance(address _from, address _to, uint256 _amount)
  public
  ConstractInterfaceMethod
  BetterThanExecuted(DBSContractState.Serious);
}
