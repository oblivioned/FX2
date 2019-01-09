pragma solidity >=0.5.0 <0.6.0;

library FX2_Schema {

    struct FieldsDOM {

        bytes32[] name;

        uint[]    len;

    }

    /// 获取字段在数据DOM中的偏移和长度
    function GetFieldOffset( FieldsDOM memory _dom, bytes32 _fieldname )
    internal
    pure
    returns ( uint offset, uint len )
    {
        for ( uint i = 0; i < _dom.name.length; i++ )
        {
            if ( _dom.name[i] == _fieldname )
            {
                len = _dom.len[i];
                break;
            }
            else
            {
                offset += _dom.len[i];
            }
        }

        return ( offset, len );
    }

    struct Table {

        bytes32     name;

        FieldsDOM   dom;

        bytes[]     records;

        uint        total;
    }

    struct Response {

        uint8 code;

        string message;

        uint affected;

    }

    struct QueryResponse {

        uint8   code;

        string  message;

        uint    affected;

        bytes[] datas;

    }

    function InitTable( Table storage _tb, bytes32 _name, FieldsDOM memory _dom ) internal returns ( Response memory response )
    {
        _tb.name = _name;
        _tb.dom = _dom;
        _tb.total = 0;

        return Response(0x0, "Success:InitTable Success.", 0);
    }

    function InsertInto( Table storage _tb, bytes memory _data ) internal returns ( Response memory response )
    {
        bytes memory _rawDats;

        uint256 pkIndex = _tb.total + 1;

        assembly {

            // 分配内存
            // rawdata结构
            // 0-31     rawdata的长度
            // 32-33    存储状态：0 正常状态 1 已经删除的状态
            // 34-63    自增加ID主键（由于存储删除状态用掉1个bit，所以实际上这里是 uint255）
            // 64-95    数据bytes的长度
            // 96-end   真实数据
            let rawSize := add( 64, mload( _data ) )

            _rawDats := mload(0x40)
            mstore(0x40, add( _rawDats, rawSize ))

            let writeoffset := _rawDats
            let writeend := add( writeoffset, rawSize )

            // 写入rawdata的长度
            mstore( writeoffset, mload(rawSize) )
            writeoffset := add(writeoffset, 32)

            // 写入存储状态和主键,由于使用0表示正常状态，所以此处无需手动写入第1位
            mstore( writeoffset, mload(pkIndex) )
            writeoffset := add(writeoffset, 32)

            // 写入data的bytes长度
            mstore( writeoffset, mload( _data ) )
            writeoffset := add(writeoffset, 32)

            if gt( mload(_data), 32 )
            {
                // 32字节为步长进行数据拷贝
                for { let i := 0 }
                    lt( i, mload(_data) )
                    { i := add(i, 32) }
                    {
                        mstore( writeoffset, mload( add(add( mload(_data), 32 ), i ) ) )
                        writeoffset := add(writeoffset, 32)
                    }
            }

            // 进行最后32个字节的拷贝,如果数据总长度小于32为，同样可以使用下面的代码进行拷贝
            // mload( add(_data, mload( _data ))) ：
            // 逻辑本来应该是 mload( sub(add(add(_data, 32),mload(_data))), 32 )
            // 但是是进行最后32位的拷贝，所以去掉了+32 和-32的过程简化而来
            if lt( writeoffset, writeend ) {
                mstore( sub(writeend, 32), mload( add(_data, mload( _data ))) )
            }
        }

        _tb.records.push(_rawDats);
        _tb.total++;
        return Response(0x0, "Success:InsertInto Success.", 1);
    }

    function Select( Table storage _fromTable, bytes32 _whereField, bytes memory _equalValue )
    internal
    returns ( QueryResponse memory response )
    {
        ( uint offset, uint len ) = GetFieldOffset( _fromTable.dom, _whereField );
        
        if ( len == 0 )
        {
            return QueryResponse( 0xE0, "ERROR(0xE0):WhereField Notfound.", 0, new bytes[](0) );
        }
        
        bytes32[] memory rawDataMemPoints = new bytes32[](8);
        
        for ( uint i = 0; i < _fromTable.records.length; i++ )
        {
            bytes memory rawData = _fromTable.records[i];
            
            bytes memory fieldValue;
            
            assembly {
                
                function $allocate(size) -> pos {
                    pos := mload(0x40)
                    mstore(0x40, add(pos, size))
                }
                
                function $bsc( source, offset, size ) -> dist {
                    
                    dist := $allocate( add(size, 32) )
                    mstore( dist, size )
                    
                    if or ( eq( size, 32 ), lt( size, 32) ) {
                        mstore( add(dist, 32), and( mload( add(source, add(32, offset))), not(exp(2, sub(32, size))) ))
                    }
                    
                    if gt( size, 32 ) {
                        for {let i := 0}
                            lt(i, size)
                            {mstore(i, add(i, 32))}
                        {
                            mstore( add(dist, add(32,i)), mload(add(source, add(32, i))) )
                        }
                        
                        mstore( add(dist, mload(dist)), and(mload(add(source, mload(source))), not(exp(2, sub(32,size)))) )
                    }
                }
                
                function $bseq( a, b ) -> iseq {
                    
                    switch or ( lt( mload(a), 32 ), eq( mload(b), 32 ) )
                    case 1 {
                        if and( 
                            eq( mload(a), mload(b)),
                            eq( mload( add(a, 32) ), mload( add(b, 32)))
                            )
                        {
                            iseq := 1
                        }
                    }
                    
                    case 0 {
                        
                        iseq := eq( mload(a), mload(b) )
                        
                        if mload(iseq) {
                            for {let i := 0}
                                lt( i, mload(a) )
                                {i := add(i, 32)}
                            {
                                iseq := and( mload(iseq), eq( mload( add(add( a, 32 ), i)), mload(add(add( b, 32 ), i))))
                            }
                            
                            if mload(iseq) {
                                iseq := and( mload(iseq), eq( mload(add(a, mload(a))), mload(add(b,mload(b)))))
                            }
                        }
                    }
                }
                
                
                fieldValue := mload(0x40)
                mstore( 0x40, add( fieldValue, mload( len ) ) )
                
                mstore( fieldValue, mload(len) )
                
                mstore( add(fieldValue, 32), mload( add( rawData, add( 32, mload( offset ) ))))
                
                fieldValue := div( mload( add(fieldValue, 32 ) ), exp(2, sub( 256, mul(mload(len), 8) ) )) 
                
                // if eq( mload(fieldValue), mload(_equalValue) ){
                //     mstore( datas, add(mload(_datas), 1 ) )
                // }
            }
        }
    }

}
