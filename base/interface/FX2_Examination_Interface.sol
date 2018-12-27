pragma solidity >=0.4.22 <0.6.0;

contract FX2_Examination_Interface {
    
    enum DBSContractState 
    {
        /***************************************************************/
        /**    BetterThanExecuted param End ( Contain "AnyTimes")     **/
        /***************************************************************/
        /* Normal operation of all functions */
        Healthy,
        
        /* There are errors, but they still work. Some of the functions are affected. */
        Sicking,
        
        /* Serious errors, resulting in some functions can not function properly */
        Serious,
        
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
    
    DBSContractState ContractState;
    
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
    
    // must implements method,use pass permissioon in contract exceptiontimes.
    function IsDoctorProgrammer(address addr) internal view returns (bool ret);
    
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
    internal;
    
    function () public;
}
    
