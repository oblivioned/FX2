pragma solidity >=0.4.22 <0.6.0;

contract FX2_PermissionInterface
{

  modifier ConstractInterfaceMethod()
  {
    require( IsExistContractVisiter(msg.sender) );
    _;
  }

  modifier NeedSuperPermission()
  {
    require(msg.sender == DBTable.superOwner);
    _;
    return;
  }

  modifier NeedAdminPermission()
  {
    if (msg.sender == DBTable.superOwner)
    {
      _;
      return;
    }

    bool exist = false;

    for (uint i = 0; i < DBTable.admins.length; i++ )
    {
      if (DBTable.admins[i] == msg.sender)
      {
        exist = true;
        break;
      }
    }

    require(exist);
    _;
    return;
  }

  modifier NeedManagerPermission()
  {
    if (msg.sender == DBTable.superOwner)
    {
      _;
      return;
    }

    bool exist = false;

    for (uint i = 0; i < DBTable.managers.length; i++ )
    {
      if (DBTable.managers[i] == msg.sender)
      {
        exist = true;

        break;
      }
    }

    // 如果存在管理员地址，则直接通过验证，否则继续查找是否属于更高权限的账号
    if (exist)
    {
      _;
      return;
    }

    for (uint j = 0; j < DBTable.admins.length; j++ )
    {
      if (DBTable.admins[j] == msg.sender)
      {
        exist = true;
        break;
      }
    }

    require(exist);
    _;
    return;
  }
}