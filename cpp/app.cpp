#include "stdafx.h"
#include "app.h"


#include "net.h"

boost::mutex global_stream_lock;

// void Post( int i)
// {
//     boost::shared_ptr<LVM> sp_lvm = 
//         boost::make_shared<LVM>("main.lua"); 

//     sp_lvm->Init();
//     sp_lvm->Dispatch(i,"hel放大lo");
// }

App app;
boost::thread_group App::worker_threads;

bool App::Run()
{
    LOG(INFO) << "App::Run() start.";

    NET::getInstance()->Start();
    
    LvmMgr::getInstance()->Init();
    
    io_service_file.reset(new boost::asio::io_service());
    work_file.reset(new boost::asio::io_service::work( *io_service_file ));
  
    // io_service_net.reset(new boost::asio::io_service());
    // work_net.reset(new boost::asio::io_service::work( *io_service_net ));
  
    // //file work
    // for( int x = 0; x < 1; ++x )
    // {
    //     worker_threads.create_thread( 
    //         boost::bind( &boost::asio::io_service::run, io_service_file ) );
    // }

    // //net work
    // for( int x = 0; x < 1; ++x )
    // {
    //     worker_threads.create_thread( 
    //         boost::bind( &boost::asio::io_service::run, io_service_net ) );
    // }  
 
    //ws work


    worker_threads.join_all();

    return true;
}

void App::Work()
{

}

