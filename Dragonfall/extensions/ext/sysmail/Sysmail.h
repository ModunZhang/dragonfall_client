//
//  Sysmail.h
//  kod
//
//  Created by DannyHe on 1/5/15.
//
//

#ifndef kod_Sysmail_h
#define kod_Sysmail_h
#include <string>
#include <stdlib.h>

bool CanSenMail();

bool SendMail(std::string to,std::string subject,std::string body,int lua_function_ref);

#endif
