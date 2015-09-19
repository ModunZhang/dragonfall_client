//
//  StreamHelper.cpp
//  CompressETCTexture
//
//  Created by DannyHe on 9/16/15.
//  Copyright (c) 2015 DannyHe. All rights reserved.
//

#include "StreamHelper.h"

////////////////////////////////////////////////////////////////////////////////////////////////////

StreamHelper::StreamHelper(int iInitialSize)
{
    m_size		=	iInitialSize;
    m_length	=	0;
    m_pos		=	0;
    m_stream	=	new char[m_size];
}

StreamHelper::StreamHelper(const void* dataPtr, unsigned int dataSize, bool ownData)
{
    m_size	=	ownData ? dataSize : 0;
    m_length	=	dataSize;
    m_pos		=	0;
    m_stream	=	(char*)dataPtr;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

StreamHelper::~StreamHelper()
{
    if(m_stream && m_size)
    {
        delete[] m_stream;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

void StreamHelper::Reset()
{
    m_pos = 0;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

void StreamHelper::Allocate(int iSize)
{
    if(m_stream)
    {
        delete[] m_stream;
    }
    
    m_size		=	iSize;
    m_stream	=	new char[m_size];
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////

void StreamHelper::Resize()
{
    
    char* pOldStream = m_stream;
    
    m_stream = new char[2 * m_size];
    memcpy(m_stream, pOldStream, m_size);
    
    m_size = 2 * m_size;
    
    if(pOldStream)
    {
        delete[] pOldStream;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

void StreamHelper::WriteChar(char val)
{
    if(m_size - m_pos < sizeof(char))
    {
        Resize();
    }
    
    m_stream[m_pos++] = val;
    
    if(m_pos > m_length)
    {
        m_length = m_pos;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

char StreamHelper::ReadChar()
{
    char val;
    
    if(m_size - m_pos < sizeof(char))
    {
        return 0;
    }
    
    val = m_stream[m_pos++];
    
    return val;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

void StreamHelper::WriteShort(short val)
{
    if(m_size - m_pos < sizeof(short))
    {
        Resize();
    }
    
    m_stream[m_pos++] = val & 0xFF;//(val >> 8) & 0xFF;
    m_stream[m_pos++] = (val >> 8) & 0xFF;//val & 0xFF;
    
    if(m_pos > m_length)
    {
        m_length = m_pos;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

short StreamHelper::ReadShort()
{
    short val;
    
    if(m_size - m_pos < sizeof(short))
    {
        return 0;
    }
    
    val		=	m_stream[m_pos++] & 0xFF;//(m_stream[m_pos++] & 0xFF) << 8;
    val		|=	(m_stream[m_pos++] & 0xFF) << 8;//m_stream[m_pos++] & 0xFF;
    
    return val;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

void StreamHelper::WriteInt(int val)
{
    if(m_size - m_pos < sizeof(int))
    {
        Resize();
    }
    
    /*m_stream[m_pos++] = (val >> 24) & 0xFF;
     m_stream[m_pos++] = (val >> 16) & 0xFF;
     m_stream[m_pos++] = (val >> 8) & 0xFF;
     m_stream[m_pos++] = val & 0xFF;*/
    
    m_stream[m_pos++] = val & 0xFF;
    m_stream[m_pos++] = (val >> 8) & 0xFF;
    m_stream[m_pos++] = (val >> 16) & 0xFF;
    m_stream[m_pos++] = (val >> 24) & 0xFF;
    
    if(m_pos > m_length)
    {
        m_length = m_pos;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

int StreamHelper::ReadInt()
{
    int val;
    
    if(m_size - m_pos < sizeof(int))
    {
        return 0;
    }
    
    /*val		=	(m_stream[m_pos++] & 0xFF) << 24;
     val		|=	(m_stream[m_pos++] & 0xFF) << 16;
     val		|=	(m_stream[m_pos++] & 0xFF) << 8;
     val		|=	(m_stream[m_pos++] & 0xFF);*/
    
    val		=	(m_stream[m_pos++] & 0xFF);
    val		|=	(m_stream[m_pos++] & 0xFF) << 8;
    val		|=	(m_stream[m_pos++] & 0xFF) << 16;
    val		|=	(m_stream[m_pos++] & 0xFF) << 24;
    
    return val;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

void StreamHelper::WriteFloat(float val)
{
    if(m_size - m_pos < sizeof(float))
    {
        Resize();
    }
    int& ival = *((int*)&val);
    
    /*m_stream[m_pos++] = (ival >> 24) & 0xFF;
     m_stream[m_pos++] = (ival >> 16) & 0xFF;
     m_stream[m_pos++] = (ival >> 8) & 0xFF;
     m_stream[m_pos++] = ival & 0xFF;*/
    
    m_stream[m_pos++] = ival & 0xFF;
    m_stream[m_pos++] = (ival >> 8) & 0xFF;
    m_stream[m_pos++] = (ival >> 16) & 0xFF;
    m_stream[m_pos++] = (ival >> 24) & 0xFF;
    
    
    if(m_pos > m_length)
    {
        m_length = m_pos;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

float StreamHelper::ReadFloat()
{
    float val;
    int& ival = *((int*)&val);
    
    if(m_size - m_pos < sizeof(int))
    {
        return 0;
    }
    
    /*ival		=	(m_stream[m_pos++] & 0xFF) << 24;
     ival		|=	(m_stream[m_pos++] & 0xFF) << 16;
     ival		|=	(m_stream[m_pos++] & 0xFF) << 8;
     ival		|=	(m_stream[m_pos++] & 0xFF);*/
    
    ival		=	(m_stream[m_pos++] & 0xFF);
    ival		|=	(m_stream[m_pos++] & 0xFF) << 8;
    ival		|=	(m_stream[m_pos++] & 0xFF) << 16;
    ival		|=	(m_stream[m_pos++] & 0xFF) << 24;
    
    
    return val;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

void StreamHelper::WriteString(const std::string& val)
{
    short length = val.length();
    WriteShort(length);
    
    if(length > 0)
    {
        if(m_size - m_pos < length)
        {
            Resize();
        }
        
        memcpy(&m_stream[m_pos], val.c_str(), length);
        m_pos += length;
        
        
        if(m_pos > m_length)
        {
            m_length = m_pos;
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

void StreamHelper::ReadString(std::string& val)
{
    short length = ReadShort();
    
    val = "";
    
    if(length > 0)
    {
        val.append(m_stream[m_pos], length);
        m_pos += length;
    }
}

