pragma solidity >=0.4.22 <0.6.0;

import "./interface/FX2_PermissionCtl_Interface.sol";

contract FX2_PermissionInterface
{
    enum DBSContractState 
    {
        /***************************************************************/
        /**    BetterThanExecuted param End ( Contain "AnyTimes")     **/
        /***************************************************************/
        /* Normal operation of all functions */
        Healthy,
        
        /* There are errors, but they still work. Some of the functions are affected. */
        Sicking,
        
        /* Serious error, suspend all contract related functions, wait for maintenance or migration */
        Error,
        /***************************************************************/
        /**    BetterThanExecuted param End ( Contain "AnyTimes")     **/
        /***************************************************************/
        
        /* The contract is being upgraded */
        Upgrading,
        
        /* The contract has been discarded and moved to the new contract, which is awaiting recovery. */
        Migrated,
        
        /* any one times */
        AnyTimes
    }
    
    DBSContractState public ContractState;
    
    function SetCTLContractAddress( FX2_PermissionCtl_Interface ctlAddress ) public
    {
        require( CTLInterface == address(0x0), "Address has been set and cannot be set again");
        
        CTLInterface = FX2_PermissionCtl_Interface(ctlAddress);
    }
    
    event OnExaminationStateChanged(
        uint256 blockNumber,
        bytes txdata,
        DBSContractState origin,
        DBSContractState current,
        string msg
        );
        
    event OnException(
        uint256 blockNumber, 
        bytes txdata,
        DBSContractState state
        );
    
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
        
        require(ContractState != DBSContractState.Upgrading, "The contract is being upgraded.");
        require(ContractState != DBSContractState.Migrated, "The contract has been discarded and moved to the new contract.");
        require( uint8(ContractState) <= uint8(_betterThanState), "Failure of health examination." );
        _;
    }
    
    function RequireInPayableFunc(bool _ret, string _msg, DBSContractState _ifFaildSetState)
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
    
    function () public 
    {
        emit OnException(block.number, msg.data, ContractState);
    }

    modifier ConstractInterfaceMethod()
    {
        require( IsExistContractVisiter(msg.sender) );
        _;
    }
  
    modifier NeedSuperPermission()
    {
        CTLInterface.RequireSuper(msg.sender);
        _;
    }

    modifier NeedAdminPermission()
    {
        CTLInterface.RequireAdmin(msg.sender);
        _;
    }

    modifier NeedManagerPermission()
    {
        CTLInterface.RequireManager(msg.sender);
        _;
    }
  
    /// @notice override super contract function
    function IsDoctorProgrammer( address addr ) 
    internal 
    view 
    returns (bool ret)
    {
        return CTLInterface.IsSuperOrAdmin( addr );
    }
  
    function IsExistContractVisiter( address visiter )
    public
    view
    returns (bool exist)
    {
        for (uint i = 0; i < constractVisiters.length; i++ )
        {
            if ( constractVisiters[i] == visiter )
            {
                return true;
            }
        }

        return false;
    }

    function ChangeContractStateToUpgrading() public NeedSuperPermission
    {
        ContractState = DBSContractState.Upgrading;
    }
    
    // ContractVisting Controller
    function AddConstractVisiter( address visiter )
    public
    NeedAdminPermission
    returns (bool success)
    {
        for (uint i = 0; i < constractVisiters.length; i++ )
        {
            if ( constractVisiters[i] == visiter )
            {
                return false;
            }
        }
        
        constractVisiters.push(visiter);
        return true;
    }
  
    FX2_PermissionCtl_Interface CTLInterface;
    
    address[]                   constractVisiters;
}