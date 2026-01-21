gg.setVisible(false)

--------------------------------------------------
-- CONFIG URL
--------------------------------------------------
local URL_GAMES = "https://raw.githubusercontent.com/jodiardianboy-code/menu_loader_v2/refs/heads/main/games_config.lua"
local URL_USERS = "https://raw.githubusercontent.com/jodiardianboy-code/menu_loader_v2/refs/heads/main/user_config.lua"
local URL_NEWS  = "https://raw.githubusercontent.com/jodiardianboy-code/menu_loader_v2/refs/heads/main/news_config.lua"


--------------------------------------------------
-- GLOBAL STATE
--------------------------------------------------
local GAME_CONFIG = {}
local USER_CONFIG = {}
local NEWS_CONFIG = {}
local CURRENT = {}

local LOGIN_SHOWN = false
local NEWS_SHOWN_AFTER_LOGIN = false

--------------------------------------------------
-- LOAD URL
--------------------------------------------------
local function loadURL(url)
    local r = gg.makeRequest(url)
    if not r or r.code ~= 200 then
        SERVER_STATUS = "OFFLINE"
        gg.alert("❌ Cannot connect server")
        os.exit()
    end

    local t = r.content
    t = t:gsub("^\239\187\191","")
         :gsub("\r","")
         :gsub("^%s+","")
         :gsub("%s+$","")

    local f,err = load("return "..t)
    if not f then
        gg.alert("CONFIG ERROR\n"..err)
        os.exit()
    end

    local ok,res = pcall(f)
    if not ok then
        gg.alert("CONFIG EXEC ERROR\n"..res)
        os.exit()
    end

    return res
end

--------------------------------------------------
-- LOAD SERVER
--------------------------------------------------
local function loadServer()
    GAME_CONFIG = loadURL(URL_GAMES)
    USER_CONFIG = loadURL(URL_USERS)
    NEWS_CONFIG = loadURL(URL_NEWS)

    if not USER_CONFIG or not USER_CONFIG.PASSWORDS then
        USER_CONFIG = { PASSWORDS = {} }
    end

    if not NEWS_CONFIG then
        NEWS_CONFIG = {
            TITLE = "NEWS",
            MESSAGE = "No update",
            LAST_UPDATE = ""
        }
    end
end

--------------------------------------------------
-- LOGIN SYSTEM
--------------------------------------------------
local function login()
    while true do

        -- fungsi menampilkan total game
        local totalGame = 0
        if GAME_CONFIG and GAME_CONFIG.GAMES then
            totalGame = #GAME_CONFIG.GAMES
        end

        gg.alert(
            "🎮 Script DRABOYGAMING™ 🇮🇩\n" ..
            "ℹ️ Version 3.0\n" ..
            "⏰ Date : " .. os.date("%d/%m/%Y") .. "\n" ..
            "🕹️ Available Script: "..totalGame.." Games\n" ..
            "⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘\n\n" ..
            "Welcome ♥️ \n" ..
            "Please enter your access key to continue\n" ..
            "Get access key in Telegram @DraboyGaming\n\n" ..
            "⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘"
        )



        local p = gg.prompt({"🔐 Enter Access Key"}, {""}, {"text"})
        if not p then return false end

        local input = tostring(p[1]):upper():gsub("%s+", "")

        local success = false

        for _,v in pairs(USER_CONFIG.PASSWORDS) do
            if type(v) == "string" then
                if input == v:upper() then
                    CURRENT.name = v
                    CURRENT.type = "PERMANENT 👑"
                    CURRENT.expire = "LIFETIME ♾️"
                    gg.toast("✅ Welcome, "..CURRENT.name.."!")
                    success = true
                    break
                end
            elseif type(v) == "table" then
                local code = tostring(v[1]):upper()
                local date = tostring(v[2])
                if input == code then
                    local y,m,d = date:match("(%d+)%-(%d+)%-(%d+)")
                    y,m,d = tonumber(y), tonumber(m), tonumber(d)
                    local exp = os.time({year=y, month=m, day=d, hour=23, min=59, sec=59})
                    local now = os.time()
                    if now > exp then
                        gg.alert("⛔ ACCOUNT EXPIRED\n\nExpired on: "..date.."\nContact @DraboyGaming")
                        success = false
                        break
                    end
                    CURRENT.name = v[1]
                    CURRENT.type = "TRIAL ⏳"
                    CURRENT.expire = date
                    gg.toast("✅ Trial active, "..CURRENT.name)
                    success = true
                    break
                end
            end
        end

        if success then
            return true
        else
            gg.alert("❌ WRONG KEY\n\nPlease check your access key and try again.")
        end
    end
end

