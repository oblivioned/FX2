/*
 *
 *《 Flying Feathers 》- Aya ETH Contract Frameworks
 * 版本:0.0.1
 * 作者:Martin.Ren（oblivioned)
 * 最后修改时间:2018-12-30
 * 项目地址:https://github.com/oblivioned/FX2
 *
 */

pragma solidity >=0.4.22 <0.6.0;

import "../FX2_FrameworkInfo.sol";

/// @title  监督者工作模式支持
/// @notice 原因:"设置监督者"可以解决一些信任问题，由于本质上对于插座合约对权限控制是授权
///         一个地址就行数据读写，如果增加对地址是一个恶意的合约就行修改自己的余额，如果
///         使用监视者对添加权限对地址就行“审查”与审批，则可以解决此问题。
///         举例:
///               作为技术公司获取了Super权限，因为部署工作一般由公司技术人员就行，Super
///             权限并不能保证一定不在技术人员手中，但是作为技术人员需要使用super权限作
///             为一些必要对维护工作。
///               但是若不限制Super权限，会导致一个情况，比如技术人员使用Super权限编写
///             一个自定义对FX2插件，功能是修改自己指定地址下的余额，由于是Super权限
///             合约会接入这个插件，接入以后以为着开放了读写权限。这样做一定是不好的。虽然
///             技术人员不一定会这样做，但是“委托方”，没有理由相信。
///               若此时启动监视者模式控制合约插件的增加与迁移，则从插座合约的层面直接限制
///             了新合约的增加，在就行必要的添加时候，委托方可以拜托任何三方技术人员审核
///             新的插件合约，以避免恶意合约的添加。
///               并且被添加的“插件”没有提供任何一种方式去移除插件，也就是说，一但添加了
///             就只能通过迁移但方式更新合约，不能删除插件合约。势必会留下痕迹。
///         举例2:
///               部分较大交易平台会静止存在“人工操作”的合约就行发布，若你机遇FX2实现
///             的合约虽然插座合约的本意是预留一个扩展插座合约的方法，但是存在
///             “技术提供者”的操作。此时你可以选择让交易平台提供一个地址，添加为“监督者”
///             已解决信任问题。
/// @author Martin.Ren
contract FX2_Surveillant_Interface is FX2_FrameworkInfo
{

  /// @notice 审批事件定义
  struct ReviewEvent
  {
    /// 申请人
    address sender;
    /// 已经部署的插件合约地址
    address implAddress;
    /// 插件模块名称
    string  modulesName;
    /// 事件名：目前暂时支持 AddModules, MigrateModules两种
    string  evnetCode;
  }

  /// @notice 审批事件发生被审批时
  event OnReviewNotifaction( address reviewAddress, string reviewDesc ) ;

  /// @notice 限制仅有监督者可以调用的函数修改器
  modifier ServerllantOnly
  {
    require (msg.sender == Surveillanter);
    _;
  }

  /// @notice 设置“监督者”，方法只能调用一次，设置一个监督者后，对合约就行扩展则需要审批
  ///         若不设置监督者，则合约视为无监视者的模式，增加，迁移，起停插件可以由权限高于
  ///         或者等于Admin的地址就行操作。为了更好的区分权限，监督者值允许使用Super权限
  ///         设置一次，之后不允许再次修改，如果“监督者”私钥丢失，将无法在对此插座合约就行
  ///         “新增”，“迁移”工作，（起停插件不受监督者限制）。
  ///         原因:"设置监督者"可以解决一些信任问题，由于本质上对于插座合约对权限控制是授权
  ///         一个地址就行数据读写，如果增加对地址是一个恶意的合约就行修改自己的余额，如果
  ///         使用监视者对添加权限对地址就行“审查”与审批，则可以解决此问题。
  function SetSurveillanter(address addr) external;


  /// @notice “监督者”审批提交的事件，目前支持两种事件，只有在设置了“监督者”并且交易发送人
  ///         为”监督者“的地址才可以执行。
  ///         AddModules : 申请添加插件模块
  ///         MigrateModules : 申请迁移某个已接入存在的插件模块
  /// @param passAddress : 插件合约地址
  function PassReviewEvent(address passAddress) external;


  /// @notice “监督者”拒绝提交的事件，目前支持两种事件，只有在设置了“监督者”并且交易发送人
  ///         为”监督者“的地址才可以执行。
  ///         AddModules : 申请添加插件模块
  ///         MigrateModules : 申请迁移某个已接入存在的插件模块
  /// @param rejectAddress : 插件合约地址
  function RejectReviewEvent(address rejectAddress) external;


  /*——————————————————————————————————————————————————————————————*/
  /*                         Stroage 变量定义                      */
  /*——————————————————————————————————————————————————————————————*/
  /// @notice 监视者地址
  address public Surveillanter;
  ReviewEvent[] reviewEvents;

  /*——————————————————————————————————————————————————————————————*/
  /*                          FX2 模块信息                         */
  /*——————————————————————————————————————————————————————————————*/
  string public FX2_ModulesName = "FX2.Surveillant";
}
