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

    /// @notice When the contract status changes
    event OnExaminationStateChanged(
        uint256 blockNumber,
        bytes txdata,
        DBSContractState origin,
        DBSContractState current,
        string msg
        );

    /// @notice Any incomplete or unusual transaction occurs
    event OnException(
        uint256 blockNumber,
        bytes txdata,
        DBSContractState state
        );

    /// @notice Check the status of the contract and execute it after passing, otherwise forcibly interrupt
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

    /// @notice If it fails to pass the exception check, throw the information and set the contract status to the specified state
    /// @param _ret : exception check result.
    /// @param _msg : if exception throw msg.
    /// @param _ifFaildSetState : if checking faild seted state.
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

    /// @notice Provides permission judgment, which must be increased when DBS data needs to be modified
    modifier ConstractInterfaceMethod()
    {
        require( IsExistContractVisiter(msg.sender) );
        _;
    }

    /// @notice check super permission,if faild interrupt.
    modifier NeedSuperPermission()
    {
        CTLInterface.RequireSuper(msg.sender);
        _;
    }

    /// @notice check admin permission,if faild interrupt.
    modifier NeedAdminPermission()
    {
        CTLInterface.RequireAdmin(msg.sender);
        _;
    }

    /// @notice check manager permission,if faild interrupt.
    modifier NeedManagerPermission()
    {
        CTLInterface.RequireManager(msg.sender);
        _;
    }

    /// @notice When the contract enters an abnormal state,
    ///  the authorized user can continue to invoke the method
    ///  to find the problem before developing the contract function.
    function IsDoctorProgrammer( address addr )
    internal
    view
    returns (bool ret)
    {
        return CTLInterface.IsSuperOrAdmin( addr );
    }

    /// @notice check sender has my visiters, but the visieter address must be a contract.
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

    /// @notice user super permission set the contract state to tartget state.
    ///         if you want to upgraded this contract,you can use
    ///         ChangeContractState(DBSContractState.Upgrading) to pause access
    //          or use ChangeContractState(DBSContractState.Migrated) stop all
    ///         access after Migrated.
    function ChangeContractState(DBSContractState state) public NeedSuperPermission
    {
        ContractState = state;
    }

    function ConstractVisiters() public view returns (address[] memory ret)
    {
      return constractVisiters;
    }

    /// @notice add pass access contract visiter by this dbs contract.
    function AddConstractVisiter( address visiter )
    public
    NeedAdminPermission
    returns ( bool success )
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

    /// @notice remove a existing contract visiter.
    function RemoveContractVister( address visiter )
    public
    NeedAdminPermission
    returns ( bool success )
    {
      for (uint i = 0; i < constractVisiters.length; i++ )
      {
          if ( constractVisiters[i] == visiter )
          {
              for (uint j = i; j < constractVisiters.length - 1; j++ )
              {
                constractVisiters[j] = constractVisiters[j + 1];
              }

              delete constractVisiters[ constractVisiters.length - 1 ];
              constractVisiters.length --;

              return true;
          }
      }

      return false;
    }

    /// Some private variable.
    FX2_PermissionCtl_Interface CTLInterface;

    address[]                   constractVisiters;
}
