#include "lvm.h"
#include "app.h"
#include "net.h"

#include <iostream>
using namespace std;

static const char UKey = 'k';
static int luaInterface(lua_State *L)  
{
    std::cout << "luaInterface:" << boost::this_thread::get_id() << "\n";

    int n = lua_gettop(L);  
    int method = lua_tonumber(L, 1); 
    
    lua_pushlightuserdata(L, (void *)&UKey); 
    lua_gettable(L, LUA_REGISTRYINDEX); 
    int idlvm = lua_tonumber(L, -1); 
    lua_pop(L, 1);

    switch(method){
        case LVM_CMD_CREATLVM: //create lvm
        {
            const char *pLuaFile = lua_tostring(L, 2);

            int ret = LvmMgr::getInstance()->_CreateLvm(pLuaFile);
            lua_pushnumber(L, ret);  
            return 1;  
        }
        break;
        case LVM_CMD_SETTIMER: //settimer
        {
            int timeid = lua_tonumber(L, 2);
            int elapse = lua_tonumber(L, 3);
            int once = 1;
            if (n > 3) {
                once = lua_tonumber(L, 4);
            }

            int ret = LvmMgr::getInstance()->SetTimer(idlvm, timeid, elapse, once);
            lua_pushnumber(L, ret);  
            return 1;  
        }
        break;  
        case LVM_CMD_HTTP_REQ:
        {
            std::string strMethod = lua_tostring(L, 2);
            std::string strHost = lua_tostring(L, 3);
            std::string strpath;
            if (n > 3) {
                strpath = lua_tostring(L, 4);
            }

            std::string strParams;
            if (n > 4) {
                strParams = lua_tostring(L, 5);
            }

            NET::getInstance()->HttpReq(strMethod, strHost, strpath, strParams);
        }   
        break; 
        default: 
        break;
    }
    int ret = 0;
    lua_pushnumber(L, ret);  
    return 1;  
}  

bool LVM::Init()
{
     //1.创建Lua状态  
    L = luaL_newstate();  
    if (L == NULL)  
    {  
        std::cout<<"load file error"<<endl;
        return false;  
    }  
   
    //2.加载Lua文件  
    int bRet = luaL_loadfile(L, m_file.c_str());  
    if(bRet)  
    {  
        std::cout<<"load file error"<<endl;  
        return false;  
    }  
   
    luaL_openlibs(L);

    lua_pushlightuserdata(L, (void *)&UKey); /* push address */
    lua_pushnumber(L, _id); /* push value */
    /* registry[&UKey] = myNumber */
    lua_settable(L, LUA_REGISTRYINDEX);

    lua_register(L, "EXTERNAL", luaInterface);  

    //3.运行Lua文件  
    bRet = lua_pcall(L,0,0,0);  
    if(bRet)  
    {  
        std::cout<<"pcall error"<<endl;  
        return false;  
    }  

    return true;
}

void LVM::UnInit()
{
    if (L){
        lua_close(L); 
        L = NULL;
    }
}

bool LVM::Dispatch(int cmd, char * msg, int len)
{
    if (L == NULL){
        std::cout << "dispatch msg error: L is null" << endl; 
        return false;
    }

    lua_getglobal(L, "DP");  
    lua_pushnumber(L, cmd);          
    lua_pushlstring(L, msg, len);           
    
    int iRet= lua_pcall(L, 2, 1, 0);// 调用函数，调用完成以后，会将返回值压入栈中，2表示参数个数，1表示返回结果个数。  
    if (iRet)                       
    {  
        const char *pErrorMsg = lua_tostring(L, -1);  
        std::cout << pErrorMsg << endl;  
        UnInit();
        return false;  
    }  
    if (lua_isnumber(L, -1))        //取值输出  
    {  
        double fValue = lua_tonumber(L, -1);  
        std::cout << "Result is " << fValue << endl;  
    }  

    return true;
}

int LVM::AddMsg(LVM_MSG *pMsg)
{
    boost::mutex::scoped_lock lock(m_lockQueue);

    int global = in_global;
    localMsgQueue.push(pMsg);
    if (!in_global){
        in_global = 1;
    }
    return global;
}

LVM_MSG * LVM::GetMsg()
{
    boost::mutex::scoped_lock lock(m_lockQueue);
    
    if (localMsgQueue.size() <= 0) {
        in_global = 0;
        return NULL;
    }
    LVM_MSG *pMsg = localMsgQueue.front();
    localMsgQueue.pop();
    return pMsg;
}

void LVM::OnTimer(int iTimerID, const boost::system::error_code& error)
{
    LvmMgr::getInstance()->PostMsg(
        _id, LVM_CMD_ONTIMER, (char*)&iTimerID, sizeof(int)
    );
}

