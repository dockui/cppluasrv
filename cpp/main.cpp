#include "uWS.h"

#include "stdafx.h"

#include "app.h"
// extern "C"  
// {  
//     #include "lua.h"  
//     #include "lauxlib.h"  
//     #include "lualib.h"  
// }  


 
INITIALIZE_EASYLOGGINGPP
void rolloutHandler(const char* filename, std::size_t size)
{
    static unsigned int idx = 0;
    std::stringstream stream;
    stream << filename << "." << ++idx;
    rename(filename, stream.str().c_str());
}
 

int main( int argc, char * argv[] )
{
    START_EASYLOGGINGPP(argc, argv);
    el::Loggers::addFlag(el::LoggingFlag::StrictLogFileSizeCheck);
    el::Configurations conf("log.conf");
    el::Loggers::reconfigureAllLoggers(conf);
    el::Helpers::installPreRollOutCallback(rolloutHandler);
    
    LOG(INFO) << "xiaohei server start ...";

    app.Run();

    el::Helpers::uninstallPreRollOutCallback();
    return 0;
}