--------------------------------------------------
-- LOGIN INFO CACHE
--------------------------------------------------
local function showLoginInfo()
    if LOGIN_SHOWN then return end
    LOGIN_SHOWN = true

    gg.alert(
        "⭐ LOGIN SUCCESS ⭐\n\n"..
        "👤 User   : "..CURRENT.name.."\n"..
        "ℹ️ Status : "..CURRENT.type.."\n"..
        "📝 Expire : "..CURRENT.expire
    )
end

--------------------------------------------------
-- NEWS
--------------------------------------------------
local function showNews()
    gg.alert(
        NEWS_CONFIG.TITLE..
        "\n⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘\n"..
        NEWS_CONFIG.MESSAGE
    )
end

--------------------------------------------------
-- EXIT CONFIRM
--------------------------------------------------
local function confirmExit()
    local c = gg.choice({"❌ Exit Loader","🔙 Back"}, nil)
    if c == 1 then
        gg.toast("Good bye")
        os.exit()
    end
end

--------------------------------------------------
-- GAME INFO
--------------------------------------------------
local function showGameInfo(game)
    if not game.NEWS or not game.NEWS.PAGES then
        gg.alert("ℹ️ No detailed info available for "..game.name)
        return
    end

  

    local infoText = game.NEWS.TITLE.."\n⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘\n"
    for _, page in ipairs(game.NEWS.PAGES) do
        infoText = infoText .. page.title .. "\n" .. page.content .. "\n⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘\n"
    end

    gg.alert(infoText)
end

--------------------------------------------------
-- MENU HEADER
--------------------------------------------------
local function menuTitle(expandUser)
    local header =
        "🎮 Script DRABOYGAMING™ 🇮🇩\n" ..
        "ℹ️ Version 3.0\n" ..
        "⏰ Date: "..os.date("%d/%m/%Y").."\n"
       

    if expandUser then
        header = header.. "👤 User: "..CURRENT.name.."\nℹ️ Status: "..CURRENT.type.."\n⏳ Expire: "..CURRENT.expire.."\n⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘\n"
    end

    header = header.."🕹️ Available Script Games: "..#GAME_CONFIG.GAMES.."\n⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘"

    return header
end

--------------------------------------------------
-- MAIN MENU
--------------------------------------------------
local function menu()
    showLoginInfo()

    -- Tampilkan news sekali setelah login
    if not NEWS_SHOWN_AFTER_LOGIN then
        showNews()
        NEWS_SHOWN_AFTER_LOGIN = true
    end

    local list = {}
    list[#list+1] = "👤 User Info"
    list[#list+1] = "⬇️⬇️ 🎮 Available Games ⬇️⬇️"
    for _,v in ipairs(GAME_CONFIG.GAMES) do
        list[#list+1] = v.name.." [v"..v.version.."]"
    end
    list[#list+1] = "⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘"
    list[#list+1] = "🔄 Refresh Server"
    list[#list+1] = "📢 News"
    list[#list+1] = "❌ Exit"

    local c = gg.choice(list,nil,menuTitle(false))
    if not c then
        gg.setVisible(false)
        return
    end

    local gameStart = 3  -- game mulai dari index 3 karena 1=User Info, 2=Available Games
    local gameEnd = gameStart + #GAME_CONFIG.GAMES - 1

    if c == #list then
        confirmExit()
        menu()
    elseif c == #list-1 then
        showNews()
        menu()
    elseif c == #list-2 then
        loadServer()
        gg.toast("✅ Server refreshed")
        menu()
    elseif c == 1 then
        -- User Info
        gg.alert(
            "🌟 User Info\n⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘\n"..
            "👤 User   : "..CURRENT.name.."\n"..
            "ℹ️ Status : "..CURRENT.type.."\n"..
            "📝 Expire : "..CURRENT.expire
        )
        menu()
    elseif c >= gameStart and c <= gameEnd then
        local game = GAME_CONFIG.GAMES[c - gameStart + 1]
        local infoChoice = gg.choice({
            "ℹ️ View Features & Mods",
            "🕹️ Launch Script",
            "🔙 Back to Menu"
        }, nil, "🎮 "..game.name.." [v"..game.version.."]\n⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘")
        if infoChoice == 1 then
            showGameInfo(game)
            menu()
        elseif infoChoice == 2 then

            gg.toast("⏬ Downloading script, please wait...")
                local r = gg.makeRequest(game.link)
                if r and r.code == 200 then
                    local ok,f = pcall(load, r.content)
                    if ok and f then
                        gg.toast("✅ Script loaded successfully!")
                        f()
                    else
                        gg.alert("❌ Script load error")
                    end
                else
                    gg.alert("❌ Failed to download script")
                end


            menu()
        else
            menu()
        end
    end
end

--------------------------------------------------
-- MAIN LOOP
--------------------------------------------------
loadServer()
if not login() then os.exit() end
menu()

while true do
    if gg.isVisible(true) then
        gg.setVisible(false)
        menu()
    end
    gg.sleep(120)
end
