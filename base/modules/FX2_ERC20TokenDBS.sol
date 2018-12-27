pragma solidity >=0.4.22 <0.6.0;

import "./FX2_BaseDBS.sol";

/// @title  BalanceDBS
/// @author Martin.Ren
contract FX2_ERC20TokenDBS is FX2_BaseDBS
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
    public payable
  {
    _balanceMap[address(this)] = totalSupply - perMinerAmount;
    _balanceMap[perMinerAddress] = perMinerAmount;
  }

  function BalanceOf(address owner)
  public
  view
  returns (uint256 balance)
  {
    return _balanceMap[owner];
  }

  function InvestmentAmountIntoCalledContract( address _owner, uint256 _investAmount )
  public
  ConstractInterfaceMethod
  returns (uint256 balance)
  {
    // this msg.sender only can be a visiter contract instance and have right permission.
    require( IsExistContractVisiter(msg.sender), "InvestmentAmountIntoMyself:msg.sender does not have access to this function." );
    require( _owner != address(0x0) && _investAmount > 0 );
    require( (_balanceMap[_owner] - _investAmount) + _investAmount == _balanceMap[_owner] );

    _balanceMap[msg.sender] += _investAmount;
    _balanceMap[_owner] -= _investAmount;
    _investmentAmountMap[_owner][msg.sender] += _investAmount;

    return _balanceMap[_owner];
  }

  function DivestmentAmountFromCalledContract( address _owner, uint256 _divestAmount )
  public
  ConstractInterfaceMethod
  returns (uint256 balance)
  {
    require( IsExistContractVisiter(msg.sender), "DivestmentAmountFromCalledContract : msg.sender does not have access to this function." );
    require( _owner != address(0x0) && _divestAmount > 0 );
    require( _investmentAmountMap[_owner][msg.sender] >= _divestAmount, "DivestmentAmountFromCalledContract : The number of evacuations is insufficient." );

    _investmentAmountMap[_owner][msg.sender] -= _divestAmount;
    _balanceMap[msg.sender] -= _divestAmount;
    _balanceMap[_owner] += _divestAmount;

    return _balanceMap[_owner];
  }

  function TransferBalanceFromContract(address _owner, uint256 _addAmount)
  public
  ConstractInterfaceMethod
  returns (uint256 balance)
  {
    require( _owner != address(0x0) && _addAmount > 0 );
    require( (_balanceMap[_owner] + _addAmount) - _addAmount == _balanceMap[_owner] );

    _balanceMap[address(this)] -= _addAmount;
    return _balanceMap[_owner] += _addAmount;
  }

  function GetTokenTotalBalance()
  public
  view
  returns (uint256 totalBalance)
  {
    return _balanceMap[address(this)];
  }

  function TransferBalance(address _from, address _to, uint256 _amount)
  public
  ConstractInterfaceMethod
  {
    require ( address(0x0) != _from && _from != address(this) );
    require ( _amount > 0 && _balanceMap[_from] >= _amount );
    require ( (_balanceMap[_from] - _amount) + _amount == _balanceMap[_from] );
    require ( (_balanceMap[_to] + _amount) - _amount == _balanceMap[_to] );

    _balanceMap[_from] -= _amount;
    _balanceMap[_to] += _amount;
  }
}
