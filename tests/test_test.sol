pragma solidity >=0.4.25 <0.6.0;

import "remix_tests.sol"; // this import is automatically injected by Remix.

import "../base/implement/FX2_PermissionCtl.sol";
import "../base/implement/FX2_ERC20TokenDBS.sol";
import "../base/FX2_ERC20TokenPlugBaseContract.sol";

// file name has to end with '_test.sol'
contract TestDeploy {

    FX2_PermissionCtl PCTL;
    FX2_ERC20TokenDBS DBS_Token;
    FX2_ERC20TokenPlugBaseContract TokenInterface;

    function beforeAll() public
    {

    }

    function Check1_DeployPCTL() public
    {
        // 创建权限管理实例
        PCTL = new FX2_PermissionCtl();
        Assert.ok( address(PCTL) != address(0x0), "new FX2_PermissionCtl() faild." );
    }

    function Check2_DeployTokenDBS() public
    {
        // 创建 TokenDBS
        DBS_Token = new FX2_ERC20TokenDBS( address(this) );
        Assert.ok( address(DBS_Token) != address(0x0), "new FX2_ERC20TokenDBS() faild." );
    }

    function Check3_DeployToken() public
    {
         // 创建 Token
        TokenInterface = new FX2_ERC20TokenPlugBaseContract( address(DBS_Token) );
        Assert.ok( address(TokenInterface) != address(0x0), "new FX2_ERC20TokenPlugBaseContract() faild." );
    }

    function Check4_SetContractPermission() public
    {
        // 设置 TokenDBS访问权限
        DBS_Token.AddConstractVisiter( address(TokenInterface) );
    }


    function Check5_ThisBalanceIsRight() public
    {
        Assert.equal( TokenInterface.balanceOf(address(this)), uint256( 1500000000 * 10 ** 8 ), "预挖数量不正确" );
    }

    function Check6_TransferSomeToken() public
    {
        TokenInterface.transfer(msg.sender, uint256(500000000 * 10 ** 8) );

        Assert.equal( TokenInterface.balanceOf(address(this)), uint256(1000000000 * 10 ** 8), "转账测试失败" );
    }
}
