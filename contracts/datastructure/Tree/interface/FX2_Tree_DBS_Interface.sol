pragma solidity >=0.5.0 <0.6.0;

import "../../../base/abstract/FX2_AbstractDBS.sol";

/// @title  树形地址存储存储
/// @notice ⚠️：树形地址存储结构的设计主要用于解决存储地址特殊性问题，和一些其他数据结构的参考结构，如果使用者需使用该结构存储推荐和分销关系，请确符合相关法律法规，例如在中国大陆计算收益时查找的节点的深度不超过三层（depth <= 3)，否则带来的任何后果，作者不承担任何责任
contract FX2_Tree_DBS_Interface is FX2_AbstractDBS
{
    /// @notice 导入节点
    /// @param  _parentNode   : 父节点
    /// @param  _chilrenNode  : 孩子节点
    /// @return success       : 导入结果
    function ImportNodes( address _parentNode, address _chilrenNode ) external returns ( bool success );

    /// @notice 增加节点
    /// @param  _newNode      : 新节点
    /// @param  _parentNode   : 父节点
    /// @return success       : 添加结果
    function AddLeafNode( address _parentNode, address _newNode) external returns ( bool success );

    /// @notice 检测节点是否是根节点
    /// @param  _node         : 检测的节点
    /// @return nodeIsExist   : 节点是否存在本树形结构图中
    /// @return isRootNode    : 检测结果，如果检测的节点本身就不存在，此项的返回无论是真假，均无效
    function IsRootNodes( address _node ) external returns ( bool nodeIsExist, bool isRootNode );

    /// @notice 获取节点的父亲节点
    /// @param  _node         : 检测的节点
    /// @return nodeIsExist   : 节点是否存在本树形结构图中
    /// @return parentNode    : 获取结果，如果检测的节点本身就不存在，此项的返回无论是真假，均无效，否则返回父亲节点数据
    function GetParentNode( address _node ) external returns ( bool nodeIsExist, address parentNode );

    /// @notice 获取孩子节点的数据
    /// @param  _parentNode : 父亲节点地址
    /// @return childrens   : 孩子节点的数据集
    function GetChildrenNode( address _parentNode ) external view returns ( address[] memory childrens );
    /// @notice 只获取数量（计算的复杂度与其上方法一样，区别在于在传输过程中不传输实际节点数据，之返回数量）
    function GetChildrenNodeCount ( address _parentNode ) external view returns ( uint childrensCount ) ;


    /// @notice 获取后代节点的数据
    /// @param  _ancestorNode : 祖先节点
    /// @return progenies     : 后代节点的数据集
    function GetProgenyNode( address _ancestorNode, uint depthCount ) external view returns ( address[] memory progenies );


    /* /// @notice 深度优先搜索算法搜索节点
    /// @param _searchNode      : 搜索目标节点
    /// @param _inSubTreeroot   : 在指定的子树中搜索，若填写 addresss(0x0)则会在全树形结构中搜索
    /// @return isExist         : 搜索的目标是否存在当前_inSubTreeroot中
    /// @return rootNode        : 若结果非addresss(0x0)则说明找到目标节点，并且此字段改为目标所属的根节点
    /// @return parentNode      : 若结果非addresss(0x0)则说明找到目标节点，并且此字段改为目标所属的父节点
    function SearchNodeByDepthFirst( address _searchNode, address _inSubTreeroot ) external view returns ( bool isExist, address rootNode, address parentNode );

    /// @notice 广度优先搜索算法搜索节点
    /// @param _searchNode      : 搜索目标节点
    /// @param _inSubTreeroot   : 在指定的子树中搜索，若填写 addresss(0x0)则会在全树形结构中搜索
    /// @return isExist         : 搜索的目标是否存在当前_inSubTreeroot中
    /// @return rootNode        : 若结果非addresss(0x0)则说明找到目标节点，并且此字段改为目标所属的根节点
    /// @return parentNode      : 若结果非addresss(0x0)则说明找到目标节点，并且此字段改为目标所属的父节点
    function SearchNodeByBreadthFirst( address _searchNode, address _inSubTreeroot ) external view returns ( bool isExist, address rootNode, address parentNode ); */

}
