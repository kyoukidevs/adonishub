-- Loader.lua
local _ENV = {Utility = {}};
local Players = game:GetService('Players')
local HttpService = game:GetService('HttpService')

local throwError = function(contents)
    if Players.LocalPlayer then 
        Players.LocalPlayer:Kick(string.format("adonishub has threw an error: %s", tostring(contents)))
    else
        while true do end 
    end
end

local httpRequest = function(data)
    local requestFunction = request or http_request or (http and http.request) or (syn and syn.request) 
    if not requestFunction then 
        throwError("Loader.lua - missing http request function")
    end

    local suc, response = pcall(function()
        return requestFunction(data)
    end)

    if not suc then 
        throwError(string.format("Loader.lua - error while doing http request: %s", response))
    end

    if not (response and response.Body) then 
        throwError("Loader.lua - no response on http request")
    end

    return response 
end

local mainRepo = "https://raw.githubusercontent.com/kyoukidevs/adonishub/main/Games/"
local libraryRepo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

_ENV.Library = loadstring(httpRequest({Url = libraryRepo .. 'Library.lua', Method = "GET"}).Body)()
_ENV.Utility.ThemeManager = loadstring(httpRequest({Url = libraryRepo .. 'addons/ThemeManager.lua', Method = "GET"}).Body)()
_ENV.Utility.SaveManager = loadstring(httpRequest({Url = libraryRepo .. 'addons/SaveManager.lua', Method = "GET"}).Body)()

if not (_ENV.Library and _ENV.Utility.ThemeManager and _ENV.Utility.SaveManager) then 
    throwError("Loader.lua - failed to load ui library")
end

local responseData = httpRequest({
    Url = "https://://github.comkyoukidevs/adonishub/contents/Games",
    Method = "GET"
})

local data = HttpService:JSONDecode(responseData.Body)

local gamesList = {}
for _, file in data do 
    local name = file.name 
    if type(name) == "string" then
        local gameName, gameId = string.match(name, "([^%s_]+)_(%d+)%.lua")
        
        if gameName and gameId then
            gamesList[tonumber(gameId)] = gameName 
        end
    end
end

local GameId = game.GameId 
_ENV.GameId = GameId 

if gamesList[GameId] then 
    _ENV.Game = gamesList[GameId];
    local gameScriptUrl = string.format("%s%s_%d.lua", mainRepo, _ENV.Game, _ENV.GameId)
    local scriptCode = httpRequest({Url = gameScriptUrl, Method = "GET"}).Body
    
    loadstring(scriptCode)()
else
    throwError(string.format("Loader.lua - Game not supported (ID: %s)", tostring(GameId)))
end
