#include "stdafx.h"
#include "lvm.h"

#include "app.h"
#include "net.h"

#include <iostream>
using namespace std;

static const char UKey = 'k';
static int luaInterface(lua_State *L)  
{
    int n = lua_gettop(L);  
    int method = lua_tonumber(L, 1); 
    int sid = lua_tonumber(L, 2); 
    int base = 2;

    lua_pushlightuserdata(L, (void *)&UKey); 
    lua_gettable(L, LUA_REGISTRYINDEX); 
    int idlvm = lua_tonumber(L, -1); 
    lua_pop(L, 1);

    // LOG(INFO) << "luaInterface: tid" << boost::this_thread::get_id() << ";Method=" 
    //     << method << "; sid=" << sid << "; idlvm=" << idlvm;

    switch(method){
        case LVM_CMD_LOG:
        {
            int level = lua_tonumber(L, base+1);
            const char * strMsg = lua_tostring(L, base+2);
            int len = lua_tonumber(L, base+3); 
             
            if (level == 1){
                LOG(DEBUG) << std::string(strMsg, len);
            }
            else if (level == 2){
                LOG(INFO) << std::string(strMsg, len);
            }
            else if (level == 3){
                LOG(WARNING) << std::string(strMsg, len);
            }
            else{
                LOG(ERROR) << std::string(strMsg, len);
            }
        }
        break;
        case LVM_CMD_MSG:
        case LVM_CMD_MSG_RET:
        {
            int cmd = lua_tonumber(L, base+1);
            int dest = lua_tonumber(L, base+2);
            const char * strMsg = lua_tostring(L, base+3);
            int len = lua_tonumber(L, base+4);
            LvmMgr::getInstance()->PostMsg(idlvm,
                dest, sid, cmd, strMsg, len);
        }
        break;
        case LVM_CMD_CLIENT_CLOSE:
        {
            int wid = lua_tonumber(L, base+1);
            NET::getInstance()->CloseClient(wid);
        }
        break;
        case LVM_CMD_CLIENT_MSG_BACK:
        {
            int wid = lua_tonumber(L, base+1);
            const char * strMsg = lua_tostring(L, base+2);
            int len = lua_tonumber(L, base+3);
            NET::getInstance()->SendClient(wid, strMsg, len);
        }
        break;
        case LVM_CMD_CREATLVM: //create lvm
        {
            const char *pLuaFile = lua_tostring(L, base+1);

            int ret = LvmMgr::getInstance()->_CreateLvm(pLuaFile);
            lua_pushnumber(L, ret);  
            return 1;  
        }
        break;
        case LVM_CMD_DELLVM:
        {
            int vid = lua_tonumber(L, base+1);
            int ret = LvmMgr::getInstance()->_RemoveLvm(vid);
            lua_pushnumber(L, ret);  
            return 1;      
        }
        break;
        case LVM_CMD_SETTIMER: //settimer
        {
            int timeid = lua_tonumber(L, 3);
            int elapse = lua_tonumber(L, 4);
            int once = 1;
            if (n > 4) {
                once = lua_tonumber(L, 5);
            }

            int ret = LvmMgr::getInstance()->SetTimer(idlvm, timeid, elapse, once);
            lua_pushnumber(L, ret);  
            return 1;  
        }
        break;  
        case LVM_CMD_KILLTIMER:
        {
            int timeid = lua_tonumber(L, base+1);
            LvmMgr::getInstance()->KillTimer(idlvm, timeid);
        }
        break;
        case LVM_CMD_HTTP_REQ:
        {
            std::string strMethod = lua_tostring(L, base+1);
            std::string strHost = lua_tostring(L, base+2);
            std::string strpath;
            if (n >= base+3) {
                strpath = lua_tostring(L, base+3);
            }

            std::string strParams;
            if (n >= base+4) {
                strParams = lua_tostring(L, base+4);
            }

            NET::getInstance()->HttpReq(idlvm, sid, strMethod, strHost, strpath, strParams);
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
        LOG(ERROR)<<"newstate error";
        return false;  
    }  
   
    //2.加载Lua文件  
    int bRet = luaL_loadfile(L, m_file.c_str());  
    if(bRet)  
    {  
        LOG(ERROR)<<"load file error"; 
        const char *pErrorMsg = lua_tostring(L, -1);  
        LOG(ERROR) << pErrorMsg;   
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
        LOG(ERROR)<<"pcall error";  
        const char *pErrorMsg = lua_tostring(L, -1);  
        LOG(ERROR) << pErrorMsg;  
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

bool LVM::Dispatch(int fid, int sid, int cmd, char * msg, int len)
{
    if (L == NULL){
        LOG(ERROR) << "dispatch msg error: L is null" ; 
        return false;
    }
    int nInParamCnt = 4;
    lua_getglobal(L, "Dispatch");  
    lua_pushnumber(L, fid); 
    lua_pushnumber(L, sid);   
    lua_pushnumber(L, cmd);   
    if (msg){
        lua_pushlstring(L, msg, len);
    }       
    else{
        nInParamCnt = 3;
    }
  
    int iRet= lua_pcall(L, nInParamCnt, 1, 0);// 调用函数，调用完成以后，会将返回值压入栈中，2表示参数个数，1表示返回结果个数。  
    if (iRet)                       
    {  
        const char *pErrorMsg = lua_tostring(L, -1);  
        LOG(ERROR) << pErrorMsg;  
        // UnInit();
        return false;  
    }  
    if (lua_isnumber(L, -1))        //取值输出  
    {  
        double fValue = lua_tonumber(L, -1);  
        LOG(INFO) << "Result is " << fValue ;  
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
    LvmMgr::getInstance()->PostMsg(_id,
        _id, iTimerID, LVM_CMD_ONTIMER, NULL, 0
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
    LOG(INFO) << "_CreateLvm: tid=" << boost::this_thread::get_id() << "; file=" << file;

    if (file == "main"){
        _lvmMain = boost::make_shared<LVM>(MAIN_LVM_ID, "script/main.lua", io_service);
        if (!_lvmMain->Init()){
            LOG(ERROR) << "create main lvm failure! ";  
            return 0;
        }
        mapLvm.insert(std::pair<int, boost::shared_ptr<LVM>>(0, _lvmMain));

        // _lvmMain->SetTimer(1, 3000);

        return MAIN_LVM_ID;
    }
    
    int id = ++_gen_id;

    boost::shared_ptr<LVM> lvm = boost::make_shared<LVM>(id, file, io_service);
    if (!lvm->Init()){
        LOG(ERROR) << "create lvm failure! " << endl;  
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

int LvmMgr::KillTimer(int lvmid, int iTimerID)
{
    io_service->post(boost::bind(&LvmMgr::_KillTimer, this, lvmid, iTimerID));
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

int LvmMgr::_KillTimer(int lvmid, int iTimerID)
{
    boost::shared_ptr<LVM> spLvm = GetLVM(lvmid);
    if (spLvm == nullptr){
        return -1;
    }
    spLvm->KillTimer(iTimerID);
    return 0;
}

uint64_t LvmMgr::PostMsg(int from , int dest, int id, int cmd, const char *msg, int len)
{
    static boost::atomic_uint64_t s_gen_msg_id(0);
 
    LVM_MSG * pMsg = new LVM_MSG();
    //pMsg->id = ++s_gen_msg_id;
    pMsg->from = from;
    pMsg->id = id;
    pMsg->dest = dest;
    pMsg->cmd = cmd;
    if (msg){
        pMsg->msg = new char[len];
        memcpy(pMsg->msg, msg, len);
        pMsg->len = len;      
    }
    io_service->post(boost::bind(&LvmMgr::_PostMsg, this, pMsg));
    return pMsg->id;
}
 
void LvmMgr::_PostMsg(LVM_MSG *pMsg){
    LOG(INFO) << "_PostMsg msg:" << pMsg->id << ";from=" << pMsg->from << ";cmd=" << pMsg->cmd 
        << ";msg=" << (std::string(pMsg->msg, pMsg->len)) << ";len=" << pMsg->len;
    //main lvm
    if (MAIN_LVM_ID == pMsg->dest){
        _lvmMain->Dispatch(pMsg->from, pMsg->id, pMsg->cmd, pMsg->msg, pMsg->len);

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
                LOG(INFO) << boost::this_thread::get_id();
                spLvm->Dispatch(pMsg->from, pMsg->id, pMsg->cmd, pMsg->msg, pMsg->len);
                delete pMsg;
            }
            else{
                break;
            }
        }while(true);

    }while(true);


    return 1;
}

