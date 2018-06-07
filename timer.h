#include <boost/asio.hpp>  
#include <boost/shared_ptr.hpp>  
#include <boost/thread.hpp>  
#include <boost/thread/mutex.hpp>  
#include <boost/bind.hpp>  
#include <iostream>  
  
class CAsyncTimer  
{  
public:  
    bool SetTimer(int iTimerID, int iElapse, int once = 1, void* pChild = NULL) {  
        MapTimer::iterator it = m_mapTimer.find(iTimerID);  
        if( it != m_mapTimer.end() ) {  
            return false;  
        }  
          
        PTIMER_INFO pInfo = new TIMER_INFO;  
        pInfo->iTimerID = iTimerID;  
        pInfo->iElapse = iElapse;  
        pInfo->pChild = pChild;  
        pInfo->once = once;
        pInfo->timer = boost::shared_ptr< boost::asio::deadline_timer >(new boost::asio::deadline_timer(*m_sp_ios));  
  
        pInfo->timer->expires_from_now(boost::posix_time::millisec(iElapse));  
        pInfo->timer->async_wait(boost::bind(&CAsyncTimer::OnTimerInternal, this, iTimerID, boost::asio::placeholders::error));  
  
        m_mapTimer.insert(std::pair<int, PTIMER_INFO>(iTimerID, pInfo));  
  
        return true;  
    }  
      
    bool KillTimer(int iTimerID) {  
        MapTimer::iterator it = m_mapTimer.find(iTimerID);  
        if( it == m_mapTimer.end() ) {  
            return false;  
        }  
  
        PTIMER_INFO pInfo = (PTIMER_INFO)(it->second);  
        pInfo->timer->cancel();  
        delete pInfo;
        m_mapTimer.erase(it);  
  
        return true;  
    }  

private: 
    virtual void OnTimer(int iTimerID, const boost::system::error_code& error) {  
        // MapTimer::iterator it = m_mapTimer.find(iTimerID);  
        // if( it == m_mapTimer.end() ) {  
        //     return;  
        // }  
  
        // PTIMER_INFO pInfo = (PTIMER_INFO)(it->second);  
          
        // pInfo->timer->expires_from_now(boost::posix_time::millisec(pInfo->iElapse));  
        // pInfo->timer->async_wait(boost::bind(&CAsyncTimer::OnTimerInternal, this, iTimerID, boost::asio::placeholders::error));  
    }  
  
 
    void OnTimerInternal(int iTimerID, const boost::system::error_code& error) {  
        MapTimer::iterator it = m_mapTimer.find(iTimerID);  
        if( it == m_mapTimer.end() ) {  
            return;  
        }  
          
        PTIMER_INFO pInfo = (PTIMER_INFO)(it->second);  
          
        if (pInfo->pChild)
        {
            ((CAsyncTimer*)(pInfo->pChild))->OnTimer(iTimerID, error);  
        }    
        else{
            OnTimer(iTimerID, error);              
        }
        if (0 == pInfo->once){
            pInfo->timer->expires_from_now(boost::posix_time::millisec(pInfo->iElapse));  
            pInfo->timer->async_wait(boost::bind(&CAsyncTimer::OnTimerInternal, this, iTimerID, boost::asio::placeholders::error));  
        }
        else{
            pInfo->timer->cancel();  
            delete pInfo;
            m_mapTimer.erase(it);
        }
    }  
      
protected:  
    typedef struct tagTIMER_INFO {  
        int iTimerID;
        int iElapse;  
        int once;
        void *pChild;  
        boost::shared_ptr< boost::asio::deadline_timer > timer;  
    } TIMER_INFO, *PTIMER_INFO;  
    typedef std::map<int, PTIMER_INFO> MapTimer;  
  
    CAsyncTimer(boost::asio::io_service* ios)   
        : m_sp_ios(ios) {  
          
    }  
    ~CAsyncTimer() {  
        MapTimer::iterator it = m_mapTimer.begin();  
        for( ; it != m_mapTimer.end(); it ++) {  
            PTIMER_INFO pInfo = (PTIMER_INFO)(it->second);  
            delete pInfo;  
            pInfo = NULL;  
        }  
        m_mapTimer.clear();  
    }  
      
    MapTimer        m_mapTimer;  
    boost::asio::io_service *     m_sp_ios;  
};  