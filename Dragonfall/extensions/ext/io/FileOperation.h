#ifndef __HELLOWORLD_FILE_OPERATION__
#define __HELLOWORLD_FILE_OPERATION__

#include <stdlib.h>

class FileOperation 
{
public:
    static bool createDirectory(std::string path);
    static bool removeDirectory(std::string path);
    static bool copyFile(std::string from, std::string to);
};

#endif
