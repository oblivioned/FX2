pragma solidity >=0.5.0 <0.6.0;

library FX2_Library_Buffer
{
    struct DataPage
    {
        /// 上一页指针
        bytes32 _priv;

        /// 下一页指针
        bytes32 _next;

        /// 实际数据
        bytes   _data;
    }
    
    function privpage( DataPage memory _page ) internal pure returns ( bool _isExist ) {
        
        if ( uint(_page._priv) > 0x60 )
        {
            assembly {
                mstore( _page, mload( _page ) )
            }
            
            return true;
        }
        
        return false;
    }
    
    function nextpage( DataPage memory _page ) internal pure returns ( bool _isExist ) {
        
        if ( uint(_page._next) > 0x60 )
        {
            assembly {
                mstore( _page, mload( add( _page, 32 ) ) )
            }
            return true;
        }
        
        return false;
    }

    struct Buffer
    {
        /// [0]当前页总数
        uint256 _pageSum;
        /// [32]页大小
        uint256 _pageSize;
        /// [64]检索建立的间隔页
        uint256 _pageIndexesInv;
        /// [96]末页指针
        bytes32 _lastPage;
        /// [128]起始页指针
        bytes32 _startPage;
    }

    function append( Buffer memory _buff, uint256 _data ) internal pure returns( bytes32 r ) {

        assembly {

            function $allocate(size) -> pos {
                pos := mload( 0x40 )
                mstore( 0x40, add( pos, size ) )
            }

            let _pageSize := mload( add( _buff, 32 ) )
            let _currenPage := 0
            let _pageDataBytes := 0
    
            switch eq ( mload( _buff ), 0 )
            case 1 {
                /// 无起始页，说明没有数据，生成第一页
                _currenPage := $allocate( 96 )
                /// 申请数据段内存长度
                _pageDataBytes := $allocate( add( 32, _pageSize ) )
                mstore( add(_currenPage, 64), _pageDataBytes )
                
                /// 记录末页
                mstore( add( _buff, 96 ), _currenPage )
                
                /// 记录起始页
                mstore( add( _buff, 128), _currenPage )
                
                /// 修改数量
                mstore( _buff, 1 )
            }
            case 0 {
                _currenPage := mload( add( _buff, 96 ) )
                _pageDataBytes := mload( add ( _currenPage, 64 ) )
            }

            // if not( lt( mload( _pageDataBytes ), _pageSize ) )
            // {
            //     //此处出现大于或者等于_pageSize的情况，说明需要建立新的分页后写入
            //     /// 无起始页，说明没有数据，生成第一页
            //     let _newPage := $allocate( 96 )
            //     /// 申请数据段内存长度
            //     mstore( add(_newPage, 64), $allocate( add( 32, _pageSize ) ) )
            //     /// 当前新页面一定是此Buffer的尾页
            //     mstore( add( _buff, 128 ), _newPage )
            //     /// 修改数量
            //     mstore( _buff, add( mload(_buff), 1 ) )
            //     /// 连接节点,连接新页的上一个节点
            //     mstore( _newPage, _buff )
            //     /// 当前页的下一个节点连接
            //     mstore( add( _currenPage, 32 ), _newPage )
            //     _currenPage := _newPage
            //     _pageDataBytes := mload( add (_currenPage, 64 ) )
            // }

            //数据未满可以继续写入，由于buffer的分页必须是32的倍数，所以未满则表示一定可以在写入至少32个字节
            mstore( _pageDataBytes, add( mload( _pageDataBytes ), 32 ) )
            
            // mstore( add( _pageDataBytes, add( 32, mload( _pageDataBytes ) ) ), _data )
            
            mstore( add( _pageDataBytes, 32 ), _data )
            
            r :=  _pageDataBytes
        }
    }

    function length( Buffer memory _buff ) internal pure returns ( uint256 len ){

        // len = ( _buff._pageSum - 1 ) * ( _buff._pageSize );

        assembly {
            // len := add( len, mload( mload( add( _buff, 96 ) ) ) )
            len := mload( 220 )
        }
    }

    function get( Buffer memory _buff, uint256 _index ) internal pure returns ( bytes32 _data ) {

        /// 求出对应的下标应该在Buffer中的总偏移量
        uint256 _buffOffset = _index * 32;

        /// 求出此偏移量应该存在哪一页中
        uint256 _pageIndex = _buffOffset / _buff._pageSize;

        DataPage memory _targetPage; assembly { _targetPage := mload( add( _buff, 128) ) }

        for ( uint i = 0; i < _pageIndex; i++ )
        {
            assembly {
                _targetPage := mload( add( _targetPage, 32 ) )
            }
        }

        /// 页内偏移
        uint256 _pageOffset = _buffOffset % _buff._pageSize;
        assembly {
            // 96 = 32位上页地址 + 32位下页地址 + 32位数据长度
            _data := mload( add( _targetPage, add ( 96, _pageOffset ) ) )
        }

    }

    function getbytes( Buffer memory _buff ) internal pure returns ( bytes memory _newBytes ) {
        
        _newBytes = new bytes( length(_buff) );
    
        DataPage memory _targetPage; assembly { _targetPage := mload( add( _buff, 128) ) }
    
        uint256 _writePageIndex = 0;
        uint256 _pageSize = _buff._pageSize;
    
        do 
        {
            assembly {
                
                for { let i := 0 } lt( i, _pageSize ) { i := add( i, 32 ) }
                {
                    mstore( add( _newBytes, add( 32, mul( _writePageIndex, _pageSize ) ) ), mload( add( _targetPage, add( 96, i ) ) )  )
                }
                
            }   
            
        } while( nextpage(_targetPage) );
    
    }
    
}

