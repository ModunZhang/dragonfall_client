//
//  CZlib.h
//  CompressETCTexture
//
//  Created by DannyHe on 9/16/15.
//  Copyright (c) 2015 DannyHe. All rights reserved.
//

#ifndef __CompressETCTexture__CZlib__
#define __CompressETCTexture__CZlib__
#define ETC_HEADER_FLAG 0x12f8352
#include "zlib.h"

class ETCCompress
{
public:
    ETCCompress();
    ~ ETCCompress();
    static int compressETC(const char * destpath,const char *srcpath);
    static int unCompressETC(const char * destpath,const char *srcpath);
    static uLongf unCompressETC(const char * packData,int packSize,Bytef* &buff);
    static bool checkETCFlag(int flag);
    static bool checkETCIsCompressed(const char * filePath);
};

#endif /* defined(__CompressETCTexture__CZlib__) */
