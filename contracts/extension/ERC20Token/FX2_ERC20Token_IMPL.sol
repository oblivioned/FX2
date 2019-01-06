pragma solidity >=0.5.0 <0.6.0;

import "./interface/FX2_ERC20TokenDBS_Interface.sol";
import "../../base/FX2_FrameworkInfo.sol";
import "./contracts/FX2_ERC20Token_Events.sol";

contract FX2_ERC20Token_IMPL is
FX2_FrameworkInfo,
FX2_ERC20Token_Events
{
    address TokenDBS;

    constructor( address tokenDBSAddr ) public payable
    {
        TokenDBS = tokenDBSAddr;
    }

    function totalSupply() public view returns ( uint256 )
    {
        return FX2_AbstractDBS_Interface(TokenDBS).GetUintValue("totalSupply");
    }

    function name() public pure returns ( string memory )
    {
        return "FFToken";
    }

    function decimals() public view returns ( uint8 )
    {
        return uint8(FX2_AbstractDBS_Interface(TokenDBS).GetUintValue("decimals"));
    }

    function symbol() public pure returns ( string memory )
    {
        return "FFT";
    }

    function balanceOf(address _owner) public view returns (uint256 balance)
    {
        return FX2_ERC20TokenDBS_Interface(TokenDBS).GetAddressBalance(_owner);
    }

    function transfer(address _to, uint256 _value) public returns (bool success)
    {
        FX2_ERC20TokenDBS_Interface(TokenDBS).TransferBalance(msg.sender, _to, _value);

        emit Transfer( msg.sender, _to, _value );

        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success)
    {
        FX2_ERC20TokenDBS_Interface(TokenDBS).TransferAllowance(msg.sender, _from, _to, _value);
        emit Transfer( _from, _to, _value );
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256)
    {
        return FX2_ERC20TokenDBS_Interface(TokenDBS).GetAllowance(owner, spender);
    }

    function approve(address spender, uint value) public returns (bool success)
    {
        success = FX2_ERC20TokenDBS_Interface(TokenDBS).SetAllowanceTo(msg.sender, spender, value);
        if ( success )
        {
            emit Approval(msg.sender, spender, value);
        }
    }

    /////////////////// FX2Framework infomation //////////////////
    string    public FX2_ModulesName = "FX2.Extension.ERC20Token.IMPL";
}
