/*
 *
 *《 Flying Feathers 》- Aya ETH Contract Frameworks
 * 版本:0.0.1
 * 作者:Martin.Ren（oblivioned)
 * 最后修改时间:2018-12-30
 * 项目地址:https://github.com/oblivioned/FX2
 *
 */

pragma solidity >=0.5.0 <0.6.0;

/// @notice 合约扩展支持的Interface定义
/// @author Martin.Ren
interface FX2_PermissionCtl_Interface
{
    /// @notice 检测对应的地址是否具备super或者admin权限
    /// @param  _sender : 检测的目标地址
    /// @return 检测结果
    function IsSuperOrAdmin(address _sender) external view returns (bool exist);


    /// @notice 获取所有已经配置的具备权限的用户和权限类型
    /// @return superAdmin : 超级权限，合约部署者，最高权限
    ///         admins     : 其他管理员，具备大部分权限
    function GetAllPermissionAddress() external view returns (address superAdmin, address[] memory admins );


    /// @notice 函数形式校验超级权限，如果校验不通过会使用require断言中断执行。
    function RequireSuper(address _sender) external view;


    /// @notice 函数形式校验管理权限，如果校验不通过会使用require断言中断执行。
    function RequireAdmin(address _sender) external view;


    /// @notice 添加管理权限账户，实现逻辑中限定了只能由超级权限添加
    /// @return 添加的结果
    function AddAdmin(address admin) external returns (bool success);


    /// @notice 移除管理权限账户，实现逻辑中限定了只能由超级权限添加
    /// @return 添加的结果
    function RemoveAdmin(address admin) external returns (bool success);
}
