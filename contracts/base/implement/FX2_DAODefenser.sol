/*
 *
 *《 Flying Feathers 》- Aya ETH Contract Frameworks
 * 版本:0.0.1
 * 作者:Martin.Ren（oblivioned)
 * 最后修改时间:2018-12-30
 * 项目地址:https://github.com/oblivioned/FX2
 *
 */

 pragma solidity >=0.5.0 <0.6.0;

 /// @notice 防止函数被“重入”，虽然可以避免大部分DAO攻击，但是在防御的同时也失去了递归调用的特性，一般用于向外界暴露的ABI方法进行修饰
 /// !!!!不支持修饰 pure，view，contant的函数（需要修改计数数据）
 /// @author Martin.Ren
 contract FX2_DAODefenser
 {
     mapping( bytes4 => bool ) _functionCallingCountMapping;

     /// @notice 当修饰的函数被重入直接中断函数并且回滚交易。
     modifier DAORequirer
     {
         require( !_functionCallingCountMapping[msg.sig] );
         _functionCallingCountMapping[msg.sig] = true;
         _;
         _functionCallingCountMapping[msg.sig] = false;
     }

     /// @notice 当修饰的函数被重入直接跳过重入的逻辑，之执行第一次的逻辑。
     modifier DAOLocker
     {
         if ( _functionCallingCountMapping[msg.sig] )
         {
             return ;
         }
         else
         {
             _functionCallingCountMapping[msg.sig] = true;
             _;
             _functionCallingCountMapping[msg.sig] = false;
         }
     }
 }
