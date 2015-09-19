//
//  StreamHelper.h
//  CompressETCTexture
//
//  Created by DannyHe on 9/16/15.
//  Copyright (c) 2015 DannyHe. All rights reserved.
//

#ifndef __CompressETCTexture__StreamHelper__
#define __CompressETCTexture__StreamHelper__

#include <string>

class StreamHelper
{
public:
    StreamHelper(int iInitialSize = 1024);
    ~StreamHelper();
    StreamHelper(const void* dataPtr, unsigned int dataSize, bool ownData = false);
    void	Reset();
    void	Allocate(int iSize);
    
    void		SetLength(int length)	{	m_length = length;	}
    int			GetLength()	const		{	return m_length;	}
    int			GetSize()	const		{	return m_size;		}
    const char*	GetData()	const		{	return m_stream;	}
    char*		GetDataPtr()			{	return m_stream;	}
    
    void	WriteChar(char val);
    void	WriteShort(short val);
    void	WriteInt(int val);
    void	WriteFloat(float val);
    void	WriteString(const std::string& val);
    
    char	ReadChar();
    short	ReadShort();
    int		ReadInt();
    float	ReadFloat();
    void	ReadString(std::string& val);
    
    
protected:
    char*	m_stream;
    int		m_size;
    int		m_length;
    int		m_pos;
    void	Resize();
};

#endif /* defined(__CompressETCTexture__StreamHelper__) */
