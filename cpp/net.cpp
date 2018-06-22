
#include "net.h"
#include "stdafx.h"
#include "app.h"
#include "uWS.h"
#include <iostream>
#include "lvm.h"

#include "third/Simple-Web-Server/client_http.hpp"
// using HttpServer = SimpleWeb::Server<SimpleWeb::HTTP>;
using HttpClient = SimpleWeb::Client<SimpleWeb::HTTP>;

boost::mutex NET::m_lockWSConn;
std::map<uint32_t, void*> NET::mapWSConn;
uint32_t NET::_WS_GEN_ID = 0;

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
  
uint32_t NET::AllocId()
{
    if (_WS_GEN_ID >= 0xFFFFFFFF){
        _WS_GEN_ID = 0;
    }
    while (true){
        uint32_t id = ++_WS_GEN_ID;
        if (mapWSConn.end() == mapWSConn.find(id)){
            return id;
        }
    }
    //unreachable
    return -1;
}

bool NET::SendClient(int wid, const char *msg, int len)
{
    boost::mutex::scoped_lock lock(m_lockWSConn);
    std::map<uint32_t, void*>::iterator it = mapWSConn.find(wid);
    if (it != mapWSConn.end()){
        ((uWS::WebSocket<uWS::SERVER> *)it->second)->send(msg, len, uWS::OpCode::TEXT, nullptr, nullptr, true);
        return true;
    }
    return false;
}
  
void NET::ws_work() {
    uWS::Hub h;

    
    h.onConnection([&h](uWS::WebSocket<uWS::SERVER> *ws, uWS::HttpRequest req) {
        std::cout << "onConnection:" << (void*)ws << std::endl;

        boost::mutex::scoped_lock lock(m_lockWSConn);
        uint32_t id = AllocId();
        ws->setUserData((void*)(uint64_t)id);
        mapWSConn[id] = ws;
    });

    h.onMessage([&h](uWS::WebSocket<uWS::SERVER> *ws, char *message, size_t length, uWS::OpCode opCode) {
        std::cout << "onMessage:" << (void*)ws << std::endl;

        boost::mutex::scoped_lock lock(m_lockWSConn);
        uint32_t id = (uint32_t)(uint64_t)ws->getUserData();
        // ws->send(message, length, opCode, nullptr, nullptr, true);
        LvmMgr::getInstance()->PostMsg(
            0, id, LVM_CMD_CLIENT_MSG, message, length);
    });

    h.onDisconnection([&h](uWS::WebSocket<uWS::SERVER> *ws, int code, char *message, size_t length) {
        std::cout << "onDisconnection:" << (void*)ws << std::endl;

        boost::mutex::scoped_lock lock(m_lockWSConn);
        uint32_t id = (uint32_t)(uint64_t)ws->getUserData();
        std::map<uint32_t, void*>::iterator it = mapWSConn.find(id);
        if (it != mapWSConn.end()){
            mapWSConn.erase(it);
        }
    });

    h.listen(3000);
    h.run();


}

bool NET::HttpReq(int idlvm, int sid, const std::string & method, 
    const std::string &host,
    const std::string &path, 
    const std::string &params)
{
    io_service_net->post(boost::bind(&NET::_HttpReq, this, 
        idlvm, sid, method, host, path, params));
    return true;
}

bool NET::_HttpReq(int idlvm, int sid, const std::string & method, 
    const std::string &host,
    const std::string &path, 
    const std::string &params)
{
    HttpClient client(host.c_str());
    std::string ret;
    std::string status;
    try {

        auto r1 = client.request(method.c_str(), path.c_str(), params.c_str());
        // std::cout << r1->content.rdbuf() << std::endl; 
        status = r1->status_code;

        ret = r1->content.string();

        // std::cout <<o ret.size() << ";==" << ret << std::endl; 

        // LvmMgr::getInstance()->PostMsg(
        //     idlvm, sid, LVM_CMD_HTTP_RESP, ret.c_str(), ret.length());
    }
    catch(const SimpleWeb::system_error &e) {
        std::cerr << "Client request error: " << e.what() << std::endl;
        status = e.what();
    }

    if (ret.length() <= 0)
    {
        ret = "fail:" + status;
    }
    
    LvmMgr::getInstance()->PostMsg(
        idlvm, sid, LVM_CMD_HTTP_RESP, ret.c_str(), ret.length());
        
    return true;
}