bool LvmMgr::Init(){
    io_service = new boost::asio::io_service();
    io_work = new boost::asio::io_service::work( *io_service );
    
    App::worker_threads.create_thread( 
        boost::bind( &boost::asio::io_service::run, io_service ) );

    io_service->post(boost::bind(&LvmMgr::_CreateLvm, this, "main"));


    //work Message
    for( int x = 0; x < 1; ++x )
    {
        App::worker_threads.create_thread( 
            boost::bind( &LvmMgr::ProcessMsg , this) );
    }


    

    return true;
}

int LvmMgr::_CreateLvm(const std::string &file)
{
    std::cout << "_CreateLvm: id=" << boost::this_thread::get_id() << "\n";

    if (file == "main"){
        _lvmMain = boost::make_shared<LVM>(0, "main.lua", io_service);
        if (!_lvmMain->Init()){
            std::cout << "create main lvm failure! " << endl;  
            return 0;
        }
        mapLvm.insert(std::pair<int, boost::shared_ptr<LVM>>(0, _lvmMain));

        _lvmMain->SetTimer(1, 3000);

        return true;
    }
    
    int id = ++_gen_id;

    boost::shared_ptr<LVM> lvm = boost::make_shared<LVM>(id, file, io_service);
    if (!lvm->Init()){
        std::cout << "create lvm failure! " << endl;  
        return 0;
    }

    mapLvm.insert(std::pair<int, boost::shared_ptr<LVM>>(id, lvm));
    return id;
}

bool LvmMgr::_RemoveLvm(int id)
{
    std::map<int, boost::shared_ptr<LVM>>::iterator it = mapLvm.find(id);
    if (it == mapLvm.end()){
        return false;
    }
    mapLvm.erase(it);
    return true;
}

boost::shared_ptr<LVM> LvmMgr::GetLVM(int id)
{
    std::map<int, boost::shared_ptr<LVM>>::iterator it = mapLvm.find(id);
    if (it == mapLvm.end()){
        return NULL;
    }
    return it->second;
}

int LvmMgr::SetTimer(int lvmid, int iTimerID, int iElapse, int once)
{
    io_service->post(boost::bind(&LvmMgr::_SetTimer, this, lvmid, iTimerID, iElapse, once ));
    return 0;
}

int LvmMgr::_SetTimer(int lvmid, int iTimerID, int iElapse, int once)
{
    boost::shared_ptr<LVM> spLvm = GetLVM(lvmid);
    if (spLvm == nullptr){
        return -1;
    }
    spLvm->SetTimer(iTimerID, iElapse, once);
    return 0;
}

uint64_t LvmMgr::PostMsg(int dest, int cmd, char *msg, int len)
{
    static boost::atomic_uint64_t s_gen_msg_id(0);
 
    LVM_MSG * pMsg = new LVM_MSG();
    pMsg->id = ++s_gen_msg_id;
    pMsg->dest = dest;
    pMsg->cmd = cmd;
    pMsg->msg = new char[len];
    memcpy(pMsg->msg, msg, len);
    pMsg->len = len;
    
    io_service->post(boost::bind(&LvmMgr::_PostMsg, this, pMsg));
    return pMsg->id;
}
 
void LvmMgr::_PostMsg(LVM_MSG *pMsg){
    std::cout << "_PostMsg msg:" << pMsg->id << ";cmd=" << pMsg->cmd 
        << ";msg=" << pMsg->msg << ";len=" << pMsg->len << std::endl;
    //main lvm
    if (0 == pMsg->dest){
        _lvmMain->Dispatch(pMsg->cmd, pMsg->msg, pMsg->len);

        delete pMsg;
        return;
    }

    boost::shared_ptr<LVM> lvm = GetLVM(pMsg->dest);
    if (lvm){
        int inGlobal = lvm->AddMsg(pMsg);
        if (!inGlobal){
            AddToGlobal(lvm);
        }
    }
}

void LvmMgr::AddToGlobal(boost::shared_ptr<LVM> lvm)
{
    boost::mutex::scoped_lock lock(m_lockGlobalMsgQueue);
    globalMsgQueue.push(lvm);
}

boost::shared_ptr<LVM> LvmMgr::NextGlobal()
{
    boost::mutex::scoped_lock lock(m_lockGlobalMsgQueue);
    
    if (globalMsgQueue.size() <= 0){
        return nullptr;
    }
    boost::shared_ptr<LVM> value = globalMsgQueue.front();  
    globalMsgQueue.pop();  
    
    return value;
}

int LvmMgr::ProcessMsg()
{
    do{
        
        boost::shared_ptr<LVM> spLvm = LvmMgr::getInstance()->NextGlobal();
        if (spLvm == nullptr){
            boost::this_thread::sleep(boost::posix_time::milliseconds( 5 ) );
            continue;
        }

        do{
            LVM_MSG *pMsg = spLvm->GetMsg();
            if (pMsg){
                std::cout << boost::this_thread::get_id() << "\n";
                spLvm->Dispatch(pMsg->cmd, pMsg->msg, pMsg->len);
                delete pMsg;
            }
            else{
                break;
            }
        }while(true);

    }while(true);


    return 1;
}

