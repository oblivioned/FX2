pragma solidity >=0.4.22 <0.6.0;

contract FX2_PermissionCtl_Interface
{
  
  
  function IsSuperOrAdmin(address _sender) public view returns (bool exist);

  function GetAllPermissionAddress()
  public
  view
  returns (address superAdmin, address[] memory admins, address[] memory managers);

  function RequireSuper(address _sender) public view;

  function RequireAdmin(address _sender) public view;
  
  function RequireManager(address _sender) public view;

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
}
