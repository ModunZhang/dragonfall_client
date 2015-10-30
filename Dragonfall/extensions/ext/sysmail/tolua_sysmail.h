//
//  ext_sysmail.h
//  kod
//
//  Created by DannyHe on 1/5/15.
//
//

#ifndef __kod__ext_sysmail__
#define __kod__ext_sysmail__

#include <string>
#include <stdlib.h>
#include "tolua++.h"


#define EXT_MODULE_NAME_SYSMAIL "sysmail"

void OnSendMailEnd(int function_id,std::string event);

void tolua_ext_module_sysmail(lua_State* tolua_S);

#endif /* defined(__kod__ext_sysmail__) */
