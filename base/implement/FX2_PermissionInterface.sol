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

import "../interface/FX2_PermissionCtl_Interface.sol";
import "../FX2_FrameworkInfo.sol";
import "../interface/FX2_Surveillant_Interface.sol";
import "../interface/FX2_ModulesManager_Interface.sol";

/// @notice FX2 关键权限合约，实现权限管理，合约状态管理等功能，作为DBS的主要权限控制合约
/// @author Martin.Ren
contract FX2_PermissionInterface is
FX2_FrameworkInfo,
FX2_Surveillant_Interface,
FX2_ModulesManager_Interface
{
    enum DBSContractState
    {
        /// @notice 健康：即未发现任何错误，正在正常运行的状态
        Healthy,

        /// @notice 生病：发现了部分小错误，但是并不影响大部分功能的运行
        Sicking,

        /// @notice 严重错误：发生了严重的错误，比如实现存入的Token提出时候发现余额不存在等，
        ///         严重问题。
        Error,

        /// @notice 禁用：禁用状态
        Disable,

        /// @notice 已经迁移：合约已经迁移，当前合约已经作为一个废弃合约，此处FX2并不推荐讲
        ///         合约就行释放，而是通过此状态限制功能，比如仍然可以取出投入的余额，但不能
        ///         在继续投入和计算任何收益。
        Migrated,

        /// @notice 定义一个任何时间都可以进入但状态，即不受健康状态检查的限制，比如 pure
        ///         view constant的函数。
        AnyTimes
    }

    DBSContractState public ContractState;
    address public PlugBaseTarget;

    /// @notice 健康状态发生改变时候,如断言检测失败，或者由管理员，或者有权限操作的合约就行了
    ///         当前合约状态的改变。
    /// @return  blockNumbe  : 状态改变时，当前的区块高度（块号）
    /// @return  txdata      : 导致状态改变的原始交易数据
    /// @return  origin      : 当前合约改变前的状态
    /// @return  current     : 当前合约当前状态
    event OnExaminationStateChanged(
        uint256 blockNumber,
        bytes txdata,
        DBSContractState origin,
        DBSContractState current,
        string msg
        );

    /// @notice 当前合约发生fallback()
    /// @return  blockNumbe  : 状态改变时，当前的区块高度（块号）
    /// @return  txdata      : 导致状态改变的原始交易数据
    /// @return  state       : 当前合约当前状态
    event OnException(
        uint256 blockNumber,
        bytes txdata,
        DBSContractState state
        );

    /// @notice 此函数修改器可以增加在任何支持FX2_PermissionInterface的合约函数内，配合
    ///         提供的断言函数，切换合约状态，该修改器定义为，情况比state更加好转的情况下可
    ///         以执行例如，BetterThanExecuted(DBSContractState.Sicking)那么在合约
    ///         状态为Sicking和Healthy时候可以执行。
    /// @param  _betterThanState  : 最差可以继续执行的状态
    modifier BetterThanExecuted( DBSContractState _betterThanState )
    {
        if ( _betterThanState == DBSContractState.AnyTimes )
        {
            _;
            return ;
        }

        if ( IsDoctorProgrammer(msg.sender) )
        {
            _;
            return ;
        }

        require(ContractState != DBSContractState.Disable, "The contract is being Disable.");
        require(ContractState != DBSContractState.Migrated, "The contract has been discarded and moved to the new contract.");
        require( uint8(ContractState) <= uint8(_betterThanState), "Failure of health examination." );
        _;
    }

    /// @notice 健康检查断言函数，用于代替普通的require断言，如果断言结果为 false，则发送
    ///         指定的消息，并且将合约设置到指定的状态
    /// @param _ret : 断言结果
    /// @param _msg : 如果断言结果为flase，require的消息.
    /// @param _ifFaildSetState : 若断言结果为false，讲合约的状态设置到的目标状态
    function RequireInPayableFunc(bool _ret, string memory _msg, DBSContractState _ifFaildSetState)
    internal
    {
        require( uint8(_ifFaildSetState) <= uint8(DBSContractState.Error), "You can't set the greater then state of error." );

        if ( !_ret && uint8(ContractState) < uint8(_ifFaildSetState) )
        {
            emit OnExaminationStateChanged(
                block.number,
                msg.data,
                ContractState,
                _ifFaildSetState,
                _msg
            );

            ContractState = _ifFaildSetState;
        }

        require(_ret, _msg);
    }

    function () external
    {
        emit OnException(block.number, msg.data, ContractState);
    }

    /// @notice 合约接口定义函数，包含权限检测，如果用此修改器定义一个派生合约的函数，那么如
    ///         果该函数只会允许具备权限的合约就行调用。
    modifier ConstractInterfaceMethod()
    {
        require( IsExistContractVisiter(msg.sender) );
        _;
    }

    /// @notice 调用外部权限CTL检测超级权限，主要用于限制当前合约的一些关键API的调用权限。
    modifier NeedSuperPermission()
    {
        CTLInterface.RequireSuper(msg.sender);
        _;
    }

    /// @notice 调用外部权限CTL检测管理员权限，主要用于限制当前合约的一些关键API的调用权限。
    modifier NeedAdminPermission()
    {
        CTLInterface.RequireAdmin(msg.sender);
        _;
    }

    /// @notice 合约处于外界不可调用的状态时候，比如Disable,Migrated原来具有管理员权限的
    ///         用户继续通行，即在链上保留一个可以调试的接口，用于debug。
    function IsDoctorProgrammer( address addr )
    internal
    view
    returns (bool ret)
    {
        return CTLInterface.IsSuperOrAdmin( addr );
    }

    /// @notice ConstractInterfaceMethod 函数修改器的实现函数，检测指定的地址是否是有权
    ///         限访问的模块地址
    function IsExistContractVisiter( address visiter )
    public
    view
    returns (bool exist)
    {
        for (uint i = 0; i < modulesIMPLs.length; i++ )
        {
            if ( modulesIMPLs[i].FX2_ContractAddr == visiter )
            {
                return true;
            }
        }

        return false;
    }

    /// @notice 修改当前合约的状态，由于任何一个继承此合约的实例都有可能是一个插件合约，那么
    ///         插件对应的插座合约可能会对本插件合约就行状态的调整
    function ChangeContractState(DBSContractState state) public
    {
      require( msg.sender == PlugBaseTarget || CTLInterface.IsSuperOrAdmin( msg.sender ) );

      ContractState = state;
    }

    /// @notice 查看当前合约已经连接的插件合约，每个FX2的PermissionInterface合约都可以作
    ///         为插座合约和插件合约，更具实际需求就行插件和插座的划分即可。
    function AllExtensionModules() public view returns (
        uint len,
        address[] memory addresses,
        DBSContractState[] states
        )
    {
        len = modulesIMPLs.length;
        addresses   = new address[](len);
        states      = new DBSContractState[](len);

        for ( uint i = 0; i < len; i++ )
        {
            addresses[i] = modulesIMPLs[i].FX2_ContractAddr;
            states[i] = FX2_PermissionInterface(addresses[i]).ContractState();
        }
    }

    /// @notice 标示函数只能由自己调用。
    modifier ThisContractOnly
    {
        require (msg.sender == address(this) );
        _;
    }

    /// @notice 实现合约部署工作的方法，在通过所有权限验证后，会调用该方法，就行合约迁移，请
    ///         注意处理数据。注意originModules的模块名称必须与newImplAddress的模块名称
    ///         一致，否则将不会进入该函数就行迁移工作。DBS按理来说不支持迁移，因为数据的迁移
    ///         在FX2中属于一种不够公开的行为。
    /// @param  originModules : 原插件合约地址
    /// @param  newImplAddress : 迁移的目标插件地址
    function DoMigrateWorking( address originModules, address newImplAddress ) public ThisContractOnly returns (bool suucess)
    {
        (originModules, newImplAddress, suucess);

        require(false, "DoMigrateWorking Is't implemented.");
    }

    /// @notice 开始进行子插件合约迁移或升级，内部实现会获取modulesAddress下是否是一个合法
    ///         的FX2插件模块，并且检查对应插件名称，对比当前合约中已经接入的插件合约，就行一
    ///         些必要的验证，比如尝试迁移一个不存在的模块。若验证通过，则会调用迁移工作函数就
    ///         就行迁移工作，如果工作在“监督者”模式下，则迁移工作会提交一个事件，等待“监督者”
    ///         就行批准后在完成迁移。
    ///         注意：在“监督者”模式下，迁移的新合约的状态条件设置为Disable状态，因为你可能
    ///              不知道“监督者”在什么时候通过了你的申请，导致一旦通过就接入合约造成一些
    ///              不好控制的时间，使用Disable在通过申请以后，不会马上生效，当你觉得具备
    ///              生效条件时候，自行调用SetContractState对插件进行启用是一个比较好的方
    ///              式。
    ///@param   modulesAddress : 迁移的目标合约，必须是已经实现部署的插件合约，并且是一个
    ///         合法的FX2插件模块，可以是FX2提供的标准扩展模块，也可以是遵循FX2规则的自定义
    ///         插件。
    function MigrateExternsionModule( address modulesAddress )
    external
    NeedAdminPermission
    returns (bool suucess)
    {
        ( bool supportFX2, InfoData memory data ) = ReadInfoAt(modulesAddress);

        require( supportFX2 && bytes(data.FX2_ModulesName).length > 0, "AddExternsionModule:Invalid FX2 Modules");

        uint originIndex = 0;
        for (; originIndex < modulesIMPLs.length; originIndex++ )
        {
            if ( keccak256( bytes(modulesIMPLs[originIndex].FX2_ModulesName) ) == keccak256( bytes(data.FX2_ModulesName)) )
            {
                break;
            }
            else if ( originIndex == modulesIMPLs.length - 1 )
            {
                return false;
            }
        }

        if ( Surveillanter != address(0x0) )
        {
          reviewEvents.push( ReviewEvent(msg.sender, modulesAddress, data.FX2_ModulesName, "MigrateModules") );
        }
        else
        {
          require( DoMigrateWorking( modulesIMPLs[originIndex].FX2_ContractAddr, modulesAddress), "DoMigrateWorking:Migrate Work Not Completed.");
        }

        return true;
    }

    /// @notice 设置当前合约所接入的插件合约的起停状态,可以随时由有权账户就行设置起停
    /// @param  modulesAddress : 已经连接的插件合约地址
    /// @param  enable : 设置启用(true),设置暂停使用(false)
    function SetExternsionModuleEnable( address modulesAddress, bool enable )
    external
    NeedAdminPermission
    returns
    (bool sucecss)
    {
      ( bool supportFX2, InfoData memory data ) = ReadInfoAt(modulesAddress);

      require(supportFX2, "AddExternsionModule:Invalid FX2 Modules");

      for (uint i = 0; i < modulesIMPLs.length; i++ )
      {
        if ( keccak256( bytes(modulesIMPLs[i].FX2_ModulesName) ) == keccak256( bytes(data.FX2_ModulesName)) )
        {
          if ( enable )
          {
            FX2_PermissionInterface(modulesAddress).ChangeContractState.gas(10000)( DBSContractState.Healthy);
          }
          else
          {
            FX2_PermissionInterface(modulesAddress).ChangeContractState.gas(10000)( DBSContractState.Disable);
          }

          return true;
        }
      }

      return false;
    }

    /// @notice 内部实现会获取modulesAddress下是否是一个合法的FX2插件模块，并且检查对应插
    ///         件名称，如已经存在一个相同名称的插件，那么应该去使用“迁移”方法，而不是尝试增
    ///         加。
    ///         如果工作在“监督者”模式下，新增插件会生成一个等待审核的事件。“监督者”在通过审
    ///         批后就行权限开放，由于增加模块实际上本质的工作是对目标地址就行调用授权，如果
    ///         申请已经提交，但是被驳回，新部署的插件合约只能作为一个废弃不可用的状态，因为
    ///         没有插座合约授权他读写数据。
    ///@param   modulesAddress : 迁移的目标合约，必须是已经实现部署的插件合约，并且是一个
    ///         合法的FX2插件模块，可以是FX2提供的标准扩展模块，也可以是遵循FX2规则的自定义
    ///         插件。
    function AddExternsionModule( address modulesAddress )
    public
    NeedAdminPermission
    returns ( bool success )
    {
        ( bool supportFX2, InfoData memory data ) = ReadInfoAt(modulesAddress);

        require( supportFX2 && bytes(data.FX2_ModulesName).length > 0, "AddExternsionModule:Invalid FX2 Modules");

        for (uint i = 0; i < modulesIMPLs.length; i++ )
        {
            if ( keccak256( bytes(modulesIMPLs[i].FX2_ModulesName) ) == keccak256( bytes(data.FX2_ModulesName)) )
            {
                return false;
            }
        }

        if ( Surveillanter != address(0x0) )
        {
          reviewEvents.push( ReviewEvent(msg.sender, modulesAddress, data.FX2_ModulesName, "AddModules") );
        }
        else
        {
          // if not working in surverillanter mode the new modules enable now.
          modulesIMPLs.push(data);
        }

        return true;
    }

    /// @notice 设置“监督者”，方法只能调用一次，设置一个监督者后，对合约就行扩展则需要审批
    ///         若不设置监督者，则合约视为无监视者的模式，增加，迁移，起停插件可以由权限高于
    ///         或者等于Admin的地址就行操作。为了更好的区分权限，监督者值允许使用Super权限
    ///         设置一次，之后不允许再次修改，如果“监督者”私钥丢失，将无法在对此插座合约就行
    ///         “新增”，“迁移”工作，（起停插件不受监督者限制）。
    ///         原因:"设置监督者"可以解决一些信任问题，由于本质上对于插座合约对权限控制是授权
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
    function SetSurveillanter(address addr) external NeedSuperPermission
    {
      require( Surveillanter != address(0x0) );
      Surveillanter = addr;

      return ;
    }

    /// @notice “监督者”审批提交的事件，目前支持两种事件，只有在设置了“监督者”并且交易发送人
    ///         为”监督者“的地址才可以执行。
    ///         AddModules : 申请添加插件模块
    ///         MigrateModules : 申请迁移某个已接入存在的插件模块
    /// @param passAddress 插件合约地址
    function PassReviewEvent(address passAddress) external ServerllantOnly
    {
      // 1.Find and remove Review event
      ReviewEvent memory passEvent;

      for ( uint i = 0; i < reviewEvents.length; i++ )
      {
        if ( reviewEvents[i].implAddress == passAddress )
        {
            passEvent = reviewEvents[i];

            for ( uint j = i; j < reviewEvents.length - 1; j++ )
            {
                reviewEvents[j] = reviewEvents[j+1];
            }

            // remove review event
            delete reviewEvents[reviewEvents.length - 1];
            reviewEvents.length --;
        }
      }

      // 2.Check Exist and find IMPL infomation
      InfoData memory originModuleInfo;
      for ( uint x = 0; x < modulesIMPLs.length; x++ )
      {
        if ( keccak256(bytes(modulesIMPLs[i].FX2_ModulesName)) == keccak256(bytes(reviewEvents[i].modulesName)) )
        {
            if ( keccak256(bytes(reviewEvents[i].evnetCode)) == keccak256("AddModules") )
            {
                emit OnReviewNotifaction( passAddress, "PassedAddModulesEvent:but address already exists。" );
                return ;
            }
            else
            {
                originModuleInfo = modulesIMPLs[i];
            }
        }
      }

      // 3. Get New Modules infomation.
      ( ,InfoData memory data ) = ReadInfoAt(passAddress);

      // 4. Do the work.
      if ( keccak256(bytes(passEvent.evnetCode)) == keccak256("AddModules") )
      {
        modulesIMPLs.push(data);

        emit OnReviewNotifaction( passAddress, "PassedAddModulesEvent" );

        return ;
      }
      else if ( keccak256(bytes(passEvent.evnetCode)) == keccak256("MigrateModules") )
      {
        if ( DoMigrateWorking(originModuleInfo.FX2_ContractAddr, passAddress) )
        {
            emit OnReviewNotifaction( passAddress, "PassedMigrateModulesEvent" );
        }
        else
        {
            emit OnReviewNotifaction( passAddress, "PassedMigrateModulesEvent:but DoMigrateWorking faild." );
        }
      }
    }

    /// @notice “监督者”拒绝提交的事件，目前支持两种事件，只有在设置了“监督者”并且交易发送人
    ///         为”监督者“的地址才可以执行。
    ///         AddModules : 申请添加插件模块
    ///         MigrateModules : 申请迁移某个已接入存在的插件模块
    /// @param rejectAddress : 插件合约地址
    function RejectReviewEvent(address rejectAddress) external ServerllantOnly
    {
      for ( uint i = 0; i < reviewEvents.length; i++ )
      {
        if ( reviewEvents[i].implAddress == rejectAddress )
        {
          for ( uint j = i; j < reviewEvents.length - 1; j++ )
          {
            reviewEvents[j] = reviewEvents[j+1];
          }

          // remove review event
          delete reviewEvents[reviewEvents.length - 1];
          reviewEvents.length --;

          emit OnReviewNotifaction( rejectAddress, "RejectEvent" );

          return;
        }
      }
    }

    /*——————————————————————————————————————————————————————————————*/
    /*                         Stroage 变量定义                      */
    /*——————————————————————————————————————————————————————————————*/
    FX2_PermissionCtl_Interface  CTLInterface;
    InfoData[]                   modulesIMPLs;


    /*——————————————————————————————————————————————————————————————*/
    /*                          FX2 模块信息                         */
    /*——————————————————————————————————————————————————————————————*/
    string public FX2_ModulesName = "FX2.PermissionInterface";
}
