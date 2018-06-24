

local M = {
    -- 0~1000   local cmd
    LVM_CMD_CREATLVM = 100,
    LVM_CMD_DELLVM = 101,
    LVM_CMD_MSG = 103,
    LVM_CMD_MSG_RET = 104,
    LVM_CMD_SETTIMER = 110,     
    LVM_CMD_ONTIMER = 111,
    LVM_CMD_KILLTIMER = 112,
    LVM_CMD_HTTP_REQ = 120,
    LVM_CMD_HTTP_RESP = 121,
    LVM_CMD_CLIENT_MSG = 130,
    LVM_CMD_CLIENT_MSG_BACK = 131,
    LVM_CMD_CLIENT_CONN = 140,
    LVM_CMD_CLIENT_DISCONN = 141,
    LVM_CMD_CLIENT_CLOSE = 142,
    LVM_CMD_LOG = 150,

    --1000 ~ game cmd
    --请求
    REQ_CREATE_TABLE = 999,
    REQ_HEART = 1000,--心跳
    REQ_LOGIN = 1001,--登录

    -- REQ_COMMON = 1005,--公用协议
    REQ_CHAT = 1003, --聊天
    REQ_SDAUDIO = 1005,--发送语音

    REQ_ENTERTABLE = 1010,--请求入桌
    REQ_DISSOLUTIONROOM = 1011, --解散房间
    REQ_PROMISROOM = 1012, --应答解散
    REQ_READY = 1013, --准备
    REQ_OUTCARD = 1014,--出牌
    REQ_ACTION = 1015,--执行操作
    REQ_TING = 1016,--听
    REQ_KICKPLAYER = 1017, --房主踢人
    REQ_TRANSFERROOM = 1018, --房主转让房间

    REQ_PIAO = 1019,       --飘分
    REQ_BAOTING = 1020, --- 玩家选择是否起手听牌  字段 opt 0:不起手听牌  1:起手听牌
    REQ_ACTION_GANG = 1021, --杠出来的两个子 进行操作

    --接受
    RES_LOGIN = 4000, --登录
    RES_ERROR = 4001, --操作错误
    RES_TBALEINFO = 4002, --初始化桌子
    RES_ENTERTABLE = 4003,--别的玩家加入桌子
    RES_OUTTABLE = 4004,--玩家离开桌子
    RES_CHAT = 4005, --聊天广播
    RES_COMMON = 4006,--公用协议
    RES_GAMESTATE = 4015,--跟新游戏状态
    RES_DISSOVEROOM = 4010, --广播询问解散房间
    RES_ACKDSVEROOM = 4011, --广播玩家应答解散房间状况
    RES_RESULTDISSOVEROOM = 4012, --广播解散房间结果
    RES_READY = 4013, --准备
    RES_STARTGAME = 4017,--游戏开始
    RES_ACCEPTAUDIO = 4007,--接收语音
    RES_QISHOUHU = 4018,--起手胡
    RES_OUTDICRECTION = 4019,--轮到谁出牌
    RES_OUTDICRECTION_OFTERBAOTING = 4020,--报听后可以出的牌
    RES_OUTCARD = 4021,--出牌
    RES_SENDCARD = 4022,--抓牌
    RES_ACTIONS = 4023,--预操作
    RES_ACTIONOVER = 4025,--操作完成
    RES_HU = 4026,--胡牌
    RES_GAMEOVER = 4027,--结算
    RES_GANG = 4029,--开杠
    RES_ZHANIAO = 4030, --扎鸟
    RES_ASKHAIDI = 4031, --咨询海底
    RES_ACTIONHAIDI = 4032,--要不要海底
    RES_SENDHAIDI = 4033, --发送海底牌
    RES_BIGGAMEOVER = 4034, --大结算
    RES_TING = 4035, --听牌
    RES_TINGCARDS = 4036, --听了什么牌
    RES_KICKPLAYERUC = 4037, --房主踢人通知
    RES_TRANSFERROOMUC = 4038, --房主转让房间通知
    RES_PIAO = 4039,  --选飘结果
    RES_BAOTINGRES = 4040,  -- 玩家选择后服务器返回选择结果  字段  ting 0:不起手听牌  1:起手听牌

    RES_QISHOUHU_FAPAI = 4040,-- 起手胡发牌

    RES_JJH_TING = 4041,-- 将将胡听牌
    RES_GANG_CARDS = 4042,-- 刷新待打出去的杠牌
    RES_NEED_OUT_GANG_CARD = 4043,-- 需要打出杠的牌

    RES_NEED_HIDE_QSH_CARD = 4044,-- 需要隐藏起手胡的牌
    RES_GANG_DATA = 4045, --长沙麻将 杠出来的子 预操作
    RES_CM_PIAO = 4046,  --选飘结果
    RES_RESULT_SCORE_GANG = 4047, --杠分现结
    RES_TING_CARDS = 4048, --玩家打出哪些牌 可以听牌
    RES_LAIYOU_ZI = 4049, --湖北麻将 癞油字
    RES_JLMJ_JZ = 4050,  --监利麻将 加增结果
    RES_ROOM_FULL = 4051,  --选座提示房间已满
}


return M