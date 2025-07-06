-- PlayerDataStore.server.luau
-- Handles persistent player data using DataStoreService

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local playerDataStore = DataStoreService:GetDataStore("PlayerDataStoreV1")

local DEFAULT_DATA = {
	robux = 0,
	upgrades = {
		mechanicalKeyboard = 0,
		dualMonitor = 0,
		fastWifi = 0,
		energyDrinks = 0,
	},
}

local function deepCopy(tbl)
	local copy = {}
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			copy[k] = deepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

local sessionData = {}

Players.PlayerAdded:Connect(function(player)
	local key = "Player_" .. player.UserId
	local data
	local success, result = pcall(function()
		return playerDataStore:GetAsync(key)
	end)
	if success and result then
		data = result
	else
		data = deepCopy(DEFAULT_DATA)
	end
	sessionData[player.UserId] = data
end)

Players.PlayerRemoving:Connect(function(player)
	local key = "Player_" .. player.UserId
	local data = sessionData[player.UserId]
	if data then
		pcall(function()
			playerDataStore:SetAsync(key, data)
		end)
		sessionData[player.UserId] = nil
	end
end)

game:BindToClose(function()
	for userId, data in pairs(sessionData) do
		local key = "Player_" .. userId
		pcall(function()
			playerDataStore:SetAsync(key, data)
		end)
	end
end)

-- RemoteFunction for client to get their data
local GetPlayerData = Instance.new("RemoteFunction")
GetPlayerData.Name = "GetPlayerData"
GetPlayerData.Parent = ReplicatedStorage
GetPlayerData.OnServerInvoke = function(player)
	return sessionData[player.UserId]
end

-- RemoteEvent for client to update their data
local UpdatePlayerData = Instance.new("RemoteEvent")
UpdatePlayerData.Name = "UpdatePlayerData"
UpdatePlayerData.Parent = ReplicatedStorage
UpdatePlayerData.OnServerEvent:Connect(function(player, newData)
	if typeof(newData) == "table" then
		sessionData[player.UserId] = newData
	end
end)
