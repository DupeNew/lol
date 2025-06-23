local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local maxPlayersBeforeHop = 5

local function shouldServerHop()
    local playerCount = #Players:GetPlayers()
    return playerCount >= maxPlayersBeforeHop
end

local function hopToServer()
    local requestUrl = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local servers = {}
    
    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGetAsync(requestUrl))
    end)

    if success and response and response.data then
        for _, server in ipairs(response.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers and server.playing > 0 then
                table.insert(servers, server)
            end
        end
    end
    
    if #servers > 0 then
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[1].id, LocalPlayer)
        end)
    end
end

while task.wait(0.1) do
    if shouldServerHop() then
        hopToServer()
    end
end
