
#ifndef __APP__
#define __APP__

#include <boost/lockfree/queue.hpp> 
#include <boost/lockfree/policies.hpp>
#include<map>
#include<queue>
#include "lvm.h"

class App{
public:
    App(){

    }
    ~App(){

    }

    bool Run();

    static boost::thread_group worker_threads;

protected:
    static void Work();

protected:
    boost::shared_ptr< boost::asio::io_service > io_service_file;
    boost::shared_ptr< boost::asio::io_service::work > work_file;



};

extern App app;
#endif