pragma solidity >=0.4.22 <0.6.0;

interface FX2_PermissionCtl_Interface
{
  function IsSuperOrAdmin(address _sender) external view returns (bool exist);
  function GetAllPermissionAddress() external view returns (address superAdmin, address[] memory admins, address[] memory managers);
  function RequireSuper(address _sender) external view;
  function RequireAdmin(address _sender) external view;
  function AddAdmin(address admin) external returns (bool success);
  function RemoveAdmin(address admin) external returns (bool success);
}
