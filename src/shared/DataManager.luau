--[[
    DataManager.luau
    Handles player data, saving, loading, and game state calculations
]]

local Players = game:GetService("Players")
local GameConfig = require(script.Parent.GameConfig)
local Types = require(script.Parent.Types)

local DataManager = {}

-- Mock DataStore (in a real game, you'd use DataStoreService)
local mockDataStore = {}

-- Current player data
local playerData: Types.PlayerData = {
	robux = GameConfig.INITIAL_ROBUX,
	upgrades = {
		fasterTyping = 0,
		interns = 0,
		laptopUpgrade = 0,
		studioHQ = 0,
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

function DataManager.getPlayerData(): Types.PlayerData
	return playerData
end

function DataManager.getGameStats(): Types.GameStats
	return gameStats
end

function DataManager.addRobux(amount: number)
	playerData.robux += amount
	gameStats.totalEarned += amount
	DataManager.updateGameStats()
end

function DataManager.spendRobux(amount: number): boolean
	if playerData.robux >= amount then
		playerData.robux -= amount
		return true
	end
	return false
end

function DataManager.getUpgradeLevel(upgradeType: Types.UpgradeType): number
	return playerData.upgrades[upgradeType] or 0
end

function DataManager.getUpgradeCost(upgradeType: Types.UpgradeType): number
	local currentLevel = DataManager.getUpgradeLevel(upgradeType)
	local upgradeData = GameConfig.UPGRADES[upgradeType]

	if not upgradeData then
		return math.huge
	end

	return math.floor(upgradeData.baseCost * (upgradeData.costMultiplier ^ currentLevel))
end

function DataManager.canAffordUpgrade(upgradeType: Types.UpgradeType): boolean
	local cost = DataManager.getUpgradeCost(upgradeType)
	return playerData.robux >= cost
end

function DataManager.purchaseUpgrade(upgradeType: Types.UpgradeType): boolean
	local cost = DataManager.getUpgradeCost(upgradeType)
	local upgradeData = GameConfig.UPGRADES[upgradeType]

	if not upgradeData then
		return false
	end

	if DataManager.getUpgradeLevel(upgradeType) >= upgradeData.maxLevel then
		return false
	end

	if DataManager.spendRobux(cost) then
		playerData.upgrades[upgradeType] += 1
		DataManager.updateGameStats()
		return true
	end

	return false
end

function DataManager.updateGameStats()
	-- Calculate click value
	local clickValue = GameConfig.BASE_CLICK_VALUE
	clickValue += DataManager.getUpgradeLevel("fasterTyping")

	-- Apply laptop upgrade multiplier
	local laptopLevel = DataManager.getUpgradeLevel("laptopUpgrade")
	clickValue *= (2 ^ laptopLevel)

	-- Calculate passive income
	local studioHQLevel = DataManager.getUpgradeLevel("studioHQ")
	gameStats.passiveIncome = studioHQLevel * 10 -- 10 Robux per level every 5 seconds

	-- Calculate auto-click rate
	local internLevel = DataManager.getUpgradeLevel("interns")
	gameStats.clicksPerSecond = internLevel * clickValue
end

function DataManager.getClickValue(): number
	local clickValue = GameConfig.BASE_CLICK_VALUE
	clickValue += DataManager.getUpgradeLevel("fasterTyping")

	local laptopLevel = DataManager.getUpgradeLevel("laptopUpgrade")
	clickValue *= (2 ^ laptopLevel)

	return clickValue
end

function DataManager.getPassiveIncome(): number
	local studioHQLevel = DataManager.getUpgradeLevel("studioHQ")
	return studioHQLevel * 10
end

function DataManager.getAutoClickRate(): number
	return DataManager.getUpgradeLevel("interns")
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
