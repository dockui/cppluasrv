#include "net.h"
#include "app.h"
#include "uWS.h"
#include <iostream>

#include "third/Simple-Web-Server/client_http.hpp"
// using HttpServer = SimpleWeb::Server<SimpleWeb::HTTP>;
using HttpClient = SimpleWeb::Client<SimpleWeb::HTTP>;


bool NET::Start()
{
    io_service_net.reset(new boost::asio::io_service());
    work_net.reset(new boost::asio::io_service::work( *io_service_net ));

    //net work
    for( int x = 0; x < 1; ++x )
    {
        App::worker_threads.create_thread( 
            boost::bind( &boost::asio::io_service::run, io_service_net ) );
    }  

    App::worker_threads.create_thread(boost::bind(&NET::ws_work));
 
    return true;
}
  
void NET::ws_work() {
    uWS::Hub h;

    
    h.onConnection([&h](uWS::WebSocket<uWS::SERVER> *ws, uWS::HttpRequest req) {
        std::cout << "onConnection:" << (void*)ws << std::endl;


    });

    h.onMessage([&h](uWS::WebSocket<uWS::SERVER> *ws, char *message, size_t length, uWS::OpCode opCode) {
        std::cout << "onMessage:" << (void*)ws << std::endl;

        ws->send(message, length, opCode, nullptr, nullptr, true);

    });

    h.onDisconnection([&h](uWS::WebSocket<uWS::SERVER> *ws, int code, char *message, size_t length) {
        std::cout << "onDisconnection:" << (void*)ws << std::endl;

    });

    h.listen(3000);
    h.run();


}

bool NET::HttpReq(const std::string & method, 
    const std::string &host,
    const std::string &path, 
    const std::string &params)
{
    io_service_net->post(boost::bind(&NET::_HttpReq, this, 
        method, host, path, params));
    return true;
}

bool NET::_HttpReq(const std::string & method, 
    const std::string &host,
    const std::string &path, 
    const std::string &params)
{
    HttpClient client(host.c_str());
    std::string ret;
    try {

        auto r1 = client.request(method.c_str(), path.c_str(), params.c_str());
        // std::cout << r1->content.rdbuf() << std::endl; 
        std::string strCode = r1->status_code;

        ret = r1->content.string();

        std::cout << ret.size() << ";==" << ret << std::endl; 
    }
    catch(const SimpleWeb::system_error &e) {
        std::cerr << "Client request error: " << e.what() << std::endl;
    }

    return true;
}
