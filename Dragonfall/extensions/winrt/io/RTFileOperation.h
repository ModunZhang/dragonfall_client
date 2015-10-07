#pragma once
class RTFileOperation
{
public:
	RTFileOperation();
	static bool createDirectory(std::string  path);
	static bool removeDirectory(std::string path);
	static bool copyFile(std::string from, std::string to);
};