contract FX2_Library_Bytes
{
    using FX2_Library_Buffer for FX2_Library_Buffer.Buffer;
    using FX2_Library_Buffer for FX2_Library_Buffer.DataPage;
    
    /// @notice 替换方法,因为替换不需要改变bytes长度，所以直接在源串中替换值，不会返回新串，在边界不合法时，方法会直接返回false
    /// @param _source : 源串
    /// @param _begin : 起始检索
    /// @param _rplcontent : 替换串
    /// @return _success : 调用结果
    function bytesset( bytes memory _source, uint _begin, bytes memory _rplcontent ) internal pure returns ( bool _success ) {

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
                    // 1.将源串需要替换的位置的数据均设置为0
                    mstore( add( _source, add( 32, i ) ), and( mload( add( _source, add( 32, i) ) ), sub ( exp( 2, mul( 8, sub( 32, mod( mload( _rplcontent ), 32 ) ) ) ), 1 ) ) )
                    // 2.由于_rplcontent最后的不足32个字节的数据存在不可预料的地位数据，需要清空低位数据后在与源串进行or拼合，此处建立一个容纳后不足32字节的副本进行操作
                    let copy := mload(0x40)
                    mstore( 0x40, add( copy, 32 ) )
                    // 3.取出最后32字节数据,取出的结果在低位,需要移动到高位对其，实际就是左移，右端补0
                    mstore( copy, mul( mload( add( _rplcontent, mload( _rplcontent ) ) ), exp( 2, mul( 8, sub( 32, mod( mload( _rplcontent ), 32 ) ) ) ) ) )
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
        _new = new bytes( _bytes1.length + _bytes2.length );

        bytesset( _new, 0, _bytes1 );
        bytesset( _new, _bytes1.length, _bytes2);
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

contract BytesTest is FX2_Library_Bytes
{
    function Test() public pure returns ( uint256 len, bytes memory _ret, bytes32 r)
    {
        FX2_Library_Buffer.Buffer memory _buffer = FX2_Library_Buffer.Buffer(0, 255, 0, 0, 0 );
        
        r = _buffer.append( 0xAAAAAAAAAAAAAAAAAAAA00000000000000000000000000000000000000000000 );
        // _buffer.append( 0xBBBBBBB );
        // _buffer.append( 0xEEEEE );
        // _buffer.append( 0xAAAAA );
        
        len = _buffer.length();
        // _ret = _buffer.getbytes();
        
        // assembly {
        //     // mstore(  )
        //     _ret := 0x0
        //     mstore( _ret, 1024 )
        // }
        
    }
}
