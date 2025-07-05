--[[
    GameLoop.luau
    Handles the main game loop, passive income, auto-clicking, and periodic updates
]]

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataManager = require(ReplicatedStorage.Shared.DataManager)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local GameLoop = {}

-- Timing variables
local lastPassiveIncomeTime = 0
local lastAutoClickTime = 0
local lastUpdateTime = 0

-- Update intervals
local PASSIVE_INCOME_INTERVAL = GameConfig.PASSIVE_INCOME_INTERVAL
local AUTO_CLICK_INTERVAL = GameConfig.AUTO_CLICK_INTERVAL
local UPDATE_INTERVAL = 0.1 -- Update display every 0.1 seconds

-- Callbacks
local onUpdateCallback = nil

--[[
    Game Loop Functions
]]

function GameLoop.start()
	-- Connect to RunService.Heartbeat for smooth updates
	RunService.Heartbeat:Connect(function(deltaTime)
		GameLoop.update(deltaTime)
	end)

	print("GameLoop started")
end

function GameLoop.update(deltaTime)
	local currentTime = tick()

	-- Handle passive income
	GameLoop.updatePassiveIncome(currentTime)

	-- Handle auto-clicking
	GameLoop.updateAutoClick(currentTime)

	-- Handle periodic updates
	GameLoop.updatePeriodic(currentTime)
end

function GameLoop.updatePassiveIncome(currentTime: number)
	if currentTime - lastPassiveIncomeTime >= PASSIVE_INCOME_INTERVAL then
		local passiveIncome = DataManager.getPassiveIncome()
		if passiveIncome > 0 then
			DataManager.addRobux(passiveIncome)

			-- Notify update callback
			if onUpdateCallback then
				onUpdateCallback()
			end
		end

		lastPassiveIncomeTime = currentTime
	end
end

function GameLoop.updateAutoClick(currentTime: number)
	if currentTime - lastAutoClickTime >= AUTO_CLICK_INTERVAL then
		local autoClickRate = DataManager.getAutoClickRate()
		if autoClickRate > 0 then
			local clickValue = DataManager.getClickValue()
			local totalIncome = autoClickRate * clickValue

			if totalIncome > 0 then
				DataManager.addRobux(totalIncome)

				-- Notify update callback
				if onUpdateCallback then
					onUpdateCallback()
				end
			end
		end

		lastAutoClickTime = currentTime
	end
end

function GameLoop.updatePeriodic(currentTime: number)
	if currentTime - lastUpdateTime >= UPDATE_INTERVAL then
		-- Update game stats
		DataManager.updateGameStats()

		-- Notify update callback
		if onUpdateCallback then
			onUpdateCallback()
		end

		lastUpdateTime = currentTime
	end
end

--[[
    Public Interface
]]

function GameLoop.setUpdateCallback(callback)
	onUpdateCallback = callback
end

function GameLoop.getLastPassiveIncomeTime(): number
	return lastPassiveIncomeTime
end

function GameLoop.getLastAutoClickTime(): number
	return lastAutoClickTime
end

function GameLoop.resetTimers()
	lastPassiveIncomeTime = tick()
	lastAutoClickTime = tick()
	lastUpdateTime = tick()
end

return GameLoop
