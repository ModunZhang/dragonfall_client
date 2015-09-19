//
//  CZlib.cpp
//  CompressETCTexture
//
//  Created by DannyHe on 9/16/15.
//  Copyright (c) 2015 DannyHe. All rights reserved.
//

#include "ETCCompress.h"

#include <iostream>
#include <stdlib.h>
#include "StreamHelper.h"
using namespace std;

struct ZipHeaderInfo
{
    int fileSize;
    int flag;
};


bool ETCCompress::checkETCFlag(int flag)
{
    return flag == ETC_HEADER_FLAG;
}

bool ETCCompress::checkETCIsCompressed(const char *filePath)
{
    return false;
}


int ETCCompress::compressETC(const char * destpath,const char *srcpath)
{
    ZipHeaderInfo zipHeader;
    
    FILE* inFile = fopen(srcpath, "rt");
    
    if(!inFile)
    {
        return -1;
    }
    
    fseek(inFile, 0, SEEK_END);
    int fileSize = ftell(inFile);
    char * fileData = new char[fileSize];
    fseek(inFile, 0, SEEK_SET);
    fread(fileData, 1, fileSize, inFile);
    fclose(inFile);
    
    zipHeader.fileSize = fileSize;
    zipHeader.flag = ETC_HEADER_FLAG;
    
    
    uLongf destLength = compressBound(fileSize);

    Bytef* pDestBuf = new Bytef[destLength];
    int result = compress2(pDestBuf , &destLength, (const Bytef*)fileData, fileSize,9);
    if (result != Z_OK)
    {
        switch(result)
        {
            case Z_MEM_ERROR:
                printf("note enough memory for compression");
                break;
                
            case Z_BUF_ERROR:
                printf("note enough room in buffer to compress the data");
                break;
        }
        return -1;
    }
    
    
    StreamHelper steamCompHeader(16*1024);
    steamCompHeader.WriteInt(zipHeader.flag);
    steamCompHeader.WriteInt(zipHeader.fileSize);
    
    cout << "ETCCompress:: orignal size: " << fileSize
    << " , compressed size : " << destLength
    << " , header size: " << steamCompHeader.GetLength()
    << " , final size : " << steamCompHeader.GetLength() + destLength
    << " compress ratio:" << (1 - (double)(steamCompHeader.GetLength() + destLength)/fileSize)*100 << "%"
    << '\n';
    
    
    FILE* fo = fopen(destpath, "wb");
    if(fo)
    {
        fwrite(steamCompHeader.GetDataPtr(), steamCompHeader.GetLength(), 1, fo);
        fwrite(pDestBuf,destLength, 1, fo);
        fclose(fo);
        delete [] pDestBuf;
        
        return 0;
    }
    return 0;
}

uLongf ETCCompress::unCompressETC(const char * packData,int packSize,Bytef* &buff)
{
    StreamHelper steamPakHeader(packData,packSize,true);
    int flag = steamPakHeader.ReadInt();
    if (!ETCCompress::checkETCFlag(flag)) {
        printf("error: header error");
        return -1;
    }
    int orginSize = steamPakHeader.ReadInt();
    int headerSize = sizeof(ZipHeaderInfo);
    uLongf newSize = orginSize;
    Bytef* pUnBuf = new Bytef[newSize];
    int result2 = uncompress(pUnBuf, &newSize,(const Bytef*)steamPakHeader.GetDataPtr() + headerSize,packSize - headerSize);
    if (result2 != Z_OK)
    {
        switch(result2)
        {
            case Z_MEM_ERROR:
                printf("note enough memory for uncompression");
                break;
                
            case Z_BUF_ERROR:
                printf("note enough room in buffer to uncompress the data");
                break;
        }
        return -1;
    }
    buff = pUnBuf;
    cout << "orignal size: " << packSize
    << " , ucompressed size : " << orginSize << '\n';
    return newSize;
}

int ETCCompress::unCompressETC(const char *destpath, const char *srcpath)
{
    FILE* packFile = fopen(srcpath, "rt");
    
    fseek(packFile, 0, SEEK_END);
    int packSize = ftell(packFile);
    char * packData = new char[packSize];
    fseek(packFile, 0, SEEK_SET);
    fread(packData, 1, packSize, packFile);
    fclose(packFile);
    Bytef* pUnBuf;
    uLongf newSize = unCompressETC(packData,packSize,pUnBuf);
    if (newSize == -1)
    {
        printf("error!");
        return -1;
    }
    
    FILE* ft = fopen(destpath, "wb");
    if(ft)
    {
        fwrite(pUnBuf,newSize, 1, ft);
        fclose(ft);
        delete [] pUnBuf;
        return 0;
    }

    return -1;
}