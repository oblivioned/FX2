pragma solidity >=0.5.0 <0.6.0;

import "../../../base/interface/FX2_AbstractDBS_Interface.sol";
import "../../ERC20Token/interface/FX2_ERC20TokenDBS_Interface.sol";
import "../contracts/FX2_Externsion_POS_Events.sol";

contract FX2_Externsion_POS_DBS_Interface is FX2_AbstractDBS_Interface
{
    /// @notice 增加一个Pos参与记录，一般由用户发起
    /// @param  _owner : 拥有此记录的用户
    /// @param  _amount : 参与的数量
    /// @return success : 记录添加结果
    function AddPosRecord( address _owner, uint256 _amount ) external returns (bool success);


    /// @notice 更新Pos参与记录的最后领取时间
    /// @param _owner : 用户地址
    /// @param _rIndex : 记录对应的检索值
    /// @param _newValue : 更新到的目标时间（一般为now)
    /// @return success : 更新是否成功
    function UpdataPosRecordLastWithDrawTime( address _owner, uint _rIndex, uint256 _newValue ) external returns (bool success);


    /// @notice 获取用户对应的Pos参与记录的详细信息
    /// @param  _owner : 用户地址
    /// @param  _rIndex : 记录对应的检索值
    /// @return _amount : 记录对应的参与数量
    /// @return _depositTime : 记录对应的创建或者投入时间
    /// @return _lastWithDrawTime : 记录对应的最后一次提取收益的时间
    function GetPosRecord( address _owner, uint _rIndex ) external view returns ( uint256 _amount, uint256 _depositTime, uint256 _lastWithDrawTime );


    /// @notice 删除用户对应的Pos参与记录，一般而言，用于提取本金，即解约过程
    /// @param  _owner : 用户地址
    /// @param  _rIndex : 记录对应的参与数量
    /// @return success : 删除是否成功
    function RemovePosRecord( address _owner, uint _rIndex ) external returns (bool success);


    /// @notice 获取用户所有Pos参与记录的详情列表
    /// @param  _owner : 用户地址
    /// @return len : 用户拥有的记录总数量
    /// @return _amounts : 记录对应的数量
    /// @return _depositTimes : 记录对应的投入时间
    /// @return _lastWithDrawTimes : 记录对应的最后一次提取的时间
    function GetPosRecordList( address _owner ) external view returns ( uint  len, uint256[] memory _amounts, uint256[] memory _depositTimes, uint256[] memory _lastWithDrawTimes );


    /// @notice 获取当前参与Pos池的总数量
    /// @return 总数量
    function GetPosPoolTotalAmount() external view returns (uint256 totalSum);


    /// @notice 获取目标用户所有在于Pos池中投入的数量
    /// @param  _owner : 用户地址
    /// @return posTotal : 当前用户在Pos池中投入的总数量
    function GetPosTotalAmount( address _owner ) external view returns (uint256 posTotal);


    /// @notice 设置对于Pos产出最大保存的记录数量，默认为30，并且记录只能扩充，不能减少。
    /// @param _maxSize : 更新的最大记录天数
    function SetPosoutRecordMaxSize (uint16 _maxSize) external;


    /// @notice 获取当前设置的Pos产出最大记录值
    /// @return size : 当前设置的Pos产出记录保存的条目数量的最大值
    function GetPosOutRecordMaxSize() external view returns (uint16 size);


    /// @notice 添加一个Pos产出记录
    /// @param _posTotal : 当次通过Pos产出的总和最高值
    /// @param _posDecimal : 当次使用的精度
    /// @param _posEverCoinAmount : 每个最小精度的代币可以获得的Pos收益
    /// @param _posoutTime :  产出时间，一般为now
    /// @return success : 操作结果
    function PushPosoutRecord( uint256 _posTotal, uint256 _posDecimal, uint256 _posEverCoinAmount, uint256 _posoutTime ) external returns (bool success);


    /// @notice 获取Pos产出记录的详情信息
    /// @param _rindex : 产出记录对应的检索值
    /// @return posTotal : 当次通过Pos产出的总和最高值
    /// @return posDecimal : 当次使用的精度
    /// @return posEverCoinAmount : 每个最小精度的代币可以获得的Pos收益
    /// @return posoutTime :  产出时间，一般为now
    function GetPosoutRecord(uint _rindex) external view returns ( uint256 posTotal, uint256 posDecimal, uint256 posEverCoinAmount, uint256 posoutTime );


    /// @notice 获取所有Pos产出记录详情(受最大保存的Pos产出记录大小的限制，例如最大记录30日，那么该方法返回的数量一定小于等于30)
    /// @return len : 记录数量
    /// @return posTotals : 当次通过Pos产出的总和最高值
    /// @return posDecimals : 当次使用的精度
    /// @return posEverCoinAmounts : 每个最小精度的代币可以获得的Pos收益
    /// @return posoutTimes :  产出时间，一般为now
    function GetPosoutRecordList() external view returns ( uint  len, uint256[] memory posTotals, uint256[] memory posDecimals, uint256[] memory posEverCoinAmounts, uint256[] memory posoutTimes );

    /// @notice 设置日通过Pos产出，每日的最大值，可以用作按年递减，或者根据发行的情况就行调整
    /// @param maxAmount : 新的日产出最大值
    function API_SetEverDayPosMaxAmount(uint256 maxAmount) external;

    /// @notice 增加一个Pos收益记录，理论上每日应该调用一次
    /// @param success : 创建结果
    function API_CreatePosOutRecord() external returns (bool success);

    /// @notice 设置是否让合约在计算Pos产出时候自动发送代币，若设为否，则不发送代币收益，但是所有计算仍然按照已经正常发送就行
    /// @param enable : true 启用 false 禁止
    function API_SetEnableWithDrawPosProfit(bool enable) external;

    /// @notice 获取当前合约是否属于发送代币收益奖励
    /// @return enable : 状态
    function API_GetEnableWithDrawPosProfit() external view returns (bool enable);


    struct PosRecord
    {
        uint256 amount;
        uint256 depositTime;
        uint256 lastWithDrawTime;
    }

    struct PosoutRecord
    {
      uint256 posTotal;
      uint256 posDecimal;
      uint256 posEverCoinAmount;
      uint256 posoutTime;
    }

    struct DB
    {
        mapping (address => PosRecord[]) dbs_pos;

        PosoutRecord[] dbs_out;

        // 参与Pos的总数量
        uint256 posAmountTotalSum;
        uint16  posOutRecordMaxSize;
    }
}
