package.path = "../?.lua;"..package.path

local utils = require "utils"

local jiang = {
    [2] = true,
    [5] = true,
    [8] = true,
    [11]= true,
    [14]= true,
    [17]= true,
    [20]= true,
    [23]= true,
    [26]= true
}

local M = {}


local COLORS = {"万","筒","条"}

function M.get_color(card)
    return math.floor((card-1)/9) + 1
end

function M.get_color_str(card)
    local color = M.get_color(card)
    return COLORS[color]
end

function M.get_card_str(index)
    if index >= 1 and index <= 9 then
        return index .. "万"
    elseif index >= 10 and index <= 18 then
        return (index - 9) .. "筒"
    elseif index >= 19 and index <= 27 then
        return (index - 18) .. "条"
    end

    local t = {"东","西","南","北","中","发","白"}
    return t[index - 27]
end

function M.getNumTable(tbl, zi)
    local t = {}
    
    local num = 3*9

    if zi then
        num = num + 7
    end

    for i=1,num do
        table.insert(t, 0)
    end

    for i=1,#tbl do
        t[tbl[i]] = t[tbl[i]] + 1
    end
    return t
end

function M.getNumTableStr(tbl,zi)
    local str = ""
    local card_str
    local num = 3*9
    if zi then
        num = num + 7
    end

    for i=1,num do
        if tbl[i] > 0 then
            card_str = M.get_card_str(i)
        end

        if tbl[i] == 1 then
            str = str .. card_str
        elseif tbl[i] == 2 then
            str = str .. card_str .. card_str
        elseif tbl[i] == 3 then
            str = str .. card_str .. card_str .. card_str
        elseif tbl[i] == 4 then
            str = str .. card_str .. card_str .. card_str .. card_str
        end
    end

    return str
end

-- 创建一幅牌,牌里存的不是牌本身，而是牌的序号
function M.create(zi)
    local t = {}

    local num = 3*9

    if zi then
        num = num + 7
    end

    for i=1,num do
        for _=1,4 do
            table.insert(t, i)
        end
    end

    return t
end

-- 洗牌
function M.shuffle(t)
    for i=#t,2,-1 do
        local tmp = t[i]
        local index = math.random(1, i - 1)
        t[i] = t[index]
        t[index] = tmp
    end
end

function M.check_hu()

end

-- 检查平胡
function M._check_normal(cards)
    -- 找出能做将的牌
    local eye_tbl = {}

    M._find_eye(cards, eye_tbl, 1,   9)
    M._find_eye(cards, eye_tbl, 10, 18)
    M._find_eye(cards, eye_tbl, 19, 27)

    local hu = false
    for i,_ in pairs(eye_tbl) do
        repeat
            cards[i] = cards[i] - 2
            if not M._check_color(cards, 1, 9) then
                break
            end
            if not M._check_color(cards, 10, 18) then
                break
            end
            if not M._check_color(cards, 19, 27) then
                break
            end

            hu = true
        until(true)
        if hu then
            return true
        end
        cards[i] = cards[i] + 2
    end
    return hu
end

function M._find_eye(cards, eye_tbl, from, to)
    local key = 0
    local t = {}
    for i=from,to do
        local c = cards[i]
        if c > 0 then
            key = key * 10 + c
            if c >= 2 then
                t[i] = true
            end
        end

        if c == 0 or i == to then
            if (key%3) == 2 then
                for k,_ in pairs(t) do
                    eye_tbl[k] = true
                end
            end
            if key > 0 and next(t) then
                t = {}
            end
        end
    end
end

-- 检查单一花色
function M._check_color(cards, min, max)
    local t = {}
    for i=min,max do
        table.insert(t, cards[i])
    end
    for i=min,max do
        local n
        if t[i] == 1 or t[i] == 4 then
            n = 1
        elseif t[i] == 2 then
            n = 2
        end

        if n then
            if i + 2 > max or t[i+1] < n or t[i+2] < n then
                return false
            end

            t[i] = t[i] - n
            t[i+1] = t[i+1] - n
            t[i+2] = t[i+2] - n
        end
    end

    return true
end

-- 大四喜
function M.check_dasixi(cards)
    for _,v in ipairs(cards) do
        if v == 4 then
            return true
        end
    end
    return false
end

-- 板板胡
function M.check_banbanhu(cards)
    for i,_ in pairs(jiang) do
        if cards[i] > 0 then
            return false
        end
    end
    return true
end

-- 缺一色
function M.check_queyise(cards)
    local n1 = 0
    local n2 = 0
    local n3 = 0
    for i=1,9 do
        n1 = n1 + cards[i]
        n2 = n2 + cards[i+9]
        n3 = n3 + cards[i+18]
    end
    return n1 == 0 or n2 == 0 or n3 == 0
end

-- 六六顺
function M.check_liuliushun(cards)
    local n = 0
    for _,v in ipairs(cards) do
        if v == 3 then
            n = n + 1
        end
    end

    return n >= 2
end

-- 碰碰胡
function M.check_pengpeng(cards, waves)
    local eye = false
    for _,n in ipairs(cards) do
        if n == 1 or n == 4 then
            return false
        end

        if n == 2 then
            if eye then
                return false
            end
            eye = true
        end
    end

    -- 有吃的牌则不算
end

-- 清一色
function M.check_qingyise()
    local n1 = 0
    local n2 = 0
    local n3 = 0
    for i=1,9 do
        n1 = n1 + cards[i]
        n2 = n2 + cards[i+9]
        n3 = n3 + cards[i+18]
    end

    -- 检查底下牌的颜色
end

-- 将将胡
function M.check_jiangjianghu(cards, waves)
    for i,v in ipairs(cards) do
        if v > 0 and not jiang[i] then
            return false
        end
    end

    return true
end

-- 七小对
function M.check_7dui(cards)
    local n = 0
    local haohua = 0
    for i,v in ipairs(cards) do
        if v==1 or v==3 then
            return false, false
        end

        if v == 4 then
            haohua = haohua + 1
        end
        n = n + v
    end

    if n < 14 then
        return false
    end

    return true, haohua
end

-- 全求人
function M.check_quanqiuren()
    local n = 0
    for i,v in ipairs(cards) do
        if v > 0 and v ~= 2 then
            return false
        end
        n = n + v
    end

    return n == 2
end

-- 检查碰
function M.check_peng(cards, card)
    return cards[card] >= 2
end

function M.check_angang(cards, card)
    return cards[card] == 4
end

function M.check_diangang(cards, card)
    return cards[card] == 3
end

function M.check_jiagang(waves, card)

end

return M
