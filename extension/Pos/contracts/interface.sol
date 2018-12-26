pragma solidity >=0.4.22 <0.6.0;

import "./lib.sol";

interface FX2_Externsion_Interface_PosSupport 
{
  
    function DespoitToPos(uint256 amount) 
    external 
    returns (bool success);

  
    function GetPosRecordCount() 
    external 
    constant
    returns (uint recordCount);

  
    function GetPosRecordInfo(uint index)
    external
    constant
    returns ( uint256 amount, uint256 depositTime, uint256 lastWithDrawTime, uint prefix );


    function RescissionPosAt(uint posRecordIndex)
    external
    returns (uint256 posProfit, uint256 amount, uint256 distantPosoutTime);

 
    function RescissionPosAll()
    external
    returns (uint256 amountTotalSum, uint256 profitTotalSum);

 
    function GetCurrentPosSum()
    external
    constant
    returns (uint256 sum);


    function GetPosoutLists()
    external
    constant
    returns ( uint256[] posouttotal, uint256[] profitByCoin, uint256[] posoutTime );


    function GetPosoutRecordCount()
    external
    constant
    returns (uint256 count);

 
    function WithDrawPosProfit(uint posRecordIndex)
    external
    returns (uint256 profit, uint256 posAmount);
  

    function WithDrawPosAllProfit()
    external
    returns (uint256 profitSum, uint256 posAmountSum);


    function API_SetEverDayPosMaxAmount(uint256 maxAmount)
    external;
    
    
    function API_CreatePosOutRecord()
    external
    returns (bool success);


    function API_SetEnableWithDrawPosProfit(bool state)
    external;
   
   
    function API_GetEnableWithDrawPosProfit(bool state)
    external
    constant;
    
}