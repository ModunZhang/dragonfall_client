#pragma once
#ifndef SysmailWinRT_h
#define SysmailWinRT_h

bool CanSenMail();
bool SendMail(std::string to, std::string subject, std::string body, int lua_function_ref);
#endif
