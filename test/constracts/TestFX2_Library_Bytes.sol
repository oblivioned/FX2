pragma solidity >=0.5.0 <0.6.0;

import "truffle/Assert.sol";
import "../../contracts/base/library/FX2_Library_Bytes.sol";

contract TestFX2_Library_Bytes is FX2_Library_Bytes
{
    function test_bytescmp() public {

        // Case 1 : 空bytes匹配测试
        Assert.equal( bytescmp( new bytes(0), new bytes(0) ), true, 'Case 1 Faild' );

        // Case 2 : 1 位
        Assert.equal( bytescmp( bytes("F"), bytes("F") ), true, 'Case 2 Faild' );

        // Case 3 : 32 位
        Assert.equal( bytescmp( bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"), bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF") ), true, 'Case 3 Faild' );

        // Case 4 : 33 位
        Assert.equal( bytescmp( bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"), bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF") ), true, 'Case 4 Faild' );

        // Case 5 : 64 位
        Assert.equal( bytescmp( bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"), bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF") ), true, 'Case 5 Faild' );

        // Case 6 : 65 位
        Assert.equal( bytescmp( bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"), bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF") ), true, 'Case 6 Faild' );

        // Case 7 - 12 : 同上测试高位不想等的情况
        Assert.equal( bytescmp( new bytes(0), new bytes(1) ), false, 'Case 7 Faild' );
        Assert.equal( bytescmp( bytes("F"), bytes("E") ), false, 'Case 8 Faild' );
        Assert.equal( bytescmp( bytes("EFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"), bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF") ), false, 'Case 9 Faild' );
        Assert.equal( bytescmp( bytes("EFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"), bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF") ), false, 'Case 10 Faild' );
        Assert.equal( bytescmp( bytes("EFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"), bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF") ), false, 'Case 11 Faild' );
        Assert.equal( bytescmp( bytes("EFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"), bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF") ), false, 'Case 12 Faild' );

        // Case 13 - 18 : 同上测试低位不想等的情况
        Assert.equal( bytescmp( new bytes(0), new bytes(1) ), false, 'Case 13 Faild' );
        Assert.equal( bytescmp( bytes("F"), bytes("E") ), false, 'Case 14 Faild' );
        Assert.equal( bytescmp( bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE"), bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF") ), false, 'Case 15 Faild' );
        Assert.equal( bytescmp( bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE"), bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF") ), false, 'Case 16 Faild' );
        Assert.equal( bytescmp( bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE"), bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF") ), false, 'Case 17 Faild' );
        Assert.equal( bytescmp( bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE"), bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF") ), false, 'Case 18 Faild' );

        // Case 19 - 18 : 测试中间某位不等的情况
        Assert.equal( bytescmp( bytes("FFFFFFFFFFFFFFFEEFFFFFFFFFFFFFFF"), bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF") ), false, 'Case 15 Faild' );
        Assert.equal( bytescmp( bytes("FFFFFFFFFFFFFFFFEEFFFFFFFFFFFFFFF"), bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF") ), false, 'Case 16 Faild' );
        Assert.equal( bytescmp( bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEEFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"), bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF") ), false, 'Case 17 Faild' );
        Assert.equal( bytescmp( bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEEFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"), bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF") ), false, 'Case 18 Faild' );

    }

    function test_bytesset() public {

        //////////////////////////////////////////////////////////////////////////////////////////////////
        // Case 1-6 测试32字节以内的替换结果，主要测试在不能进行32字节对其时候，函数是否可以正常结算结果
        string memory text = "This is a test strings.";
        bytes memory textBytes = bytes(text);


        // Case 1-2 全部替换后匹配结果
        Assert.equal( bytesset( textBytes, 0, bytes("THIS IS A TEST STRINGS.") ), true, 'Case 1 Faild');
        /* Assert.equal( bytescmp( textBytes, bytes("THIS IS A TEST STRINGS.") ), true, 'Case 2 Faild' ); */
        Assert.equal( bytescmp( textBytes, bytes("THIS IS A TEST STRINGS.") ), true, string(textBytes) );

        // Case 3-4 替换前4位后匹配结果
        Assert.equal( bytesset( textBytes, 0, bytes("FFFF") ), true, 'Case 3 Faild');
        Assert.equal( bytescmp( textBytes, bytes("FFFF IS A TEST STRINGS.") ), true, 'Case 4 Faild' );

        // Case 5-6 替换中间的TEST后匹配结果
        Assert.equal( bytesset( textBytes, 10, bytes("AAAA") ), true, 'Case 5 Faild');
        Assert.equal( bytescmp( textBytes, bytes("FFFF IS A AAAA STRINGS.") ), true, 'Case 6 Faild' );

        // Case 6-7 越界替换应该正常返回替换失败,并且源串不应该改变
        Assert.equal( bytesset( textBytes, 0, bytes("This is a test strings.out of arr") ), false, 'Case 7 Faild');
        Assert.equal( bytescmp( textBytes, bytes("FFFF IS A AAAA STRINGS.") ), true, 'Case 8 Faild' );


        //////////////////////////////////////////////////////////////////////////////////////////////////
        // Case 9-14 测试32字节外的替换结果,测试用例使用40字节，主要测试在不能就行32字节对其时候函数是否可以正常计算结果
        string memory text40 = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        textBytes = bytes(text40);

        // Case 9-10 40字节全部替换后匹配结果
        Assert.equal( bytesset( textBytes, 0, bytes("BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB") ), true, 'Case 9 Faild');
        Assert.equal( bytescmp( textBytes, bytes("BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB") ), true, 'Case 10 Faild' );

        // Case 11-12 40字节中替换10-30个字节后匹配结果
        Assert.equal( bytesset( textBytes, 10, bytes("FFFFFFFFFFFFFFFFFFFF") ), true, 'Case 11 Faild');
        Assert.equal( bytescmp( textBytes, bytes("BBBBBBBBBBFFFFFFFFFFFFFFFFFFFFBBBBBBBBBB") ), true, 'Case 12 Faild' );

        // Case 13-14 越界替换
        Assert.equal( bytesset( textBytes, 30, bytes("FFFFFFFFFFFFFFFFFFFF") ), false, 'Case 13 Faild');
        Assert.equal( bytescmp( textBytes, bytes("BBBBBBBBBBFFFFFFFFFFFFFFFFFFFFBBBBBBBBBB") ), true, 'Case 12 Faild' );


        //////////////////////////////////////////////////////////////////////////////////////////////////
        // Case 15-20 测试在可以就行32字节对其时候，结果是否正确，用例使用64字节
        string memory text64 = "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
        textBytes = bytes(text64);

        // Case 15-16 40字节全部替换后匹配结果
        Assert.equal( bytesset( textBytes, 0, bytes("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA") ), true, 'Case 15 Faild');
        Assert.equal( bytescmp( textBytes, bytes("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA") ), true, 'Case 16 Faild' );

        // Case 17-18 40字节中替换10-30个字节后匹配结果
        Assert.equal( bytesset( textBytes, 16, bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF") ), true, 'Case 17 Faild');
        Assert.equal( bytescmp( textBytes, bytes("AAAAAAAAAAAAAAAAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFAAAAAAAAAAAAAAAA") ), true, 'Case 18 Faild' );

        // Case 19-20 越界替换
        Assert.equal( bytesset( textBytes, 33, bytes("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF") ), false, 'Case 19 Faild');
        Assert.equal( bytescmp( textBytes, bytes("AAAAAAAAAAAAAAAAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFAAAAAAAAAAAAAAAA") ), true, 'Case 20 Faild' );
    }
}
