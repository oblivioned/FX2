pragma solidity >=0.5.0 <0.6.0;

contract FX2_Library_Bytes
{
    /// @notice 替换方法,因为替换不需要改变bytes长度，所以直接在源串中替换值，不会返回新串，在边界不合法时，方法会直接返回false
    /// @param _source : 源串
    /// @param _begin : 起始检索
    /// @param _rplcontent : 替换串
    /// @return _success : 调用结果
    function bytesrpl( bytes memory _source, uint _begin, bytes memory _rplcontent ) internal pure returns ( bool _success ) {

        assembly {

            if gt ( add( _begin, mload( _rplcontent ) ), mload( _source ) ) {
                return (0,0)
            }

            for { let i := _begin } lt( i, add( _begin, mload( _rplcontent ) ) ) { i := add( i, 32 ) }
            {
                // 如果当前循环控制字符i加上32后大于实际需要替换的内容的长度，说明没有下一次循环写入，本次写入的数据会不足32个字节，需要合并数据，若相反则本次写入一定会写入32个字节
                switch gt ( add( i, 32 ), add( _begin, mload( _rplcontent ) ) )
                case 0 {
                    // 本次写入一定是32个字节，不需要合并字节数据
                    mstore( add( _source, add( 32, i ) ), mload( add( _rplcontent, add ( 32, sub( i, _begin ) ) ) ) )
                }
                case 1 {
                    // 本次写入一定小于32个字节，需要拼合数据
                    // 1.讲源串需要替换的位置的数据均设置为0
                    mstore( add( _source, add( 32, i) ), and( mload( add( _source, add( 32, i) ) ), exp( 8, sub( 32, mod( mload( _rplcontent ), 32 ) ) ) ) )
                    // 2.由于_rplcontent最后的不足32个字节的数据存在不可预料的地位数据，需要清空低位数据后在与源串进行or拼合，此处建立一个容纳后不足32字节的副本进行操作
                    let copy := mload(0x40)
                    mstore( 0x40, add( copy, 32 ) )
                    // 3.取出最后32字节数据,取出的结果在低位,需要移动到高位对其，实际就是左移，右端补0
                    mstore( copy, mul( mload( add( _rplcontent, mload( _rplcontent ) ) ), exp( 8, sub( 32, mod( mload( _rplcontent ), 32 ) ) ) ) )
                    // 4.数据合并
                    mstore( add( _source, add( 32, i ) ), or( mload( add( _source, add( 32, i ) ) ), mload(copy) ) )
                }
            }

            _success := 1
        }

    }

    /// @notice 拷贝方法,在内存中拷贝一个源串的备份，会返回新串
    /// @param _source : 源串
    /// @return _dist : 副本
    function bytescpy( bytes memory _source ) internal pure returns ( bytes memory _dist )
    {
        assembly {

            _dist := mload(0x40)
            mstore( 0x40, add( _dist, mload(_source) ) )

            for { let i := 0 } lt ( i, mload( _source ) ) { i := add(i, 32) }
            {
                mstore( add(_dist, i), mload( add( _source, i ) ) )
            }
        }
    }

    /// @notice 指定位置拷贝方法，在内存中按照指定的_seek和len提取一个源串的副本
    /// @param _source : 源串
    /// @param _seek : 拷贝的源串起始位置
    /// @param _len : 拷贝的源串的长度
    /// @return _dist : 副本
    function bytespcpy( bytes memory _source, uint _seek, uint _len ) internal pure returns ( bytes memory _dist )
    {
        assembly {

            if gt ( add( _seek, _len ), mload( _source ) )
            {
                return (0,0)
            }

            _dist := mload(0x40)
            mstore( 0x40, add( 32, add( _dist, _len ) ) )
            mstore( _dist, _len )

            for { let i:= _seek } lt ( i, add( _seek, _len ) ) { i := add( i, 32 ) }
            {
                mstore( add( _dist, add( 32, sub( i, _seek ) ) ), mload( add( _source, add( 32, i ) ) ) )
            }

        }
    }

    /// @notice 拼接函数，讲两个串就行拼接，由于串的长度是两个参数串的总和，所以会返回一个新的实例
    /// @param _bytes1 : 拼接结果中的高位字串
    /// @param _bytes1 : 拼接结果中的低位字串
    /// @return _new : 新的字串内存实例
    function bytescat( bytes memory _bytes1, bytes memory _bytes2 ) internal pure returns ( bytes memory _new )
    {
        assembly {

            let len := add ( add( mload( _bytes1 ), mload( _bytes2 ) ), 32 )
            _new := mload( 0x40 )
            mstore( 0x40, add( _new, len ) )
            mstore( _new, len )

            for { let i:= 0 } lt ( i, mload( _bytes1 ) ) { i := add(i , 32) }
            {
                mstore( add( _new, add( 32, i) ), mload(add( _bytes1, add( 32 , i ) ) ) )
            }

            for { let i:= mload( _bytes1 ) } lt ( i, len ) { i := add(i , 32) }
            {
                mstore( add( _new, add( 32, i) ), mload(add( _bytes2, add( 32 , i ) ) ) )
            }
        }
    }

    /// @notice 获取字串长度，推荐直接使用bytes.length而不是在此获取，此处仅提供一个额外的写法，而实际功能与前者无差别
    /// @return _len : 长度
    function byteslen( bytes memory _source ) internal pure returns ( uint _len )
    {
        assembly {
            _len := mload( _source )
        }
    }

    /// @notice 字串匹配，匹配两个字串是否相等，由于一次匹配32个字节，所以相比hash值匹配方式和循环遍历方式而言此方法效率较高特别是在串长超过32个字节时，由于是按照字节匹配，若用在匹配字符串中时候，会严格区分大小写
    /// @param _bytes1 : 字串1
    /// @param _bytes1 : 字串2
    /// @return _isEqual : 匹配结果
    function bytescmp( bytes memory _bytes1, bytes memory _bytes2 ) internal pure returns ( bool _isEqual )
    {
        assembly {

            _isEqual := 0

            if eq( mload( _bytes1 ), mload( _bytes2 ) )
            {
                _isEqual := 1

                for { let i := 0 } lt ( i, mload( _bytes1 ) ) { i := add( i, 32 ) }
                {
                    switch gt ( add( i, 32 ), mload( _bytes1 ) )
                    case 0 {
                        _isEqual := and( _isEqual, eq( mload( add( _bytes1, add( 32, i ) ) ), mload( add( _bytes2, add( 32, i ) ) ) ) )
                    }
                    case 1 {

                        _isEqual := and( _isEqual,
                            eq(
                                div ( mload( add( _bytes1, add( 32, i ) ) ), exp( 2, sub( 32, sub( mload(_bytes1), i ) ) ) ),
                                div ( mload( add( _bytes2, add( 32, i ) ) ), exp( 2, sub( 32, sub( mload(_bytes1), i ) ) ) )
                            )
                        )
                    }
                }
            }
        }
    }

    /// @notice 按照指定位置进行匹配
    /// @param _source : 源串
    /// @param _begin : 匹配源串的起始位置
    /// @param _dist : 匹配目标串
    /// @return _isEqual : 匹配结果
    function bytespcmp( bytes memory _source, uint _begin, bytes memory _dist ) internal pure returns ( bool _isEqual )
    {
        /// 此处不采用一下方式进行，改为直接匹配内存中对应的字节，相对可以提高计算效率
        /// bytes memory _rangeBytes = bytespcpy( _source, _seek, _len );
        /// return bytescmp( _rangeBytes, _dist);
        assembly {

            if gt ( add( _begin, mload(_dist) ), mload( _source ) ) {
                return ( 0, 0 )
            }

            for { let i := _begin } lt ( i, add( _begin, mload( _dist ) ) ) { i := add( i, 32 ) }
            {
                switch gt ( add( i, 32 ), add( _begin, mload( _dist ) ) )
                case 1 {

                    let sub32BytesIsEqual := eq( mload( add( _source, add( 32, i ) ) ), mload( add( _dist, add( 32, sub( i, _begin ) ) ) ) )

                    /// 指针为0x60说明未分配内存
                    switch eq ( _isEqual, 0x60 )
                    case 1 {
                        // 未分配内存
                        _isEqual := mload( 0x40 )
                        mstore( 0x40, add( _isEqual, 32 ) )
                        mstore( _isEqual, sub32BytesIsEqual )
                    }
                    case 0 {
                        // 已分配内存
                        _isEqual := and( mload(_isEqual), sub32BytesIsEqual )
                    }

                }
                case 0 {
                    /// 最后的n个byte是否相等
                    let lastBytesnIsEqual := and( _isEqual,
                        eq(
                            div ( mload( add( _source, add( 32, i ) ) ), exp( 2, sub( 32, sub( mload(_dist), sub( i, _begin ) ) ) ) ),
                            div ( mload( add( _source, add( 32, i ) ) ), exp( 2, sub( 32, sub( mload(_dist), sub( i, _begin ) ) ) ) )
                        )
                    )

                    /// 指针为0x60说明未分配内存
                    switch eq ( _isEqual, 0x60 )
                    case 1 {
                        // 未分配内存
                        _isEqual := mload( 0x40 )
                        mstore( 0x40, add( _isEqual, 32 ) )
                        mstore( _isEqual, lastBytesnIsEqual )
                    }
                    case 0 {
                        // 已分配内存
                        _isEqual := and( mload(_isEqual), lastBytesnIsEqual )
                    }
                }
            }

        }

    }
}
