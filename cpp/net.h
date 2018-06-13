#ifndef WS_WORK
#define WS_WORK

#include <string>

#include <boost/bind.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/enable_shared_from_this.hpp>
#include <boost/asio.hpp>
#include <boost/thread.hpp>
#include <boost/thread/mutex.hpp>

class NET
{
public:
    NET() {    
    }
    ~NET(){    
    }

    static NET* getInstance(){
        static NET instance;
        return &instance;
    }

    bool Start();

    bool HttpReq(int idlvm, int sid, const std::string & method, 
        const std::string &host,
        const std::string &path, 
        const std::string &params);

    bool SendClient(int wid, const char *msg, int len);
    
protected:
    static void ws_work();

    bool _HttpReq(int idlvm, int sid, const std::string & method, 
        const std::string &host,
        const std::string &path, 
        const std::string &params);

    static uint32_t AllocId();

    static boost::mutex m_lockWSConn;
    static std::map<uint32_t, void*> mapWSConn;
    static uint32_t _WS_GEN_ID;

private:
    boost::shared_ptr< boost::asio::io_service > io_service_net;
    boost::shared_ptr< boost::asio::io_service::work > work_net;

    

};


#endif
