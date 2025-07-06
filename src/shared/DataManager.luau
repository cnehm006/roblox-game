--[[
    DataManager.luau
    Handles player data, saving, loading, and game state calculations
]]

local Players = game:GetService("Players")
local GameConfig = require(script.Parent.GameConfig)
local Types = require(script.Parent.Types)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GetPlayerData = ReplicatedStorage:WaitForChild("GetPlayerData")
local UpdatePlayerData = ReplicatedStorage:WaitForChild("UpdatePlayerData")

local DataManager = {}

-- Mock data store for testing (replace with real DataStore in production)
local mockDataStore = {}

local cachedData = nil

-- Current player data
local playerData: Types.PlayerData = {
	robux = GameConfig.INITIAL_ROBUX,
	upgrades = {
		mechanicalKeyboard = 0,
		dualMonitor = 0,
		fastWifi = 0,
		energyDrinks = 0,
	},
	lastSave = os.time(),
}

-- Game statistics
local gameStats: Types.GameStats = {
	clicksPerSecond = 0,
	passiveIncome = 0,
	totalClicks = 0,
	totalEarned = 0,
}

--[[
    Data Management Functions
]]

function DataManager.getPlayerData()
	if not cachedData then
		cachedData = GetPlayerData:InvokeServer()
	end
	return cachedData
end

function DataManager.getGameStats(): Types.GameStats
	return gameStats
end

function DataManager.save()
	if cachedData then
		UpdatePlayerData:FireServer(cachedData)
	end
end

function DataManager.addRobux(amount: number)
	local data = DataManager.getPlayerData()
	data.robux += amount
	DataManager.save()
end

function DataManager.spendRobux(amount: number): boolean
	local data = DataManager.getPlayerData()
	if data.robux >= amount then
		data.robux -= amount
		DataManager.save()
		return true
	end
	return false
end

function DataManager.getUpgradeLevel(upgradeType: Types.UpgradeType): number
	local data = DataManager.getPlayerData()
	return data.upgrades[upgradeType] or 0
end

function DataManager.getUpgradeCost(upgradeType: Types.UpgradeType): number
	local currentLevel = DataManager.getUpgradeLevel(upgradeType)

	-- Phase 1 upgrade costs
	local upgradeCosts = {
		mechanicalKeyboard = { baseCost = 20, costMultiplier = 1.5 },
		dualMonitor = { baseCost = 100, costMultiplier = 2.0 },
		fastWifi = { baseCost = 80, costMultiplier = 1.7 },
		energyDrinks = { baseCost = 60, costMultiplier = 1.6 },
	}

	local upgradeData = upgradeCosts[upgradeType]
	if not upgradeData then
		return math.huge
	end

	return math.floor(upgradeData.baseCost * (upgradeData.costMultiplier ^ currentLevel))
end

function DataManager.canAffordUpgrade(upgradeType: Types.UpgradeType): boolean
	local cost = DataManager.getUpgradeCost(upgradeType)
	local data = DataManager.getPlayerData()
	return data.robux >= cost
end

function DataManager.purchaseUpgrade(upgradeType: Types.UpgradeType): boolean
	local cost = DataManager.getUpgradeCost(upgradeType)

	-- Phase 1 upgrade max levels
	local maxLevels = {
		mechanicalKeyboard = 20,
		dualMonitor = 10,
		fastWifi = 10,
		energyDrinks = 10,
	}

	local maxLevel = maxLevels[upgradeType] or 0
	if DataManager.getUpgradeLevel(upgradeType) >= maxLevel then
		return false
	end

	if DataManager.spendRobux(cost) then
		local data = DataManager.getPlayerData()
		data.upgrades[upgradeType] += 1
		DataManager.updateGameStats()
		return true
	end

	return false
end

function DataManager.updateGameStats()
	-- Calculate click value based on Phase 1 upgrades
	local clickValue = GameConfig.BASE_CLICK_VALUE

	-- Mechanical Keyboard: +1 per level
	local keyboardLevel = DataManager.getUpgradeLevel("mechanicalKeyboard")
	clickValue += keyboardLevel

	-- Dual Monitor: NO LONGER APPLIES HERE
	-- local monitorLevel = DataManager.getUpgradeLevel("dualMonitor")
	-- clickValue *= (1.2 ^ monitorLevel)

	-- Calculate passive income (not used in Phase 1, but keeping for future)
	gameStats.passiveIncome = 0

	-- Calculate auto-click rate (not used in Phase 1, but keeping for future)
	gameStats.clicksPerSecond = 0
end

function DataManager.getClickValue(): number
	local clickValue = GameConfig.BASE_CLICK_VALUE

	-- Mechanical Keyboard: +1 per level
	local keyboardLevel = DataManager.getUpgradeLevel("mechanicalKeyboard")
	clickValue += keyboardLevel

	-- Dual Monitor: NO LONGER APPLIES HERE
	-- local monitorLevel = DataManager.getUpgradeLevel("dualMonitor")
	-- clickValue *= (1.2 ^ monitorLevel)

	return clickValue
end

function DataManager.getPassiveIncome(): number
	-- Not used in Phase 1
	return 0
end

function DataManager.getAutoClickRate(): number
	-- Not used in Phase 1
	return 0
end

--[[
    Save/Load Functions (Mock implementation)
]]

function DataManager.saveData()
	local player = Players.LocalPlayer
	if not player then
		return
	end

	playerData.lastSave = os.time()
	mockDataStore[player.UserId] = playerData

	-- In a real game, you'd use:
	-- local dataStore = DataStoreService:GetDataStore("TycoonTycoonData")
	-- dataStore:SetAsync(player.UserId, playerData)
end

function DataManager.loadData()
	local player = Players.LocalPlayer
	if not player then
		return
	end

	local savedData = mockDataStore[player.UserId]
	if savedData then
		playerData = savedData
		DataManager.updateGameStats()
	end

	-- In a real game, you'd use:
	-- local dataStore = DataStoreService:GetDataStore("TycoonTycoonData")
	-- local success, data = pcall(function()
	--     return dataStore:GetAsync(player.UserId)
	-- end)
	-- if success and data then
	--     playerData = data
	--     DataManager.updateGameStats()
	-- end
end

-- Auto-save every 30 seconds
spawn(function()
	while true do
		wait(30)
		DataManager.saveData()
	end
end)

return DataManager
