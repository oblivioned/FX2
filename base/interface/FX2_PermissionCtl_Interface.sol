pragma solidity >=0.4.22 <0.6.0;

import "./FX2_Examination_Interface.sol";

contract FX2_PermissionCtl_Interface is FX2_Examination_Interface
{
  function ChangeContractStateToUpgrading()
  public;
  
  /// @notice override super contract function
  function IsDoctorProgrammer(address addr) 
  internal 
  view 
  returns (bool ret);

  function GetAllVisterConstract()
  public
  view
  returns ( address[] memory contracts );

  function GetAllPermissionAddress()
  public
  view
  returns (address superAdmin, address[] memory admins, address[] memory managers);
  
  function GetSuperOwner()
  public
  view
  returns (address superOwnerAddress);

  function AddManager(address manager)
  public
  returns (bool success);

  function AddAdmin(address admin)
  public
  returns (bool success);

  function RemoveManager(address manager)
  public
  returns (bool success);
  
  
  function RemoveAdmin(address admin)
  public
  returns (bool success);

  function IsExistContractVisiter( address visiter )
  public
  view
  returns (bool exist);

  function AddConstractVisiter( address visiter )
  public
  returns (bool success);
  
}
