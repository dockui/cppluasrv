#ifndef __LVM__
#define __LVM__
#include <string>
#include <map>
#include <queue>
#include <boost/bind.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/enable_shared_from_this.hpp>
#include <boost/asio.hpp>
#include <boost/thread.hpp>
#include <boost/thread/mutex.hpp>

extern "C"  
{  
    #include "lua.h"  
    #include "lauxlib.h"  
    #include "lualib.h"  
}

#include "timer.h"

enum LVM_CMD{
    LVM_CMD_CREATLVM = 0,
    LVM_CMD_SETTIMER = 1, 
    LVM_CMD_ONTIMER = 2,
    LVM_CMD_KILLTIMER = 3,
    LVM_CMD_HTTP_REQ = 4,
    LVM_CMD_HTTP_RESP = 5

};

struct LVM_MSG{
    uint64_t id;
    int dest;
    int cmd;
    char *msg;
    int len;
    LVM_MSG():id(0),
        dest(0),
        cmd(0),
        msg(NULL),
        len(0){
    }
    ~LVM_MSG(){
        if (msg) {
            delete []msg;
            msg = NULL;
        }
    }
};

class LVM :
    public CAsyncTimer,
    public boost::enable_shared_from_this<LVM>
{
public:
    LVM(int id, const std::string &file, boost::asio::io_service *io_service): _id(id), in_global(0),
        CAsyncTimer(io_service)
    
    { 
        L = NULL;
        m_file = file;   
    }
    ~LVM(){  
        UnInit();
    }

    bool Init();
    void UnInit();

    int AddMsg(LVM_MSG *pMsg);
    LVM_MSG * GetMsg();

    bool Dispatch(int cmd, char*msg, int len);

protected:
    virtual void OnTimer(int iTimerID, const boost::system::error_code& error);

private:
    int _id;
    lua_State *L;

    std::string m_file;

    boost::mutex m_lockQueue;
    std::queue<LVM_MSG *> localMsgQueue;
    int in_global;
};

class LvmMgr{
public: 
    LvmMgr():_gen_id(0),
             io_service(NULL),
             _lvmMain(NULL)
    {    

    }
    ~LvmMgr(){    
    }

    static LvmMgr* getInstance(){
        static LvmMgr instance;
        return &instance;
    }

    bool Init();

protected:
    boost::asio::io_service *io_service;
    boost::asio::io_service::work *io_work;

public:
    uint64_t PostMsg(int dest, int cmd, char *msg, int len);

protected:
    void _PostMsg(LVM_MSG *pMsg);
    int ProcessMsg();

public:
    int SetTimer(int lvmid, int iTimerID, int iElapse, int once);
    int _CreateLvm(const std::string &file);
    bool _RemoveLvm(int id);
    boost::shared_ptr<LVM> GetLVM(int id);

protected:
    int _SetTimer(int lvmid, int iTimerID, int iElapse, int once);

protected:
    void AddToGlobal(boost::shared_ptr<LVM> lvm);
    boost::shared_ptr<LVM> NextGlobal();

protected:
    int _gen_id;
    boost::shared_ptr<LVM> _lvmMain;
    std::map<int, boost::shared_ptr<LVM>> mapLvm;
    
    boost::mutex m_lockGlobalMsgQueue;
    std::queue<boost::shared_ptr<LVM>> globalMsgQueue;
};

#endif
