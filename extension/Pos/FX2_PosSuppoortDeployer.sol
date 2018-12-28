pragma solidity >=0.4.22 <0.6.0;

import "./contracts/dbs.sol";
import "./contracts/impl.sol";

contract FX2_Deployer
{
    address public CTL_Instance_Address     = address(0x692a70d2e424a56d2c6c27aa97d1a86395877b3a);
    address public Token_Instance_Address   = address(0x0dcd2f752394c41875e259e00bb44fd505297caf);
    
    address public DBSAddress;
    address public IMPLAddress;
    
    constructor() public MustSupportFX2(CTL_Instance_Address) MustSupportFX2(Token_Instance_Address)
    {
        
    }
    
    function SetDBSAddress(address addr) public
    {
        require ( DBSAddress == address(0x0) );
        DBSAddress = addr;
    }
    
    function SetIMPLAddress(address addr) public
    {
        require ( IMPLAddress == address(0x0) );
        IMPLAddress = addr;
    }
    
    modifier MustSupportFX2(address contractAddr)
    {
        // require ( bytes(FX2_CheckerInterface(contractAddr).FX2_VersionInfo()).length > 10 );
        _;
    }
    
    modifier PermissionChecker
    {
        require( CTL_Interface(CTL_Instance_Address).IsSuperOrAdmin(msg.sender), "If you need to extend this Token, the address of the call deployment must have at least administrator privileges.");
        _;
    }
    
}

contract FX2_DeployDBS
{
    constructor( address deployerAddress ) public
    {
        address CTL_Instance_Address = FX2_Deployer(deployerAddress).CTL_Instance_Address();
        address Token_Instance_Address = FX2_Deployer(deployerAddress).Token_Instance_Address();
        
        address contractAddress = new FX2_Externsion_DBS_PosSupport( Token_Instance_Address, CTL_Instance_Address );
        FX2_Deployer(deployerAddress).SetDBSAddress(contractAddress);
    }
}

contract FX2_DeployIMPL
{
    address TaskStateAddress;
    
    constructor( address deployerAddress ) public
    {
        TaskStateAddress = deployerAddress;
        address Token_Instance_Address = FX2_Deployer(deployerAddress).Token_Instance_Address();
        address IMPLAddress = new FX2_Externsion_IMPL_PosSupport( FX2_Deployer(deployerAddress).DBSAddress(), Token_Instance_Address );
        
        bytes4 methodId = bytes4(keccak256("AddConstractVisiter(address)"));
        require( address(Token_Instance_Address).call(methodId, IMPLAddress) );
        
        FX2_Deployer(deployerAddress).SetIMPLAddress(IMPLAddress);
    }
    
}

interface FX2_CheckerInterface
{
    function FX2_VersionInfo() external view returns (string memory str);
}

interface CTL_Interface
{
    function IsSuperOrAdmin(address _sender) external view returns (bool exist);
}

interface DBS_Interface
{
    function AddConstractVisiter( address visiter ) external returns ( bool success );
}