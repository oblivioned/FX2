pragma solidity >=0.4.22 <0.6.0;

import "../../base/implement/FX2_BaseDBS.sol";
import "../../base/delegate/FX2_Investable_Delegate.sol";
import "../../base/FX2_FrameworkInfo.sol";

/// @title  BalanceDBS
/// @author Martin.Ren
contract FX2_ERC20TokenDBS is FX2_BaseDBS
{
  mapping ( address => uint256 ) _balanceMap;
  mapping ( address => mapping (string => uint256) ) _investmentAmountMap;

  /* I don't want implementation any method to support allowance modules. by martin*/
  /* mapping ( address => uint256 ) _allowance; */
  constructor( address permissionCTL )
  public
  payable
  {
    _uintHashMap["totalSupply"] = 5000000000 * 10 ** 8;
    _uintHashMap["decimals"] = 8;
    _uintHashMap["permineAmount"] = 1500000000 * 10 ** 8;

    _balanceMap[address(this)] = _uintHashMap["totalSupply"] - _uintHashMap["permineAmount"];
    _balanceMap[msg.sender] = _uintHashMap["permineAmount"];

    CTLInterface = FX2_PermissionCtl_Interface(permissionCTL);
  }

  function GetAddressBalance(address owner)
  public
  view
  BetterThanExecuted(DBSContractState.AnyTimes)
  returns (uint256 balance)
  {
    return _balanceMap[owner];
  }

  function InvestmentAmountTo( address _owner, uint256 _investAmount )
  public
  ConstractInterfaceMethod
  BetterThanExecuted(DBSContractState.Healthy)
  returns (uint256 balance)
  {
    string memory investName = FX2_Investable_Delegate(msg.sender).InvestIdentifier();
    // this msg.sender only can be a visiter contract instance and have right permission.
    require( IsExistContractVisiter( msg.sender) && bytes(investName).length > 0 );
    require( _owner != address(0x0) && _investAmount > 0 );
    require( (_balanceMap[_owner] - _investAmount) + _investAmount == _balanceMap[_owner] );

    _balanceMap[msg.sender] += _investAmount;
    _balanceMap[_owner] -= _investAmount;

    _investmentAmountMap[_owner][investName] += _investAmount;

    return _balanceMap[_owner];
  }

  function DivestmentAmountFrom( address _owner, uint256 _divestAmount )
  public
  ConstractInterfaceMethod
  BetterThanExecuted(DBSContractState.Healthy)
  returns (uint256 balance)
  {
    string memory investName = FX2_Investable_Delegate(msg.sender).InvestIdentifier();
    // this msg.sender only can be a visiter contract instance and have right permission.
    require( IsExistContractVisiter( msg.sender) && bytes(investName).length > 0 );
    require( _owner != address(0x0) && _divestAmount > 0 );
    require( _investmentAmountMap[_owner][investName] >= _divestAmount );

    _investmentAmountMap[_owner][investName] -= _divestAmount;

    _balanceMap[msg.sender] -= _divestAmount;
    _balanceMap[_owner] += _divestAmount;

    return _balanceMap[_owner];
  }

  function TransferBalanceFromContract(address _owner, uint256 _addAmount)
  public
  ConstractInterfaceMethod
  BetterThanExecuted(DBSContractState.Sicking)
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
  BetterThanExecuted(DBSContractState.AnyTimes)
  returns (uint256 totalBalance)
  {
    return _balanceMap[address(this)];
  }

  function TransferBalance(address _from, address _to, uint256 _amount)
  public
  ConstractInterfaceMethod
  BetterThanExecuted(DBSContractState.Sicking)
  {
    require ( address(0x0) != _from && _from != _to );
    require ( _amount > 0 && _balanceMap[_from] >= _amount );
    require ( (_balanceMap[_from] - _amount) + _amount == _balanceMap[_from] );
    require ( (_balanceMap[_to] + _amount) - _amount == _balanceMap[_to] );

    _balanceMap[_from] -= _amount;
    _balanceMap[_to] += _amount;
  }

  /////////////////// FX2Framework infomation //////////////////
  string public FX2_VersionInfo = "{'Symbol':'Aya','Ver':'0.0.1 Release 2018-12-28','Modules':'FX2_ERC20TokenDBS'}";
}
