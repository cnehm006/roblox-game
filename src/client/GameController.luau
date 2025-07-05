--[[
    GameController.luau
    Main controller that initializes and manages all game systems
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Load modules with error handling
local DataManager = require(ReplicatedStorage.Shared.DataManager)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local MainGui = require(script.Parent.Gui.MainGui)
local UpgradesPanel = require(script.Parent.Gui.UpgradesPanel)
local GameLoop = require(script.Parent.GameLoop)

local GameController = {}

--[[
    Initialization Functions
]]

function GameController.init()
	print("Initializing Tycoon Tycoon...")

	local success, err = pcall(function()
		-- Load player data
		DataManager.loadData()

		-- Create main GUI
		local mainGui = MainGui.create()

		-- Create upgrades panel
		local upgradesPanel = UpgradesPanel.create(mainGui)

		-- Set up connections
		GameController.setupConnections()

		-- Start game loop
		GameLoop.start()

		-- Set up update callbacks
		GameController.setupUpdateCallbacks()
	end)

	if not success then
		warn("Failed to initialize Tycoon Tycoon:", err)
		return false
	end

	print("Tycoon Tycoon initialized successfully!")
	return true
end

function GameController.setupConnections()
	-- Connect main GUI to upgrades panel
	MainGui.setUpgradesCallback(function()
		UpgradesPanel.toggle()
	end)

	-- Connect upgrades panel to main GUI
	UpgradesPanel.setUpgradeCallback(function()
		MainGui.updateDisplay()
	end)

	-- Connect game loop to GUI updates
	GameLoop.setUpdateCallback(function()
		MainGui.updateDisplay()
		if UpgradesPanel.isPanelOpen() then
			UpgradesPanel.updateAllDisplays()
		end
	end)
end

function GameController.setupUpdateCallbacks()
	-- Set up periodic data saving
	spawn(function()
		while true do
			wait(30) -- Save every 30 seconds
			DataManager.saveData()
		end
	end)

	-- Set up periodic display updates
	spawn(function()
		while true do
			wait(0.1) -- Update every 0.1 seconds
			MainGui.updateDisplay()
		end
	end)
end

--[[
    Game State Functions
]]

function GameController.startGame()
	print("Starting Tycoon Tycoon game...")

	local success, err = pcall(function()
		-- Reset game loop timers
		GameLoop.resetTimers()

		-- Initial display update
		MainGui.updateDisplay()
	end)

	if not success then
		warn("Failed to start Tycoon Tycoon game:", err)
		return false
	end

	print("Game started!")
	return true
end

function GameController.pauseGame()
	print("Game paused")
	-- In a real implementation, you might want to pause the game loop
end

function GameController.resumeGame()
	print("Game resumed")
	-- In a real implementation, you might want to resume the game loop
end

--[[
    Utility Functions
]]

function GameController.getPlayerData()
	return DataManager.getPlayerData()
end

function GameController.getGameStats()
	return DataManager.getGameStats()
end

function GameController.saveGame()
	DataManager.saveData()
	print("Game saved")
end

function GameController.loadGame()
	DataManager.loadData()
	MainGui.updateDisplay()
	print("Game loaded")
end

--[[
    Debug Functions
]]

function GameController.debugAddRobux(amount: number)
	DataManager.addRobux(amount)
	MainGui.updateDisplay()
	print("Added " .. amount .. " Robux (debug)")
end

function GameController.debugMaxUpgrades()
	local upgradeTypes = { "fasterTyping", "interns", "laptopUpgrade", "studioHQ" }

	for _, upgradeType in ipairs(upgradeTypes) do
		local upgradeData = GameConfig.UPGRADES[upgradeType]
		if upgradeData then
			-- Add enough Robux to max the upgrade
			local currentLevel = DataManager.getUpgradeLevel(upgradeType)
			local levelsToAdd = upgradeData.maxLevel - currentLevel

			for i = 1, levelsToAdd do
				local cost = DataManager.getUpgradeCost(upgradeType)
				DataManager.addRobux(cost)
				DataManager.purchaseUpgrade(upgradeType)
			end
		end
	end

	MainGui.updateDisplay()
	if UpgradesPanel.isPanelOpen() then
		UpgradesPanel.updateAllDisplays()
	end

	print("All upgrades maxed (debug)")
end

--[[
    Public Interface
]]

function GameController.getMainGui()
	return MainGui
end

function GameController.getUpgradesPanel()
	return UpgradesPanel
end

function GameController.getGameLoop()
	return GameLoop
end

return GameController
