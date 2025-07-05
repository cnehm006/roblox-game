--[[
    MainGui.luau
    Creates and manages the main game GUI
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataManager = require(ReplicatedStorage.Shared.DataManager)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local UIUtils = require(ReplicatedStorage.Shared.UIUtils)
local Types = require(ReplicatedStorage.Shared.Types)

local MainGui = {}

-- GUI references
local screenGui: ScreenGui
local robuxLabel: TextLabel
local writeCodeButton: TextButton
local upgradesButton: TextButton

--[[
    GUI Creation Functions
]]

function MainGui.create()
	-- Create ScreenGui
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TycoonTycoonGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 100
	screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	print("ScreenGui parented to PlayerGui!")

	-- Create main container
	local mainContainer = Instance.new("Frame")
	mainContainer.Name = "MainContainer"
	mainContainer.Size = UDim2.new(1, 0, 1, 0)
	mainContainer.Position = UDim2.new(0, 0, 0, 0)
	mainContainer.BackgroundTransparency = 1
	mainContainer.Parent = screenGui

	-- Create Robux counter at top
	robuxLabel = UIUtils.createTextLabel(
		mainContainer,
		"RobuxLabel",
		"Robux: 0",
		UDim2.new(0, 200, 0, 50),
		UDim2.new(0, 20, 0, 20)
	)
	robuxLabel.TextColor3 = GameConfig.UI.COLORS.SUCCESS
	robuxLabel.Font = Enum.Font.GothamBold
	robuxLabel.TextSize = 24

	-- Create Write Code button in center
	writeCodeButton = UIUtils.createButton(
		mainContainer,
		"WriteCodeButton",
		"Write Code",
		UDim2.new(0, 300, 0, 100),
		UDim2.new(0.5, -150, 0.5, -50)
	)
	writeCodeButton.TextSize = 32

	-- Create Upgrades button in bottom-right
	upgradesButton = UIUtils.createButton(
		mainContainer,
		"UpgradesButton",
		"Upgrades",
		UDim2.new(0, 150, 0, 50),
		UDim2.new(1, -170, 1, -70)
	)
	upgradesButton.TextSize = 18

	-- TEST: Add a simple visible label to check GUI visibility
	local testLabel = Instance.new("TextLabel")
	testLabel.Size = UDim2.new(0, 200, 0, 50)
	testLabel.Position = UDim2.new(0.5, -100, 0.1, 0)
	testLabel.Text = "TEST"
	testLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	testLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	testLabel.Parent = screenGui
	print("Test label created!")

	-- Print all PlayerGui children for debug
	for _, child in pairs(Players.LocalPlayer.PlayerGui:GetChildren()) do
		print("PlayerGui child:", child.Name, child.ClassName)
	end

	-- Set up event handlers
	MainGui.setupEventHandlers()

	-- Initial update
	MainGui.updateDisplay()

	return screenGui
end

--[[
    Event Handlers
]]

function MainGui.setupEventHandlers()
	-- Write Code button click
	writeCodeButton.MouseButton1Click:Connect(function()
		MainGui.onWriteCodeClick()
	end)

	-- Upgrades button click
	upgradesButton.MouseButton1Click:Connect(function()
		MainGui.onUpgradesClick()
	end)
end

function MainGui.onWriteCodeClick()
	-- Add Robux
	local clickValue = DataManager.getClickValue()
	DataManager.addRobux(clickValue)

	-- Play sound
	UIUtils.playSound(GameConfig.SOUNDS.CLICK)

	-- Button animation
	UIUtils.buttonClickAnimation(writeCodeButton)

	-- Update display
	MainGui.updateDisplay()
end

function MainGui.onUpgradesClick()
	-- This will be handled by the UpgradesPanel module
	-- For now, just play a sound
	UIUtils.playSound(GameConfig.SOUNDS.CLICK)

	-- Notify other modules that upgrades button was clicked
	-- In a real implementation, you'd use a signal or event
	if MainGui.onUpgradesRequested then
		MainGui.onUpgradesRequested()
	end
end

--[[
    Display Update Functions
]]

function MainGui.updateDisplay()
	local playerData = DataManager.getPlayerData()
	local gameStats = DataManager.getGameStats()

	-- Update Robux counter
	robuxLabel.Text = "Robux: " .. UIUtils.formatNumber(playerData.robux)

	-- Update Write Code button text to show current click value
	local clickValue = DataManager.getClickValue()
	writeCodeButton.Text = "Write Code\n+" .. clickValue .. " Robux"
end

--[[
    Public Interface
]]

function MainGui.getGui(): ScreenGui
	return screenGui
end

function MainGui.getWriteCodeButton(): TextButton
	return writeCodeButton
end

function MainGui.getUpgradesButton(): TextButton
	return upgradesButton
end

function MainGui.getRobuxLabel(): TextLabel
	return robuxLabel
end

-- Callback for when upgrades are requested
MainGui.onUpgradesRequested = nil

function MainGui.setUpgradesCallback(callback)
	MainGui.onUpgradesRequested = callback
end

return MainGui
