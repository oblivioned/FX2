pragma solidity >=0.5.0 <0.6.0;

import "./interface/FX2_Tree_DBS_Interface.sol";

/// @title  树形村粗数据结构
/// @notice ⚠️：树形数据机构仅是单纯的提供一个在计算机《数据结构》中实现的树形结构，如何使用该结构，请使用者自行斟酌，若由于使用不当违法相关法律法规，作者不承担任何责任。
contract FX2_Tree_DBS is FX2_Tree_DBS_Interface
{
  constructor( FX2_PermissionCtl_Interface fx2_pcimpl, FX2_ModulesManager_Interface fx2_mmimpl )
  public
  {
    FX2_PermissionCtl_Modifier_LinkIMPL( fx2_pcimpl );
    FX2_ModulesManager_Modifier_LinkIMPL( fx2_mmimpl );
  }

  /// @notice 导入节点，必须从上至下导入，即从Root节点开始, 若不能保证数据源的准确性，可能存在循环树的情况
  /// @param  _parentNode   : 父节点
  /// @param  _chilrenNode  : 孩子节点
  /// @return success       : 导入结果
  function ImportNodes( address _parentNode, address _chilrenNode )
  external
  NeedAdminPermission
  returns ( bool success )
  {
    /// 节点必须未就行过连接，否则跳过此节点的添加
    if ( _parentNodeMapping[_chilrenNode] == address(uint160(0)) ||
         _parentNodeMapping[_chilrenNode] == address(uint160(-1)) )
    {
      _childrenNodeMapping[_parentNode].push(_chilrenNode);
      _parentNodeMapping[_chilrenNode] = _parentNode;
      return true;
    }
      
    return false;
  }

  /// @notice 检测节点是否是根节点
  /// @param  _node         : 检测的节点
  /// @return nodeIsExist   : 节点是否存在本树形结构图中
  /// @return isRootNode    : 检测结果，如果检测的节点本身就不存在，此项的返回无论是真假，均无效
  function IsRootNodes( address _node )
  external
  ValidModuleAPI
  returns ( bool nodeIsExist, bool isRootNode )
  {
    if ( _parentNodeMapping[_node] == address(uint160(-1)) )
    {
      // 节点存在但是没有父节点数据
      return (true, true);
    }
    else if ( _parentNodeMapping[_node] == address(uint160(0)) )
    {
      // 节点不存在
      return (false, false);
    }
    else
    {
      // 节点存在，但是有记录父亲节点
      return (true, false);
    }
  }

  /// @notice 获取节点的父亲节点
  /// @param  _node         : 检测的节点
  /// @return nodeIsExist   : 节点是否存在本树形结构图中
  /// @return parentNode    : 获取结果，如果检测的节点本身就不存在，此项的返回无论是真假，均无效，否则返回父亲节点数据
  function GetParentNode( address _node )
  external
  ValidModuleAPI
  returns ( bool nodeIsExist, address parentNode )
  {
    if ( _parentNodeMapping[_node] == address(uint160(-1)) )
    {
      // 节点存在但是没有父节点数据
      return (true, address(uint160(0)));
    }
    else if ( _parentNodeMapping[_node] == address(uint160(0)) )
    {
      // 节点不存在
      return (false, address(uint160(0)));
    }
    else
    {
      // 节点存在，但是有记录父亲节点
      return (true, _parentNodeMapping[_node]);
    }
  }

  /// @notice 增加节点
  /// @param  _newNode      : 新节点
  /// @param  _parentNode   : 父节点
  /// @return success       : 添加结果
  function AddLeafNode( address _parentNode, address _newNode )
  external
  ValidModuleAPI
  returns ( bool success )
  {
    if ( _parentNodeMapping[_newNode] == address(0x0) )
    {
      _childrenNodeMapping[_parentNode].push(_newNode);
      _parentNodeMapping[_newNode] = _parentNode;
      return true;
    }
    
    return false;
  }


  /// @notice 获取孩子节点的数据
  /// @param  _parentNode : 父亲节点地址
  /// @return childrens   : 孩子节点的数据集
  function GetChildrenNode( address _parentNode )
  external
  view
  ValidModuleAPI
  returns ( address[] memory childrens )
  {
    return _childrenNodeMapping[_parentNode];
  }

  /// @notice 只获取数量
  function GetChildrenNodeCount ( address _parentNode )
  external
  view
  ValidModuleAPI
  returns ( uint childrensCount )
  {
    return _childrenNodeMapping[_parentNode].length;
  }

  /// @notice 获取后代节点的数据
  /// @param  _ancestorNode : 祖先节点
  /// @return progenies     : 后代节点的数据集
  function GetProgenyNode( address _ancestorNode, uint depthCount )
  external
  view
  ValidModuleAPI
  returns (address[] memory progenies)
  {
    uint offset = 0;

    for ( uint d = 0; d < depthCount; d++ )
    {
      if ( d == 0 )
      {
         progenies = _childrenNodeMapping[_ancestorNode];
      }
      else
      {
        address[] memory depthLoopTempArr;

        for ( uint x = offset; x < progenies.length; x++ )
        {
          if ( x == offset )
          {
            depthLoopTempArr = _childrenNodeMapping[progenies[x]];
          }
          else
          {
            depthLoopTempArr = MergedArray(depthLoopTempArr, _childrenNodeMapping[progenies[x]]);
          }
        }

        progenies = MergedArray(progenies, depthLoopTempArr);
        offset = progenies.length - 1;
      }
    }
  }

  function MergedArray( address[] memory originArrLeft, address[] memory originArrRight )
  public
  pure
  returns (address[] memory mergedArr)
  {
    mergedArr = new address[](originArrLeft.length + originArrRight.length);

    for ( uint i = 0; i < mergedArr.length; i++ )
    {
        if ( i < originArrLeft.length )
        {
            mergedArr[i] = originArrLeft[i];
        }
        else
        {
            mergedArr[i] = originArrRight[i - originArrLeft.length];
        }
    }
  }

  /* /// @notice 深度优先搜索算法搜索节点，搜索的复杂度根据树状结构中的数据量而定
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


  /// @notice 记录每个节点的父亲节点，若得出的结果是 address(uint160(-1)) 说明是一个已经添加的节点，但是没有添加父节点的连接
  mapping ( address => address )    _parentNodeMapping;
  mapping ( address => address[] )  _childrenNodeMapping;

  /////////////////// FX2Framework infomation //////////////////
  string    public FX2_ModulesName = "FX2.DataStructure.Tree.DBS";
}
