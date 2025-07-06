--[[
    MainGui.luau
    Creates and manages the main game GUI
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local DataManager = require(ReplicatedStorage.Shared.DataManager)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local UIUtils = require(ReplicatedStorage.Shared.UIUtils)
local Types = require(ReplicatedStorage.Shared.Types)

local MainGui = {}

-- GUI references
local screenGui: ScreenGui
local mainContainer: Frame
local robuxLabel: TextLabel
local multiplierLabel: TextLabel
local writeCodeButton: TextButton
local upgradesButton: TextButton
local upgradesPanelInstance
local titleScreen: Frame
local playButton: TextButton

-- Game state
local displayedRobux = 0
local robuxTween: Tween
local canClick = true
local clickCooldown = 0.5 -- Default cooldown
local lastClickTime = 0
local streak = 0
local streakMultiplier = 1
local streakDecayTime = 1.2 -- seconds to reset streak
local streakMax = 10
MainGui._lastStreakTime = 0

-- Streak system config
local STREAK_TIME_WINDOW = 1.0 -- seconds allowed between clicks
local BASE_STREAK_CAP = 20 -- 20 streaks = +1.0x
local STREAK_STEP = 0.05 -- each streak adds +0.05x
local streakBonus = 0
local dualMonitorBonus = 0

function MainGui.create()
	-- Create ScreenGui
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TycoonTycoonGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 100
	screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	print("ScreenGui parented to PlayerGui!")

	-- Add fullscreen dark background
	local bg = Instance.new("Frame")
	bg.Name = "Background"
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.Position = UDim2.new(0, 0, 0, 0)
	bg.BackgroundColor3 = GameConfig.UI.COLORS.BACKGROUND
	bg.BackgroundTransparency = 0
	bg.BorderSizePixel = 0
	bg.ZIndex = 0
	bg.Parent = screenGui

	-- Create main container (for layout)
	mainContainer = Instance.new("Frame")
	mainContainer.Name = "MainContainer"
	mainContainer.Size = UDim2.new(1, 0, 1, 0)
	mainContainer.Position = UDim2.new(0, 0, 0, 0)
	mainContainer.BackgroundTransparency = 1
	mainContainer.ZIndex = 3
	mainContainer.Parent = screenGui

	-- Create Robux counter at top center
	robuxLabel = UIUtils.createTextLabel(
		mainContainer,
		"RobuxLabel",
		"Robux: 0",
		UDim2.new(0, 320, 0, 60),
		UDim2.new(0.5, -160, 0, 24)
	)
	robuxLabel.TextColor3 = GameConfig.UI.COLORS.SUCCESS
	robuxLabel.Font = GameConfig.UI.FONT
	robuxLabel.TextSize = 32
	robuxLabel.BackgroundTransparency = 1
	robuxLabel.ZIndex = 2

	-- Create multiplier label further below Robux
	multiplierLabel = UIUtils.createTextLabel(
		mainContainer,
		"MultiplierLabel",
		"",
		UDim2.new(0, 180, 0, 28),
		UDim2.new(0.5, -90, 0, 84) -- was 64, now 84 for more space
	)
	multiplierLabel.TextColor3 = Color3.fromRGB(120, 200, 255)
	multiplierLabel.Font = GameConfig.UI.FONT
	multiplierLabel.TextSize = 20
	multiplierLabel.BackgroundTransparency = 1
	multiplierLabel.ZIndex = 2
	multiplierLabel.Visible = false

	-- Create Write Code button in center
	writeCodeButton = UIUtils.createButton(
		mainContainer,
		"WriteCodeButton",
		"Write Code",
		UDim2.new(0, 340, 0, 110),
		UDim2.new(0.5, -170, 0.5, -55)
	)
	writeCodeButton.TextSize = 36
	writeCodeButton.ZIndex = 2

	-- Create Upgrades button in bottom-right
	upgradesButton = UIUtils.createButton(
		mainContainer,
		"UpgradesButton",
		"Upgrades",
		UDim2.new(0, 180, 0, 56),
		UDim2.new(1, -200, 1, -76)
	)
	upgradesButton.TextSize = 22
	upgradesButton.ZIndex = 2

	-- Create upgrades panel (hidden by default)
	upgradesPanelInstance = require(script.Parent.UpgradesPanel).create(mainContainer)
	upgradesPanelInstance.Visible = false

	-- Set up upgrade callback
	require(script.Parent.UpgradesPanel).setUpgradeCallback(function()
		MainGui.updateDisplay()
	end)

	-- Title Screen
	titleScreen = Instance.new("Frame")
	titleScreen.Name = "TitleScreen"
	titleScreen.Size = UDim2.new(1, 0, 1, 0)
	titleScreen.Position = UDim2.new(0, 0, 0, 0)
	titleScreen.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	titleScreen.BackgroundTransparency = 0
	titleScreen.ZIndex = 200
	titleScreen.Parent = screenGui

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, 0, 0, 120)
	titleLabel.Position = UDim2.new(0, 0, 0.25, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "Roblox Dev Incremental"
	titleLabel.TextColor3 = Color3.fromRGB(120, 255, 180)
	titleLabel.Font = GameConfig.UI.FONT
	titleLabel.TextSize = 56
	titleLabel.TextStrokeTransparency = 0.8
	titleLabel.ZIndex = 201
	titleLabel.Parent = titleScreen

	playButton = Instance.new("TextButton")
	playButton.Name = "PlayButton"
	playButton.Size = UDim2.new(0, 260, 0, 70)
	playButton.Position = UDim2.new(0.5, -130, 0.55, 0)
	playButton.BackgroundColor3 = GameConfig.UI.COLORS.ACCENT
	playButton.Text = "Play"
	playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	playButton.Font = GameConfig.UI.FONT
	playButton.TextSize = 32
	playButton.ZIndex = 201
	playButton.AutoButtonColor = true
	playButton.Parent = titleScreen

	local playCorner = Instance.new("UICorner")
	playCorner.CornerRadius = UDim.new(0, 18)
	playCorner.Parent = playButton

	playButton.MouseButton1Click:Connect(function()
		local tween = TweenService:Create(
			titleScreen,
			TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 1 }
		)
		local labelTween = TweenService:Create(
			titleLabel,
			TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ TextTransparency = 1, TextStrokeTransparency = 1 }
		)
		local buttonTween = TweenService:Create(
			playButton,
			TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ TextTransparency = 1, BackgroundTransparency = 1 }
		)
		tween:Play()
		labelTween:Play()
		buttonTween:Play()
		tween.Completed:Connect(function()
			titleScreen.Visible = false
		end)
	end)

	-- Set up event handlers
	MainGui.setupEventHandlers()

	-- Initial update
	MainGui.updateDisplay(true)

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
		print("DEBUG: Upgrades button clicked in MainGui")
		MainGui.onUpgradesClick()
	end)
end

function MainGui.onWriteCodeClick()
	if not canClick then
		return
	end

	local now = tick()
	local energyDrinksLevel = DataManager.getUpgradeLevel("energyDrinks")
	local dualMonitorLevel = DataManager.getUpgradeLevel("dualMonitor")

	-- Dual Monitor bonus is always present
	dualMonitorBonus = (1.2 ^ dualMonitorLevel) - 1

	-- Only build streak if Energy Drinks > 0
	if energyDrinksLevel > 0 then
		local streakStep = 0.05 * energyDrinksLevel
		local maxStreakBonus = 1.0 + (energyDrinksLevel * 0.5)
		local maxStreak = math.floor(maxStreakBonus / streakStep)
		if now - lastClickTime <= STREAK_TIME_WINDOW then
			streak += 1
		else
			streak = 1
		end
		lastClickTime = now
		local streakForBonus = math.min(streak, maxStreak)
		streakBonus = streakForBonus * streakStep
		if streakBonus > maxStreakBonus then
			streakBonus = maxStreakBonus
		end
	else
		streak = 0
		streakBonus = 0
		lastClickTime = now
	end

	-- Calculate total multiplier
	local totalMultiplier = 1 + streakBonus + dualMonitorBonus

	-- Get base click value
	local clickValue = DataManager.getClickValue()
	local finalValue = math.floor(clickValue * totalMultiplier)

	-- Add Robux
	DataManager.addRobux(finalValue)

	-- Update cooldown based on Fast Wi-Fi upgrade
	local fastWifiLevel = DataManager.getUpgradeLevel("fastWifi")
	local cooldownReduction = fastWifiLevel * 0.02 -- -0.02s per level
	clickCooldown = math.max(0.1, 0.5 - cooldownReduction) -- Base cooldown 0.5s

	-- Animate button
	UIUtils.buttonClickAnimation(writeCodeButton)

	-- Robux animation: faint green cash-shaped rectangle with random rotation
	local cashRect = Instance.new("Frame")
	cashRect.Size = UDim2.new(0, 48, 0, 22)
	local randX = math.random(5, 95) / 100 -- between 0.05 and 0.95
	cashRect.Position = UDim2.new(randX, -24, 0, -30)
	cashRect.BackgroundColor3 = Color3.fromRGB(120, 255, 120)
	cashRect.BackgroundTransparency = 0.65
	cashRect.ZIndex = 1
	cashRect.Rotation = math.random(-45, 45)
	cashRect.Parent = mainContainer
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = cashRect
	print("[DEBUG] Cash rectangle created at X:", randX)

	local endRotation = cashRect.Rotation + math.random(-30, 30)
	local tween = TweenService:Create(
		cashRect,
		TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Position = UDim2.new(randX, -24, 1, 30), BackgroundTransparency = 1, Rotation = endRotation }
	)
	tween:Play()
	tween.Completed:Connect(function()
		cashRect:Destroy()
	end)

	-- Update display
	MainGui.updateDisplay()

	-- Set cooldown
	canClick = false
	spawn(function()
		wait(clickCooldown)
		canClick = true
	end)
end

function MainGui.onUpgradesClick()
	print("DEBUG: MainGui.onUpgradesClick() called")
	if upgradesPanelInstance then
		upgradesPanelInstance.Visible = true
	end
	if MainGui.onUpgradesRequested then
		print("DEBUG: Calling onUpgradesRequested callback")
		MainGui.onUpgradesRequested()
	else
		print("DEBUG: onUpgradesRequested callback is nil!")
	end
end

--[[
    Display Update Functions
]]

function MainGui.updateDisplay(force)
	local now = tick()
	local playerData = DataManager.getPlayerData()
	local robux = playerData.robux
	if force or not robuxTween then
		displayedRobux = robux
		robuxLabel.Text = "Robux: " .. UIUtils.formatNumber(displayedRobux)
	else
		if robuxTween then
			robuxTween:Cancel()
		end
		robuxTween = TweenService:Create(
			robuxLabel,
			TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ TextTransparency = 0.2 }
		)
		robuxTween:Play()
		local start = displayedRobux
		local goal = robux
		local startTime = tick()
		local duration = 0.4
		spawn(function()
			while tick() - startTime < duration do
				local alpha = (tick() - startTime) / duration
				displayedRobux = math.floor(start + (goal - start) * alpha)
				robuxLabel.Text = "Robux: " .. UIUtils.formatNumber(displayedRobux)
				wait()
			end
			displayedRobux = goal
			robuxLabel.Text = "Robux: " .. UIUtils.formatNumber(displayedRobux)
		end)
	end

	-- Reset streak bonus if too slow (but not dual monitor bonus)
	local energyDrinksLevel = DataManager.getUpgradeLevel("energyDrinks")
	if energyDrinksLevel > 0 and now - lastClickTime > STREAK_TIME_WINDOW then
		streak = 0
		streakBonus = 0
	end

	-- Only show multiplier if player has at least one upgrade
	local hasUpgrade = false
	for _, v in pairs(playerData.upgrades) do
		if v > 0 then
			hasUpgrade = true
			break
		end
	end
	if hasUpgrade then
		local dualMonitorLevel = playerData.upgrades["dualMonitor"] or 0
		dualMonitorBonus = (1.2 ^ dualMonitorLevel) - 1
		local totalMultiplier = 1 + streakBonus + dualMonitorBonus
		multiplierLabel.Text = string.format("Multiplier: x%.2f", totalMultiplier)
		multiplierLabel.Visible = true
	else
		multiplierLabel.Visible = false
	end

	-- Update Write Code button text (base click value only)
	local clickValue = DataManager.getClickValue() -- base value, no multiplier
	writeCodeButton.RichText = true
	writeCodeButton.Text = string.format(
		'<b><font size="38">Write Code</font></b>\n<font size="20" color="#A0E6A0">+%d Robux</font>',
		clickValue
	)
end

function MainGui.getClickValue(): number
	return require(game.ReplicatedStorage.Shared.DataManager).getClickValue()
end

function MainGui.getClickCooldown()
	local base = 0.25
	local fastWifiLevel = MainGui.getUpgradeLevel("fastWifi") or 0
	return math.max(0.08, base - 0.02 * fastWifiLevel)
end

function MainGui.getStreakMultiplier()
	return 0.05 * (MainGui.getUpgradeLevel("energyDrinks") or 0)
end

function MainGui.getUpgradeLevel(upgradeType)
	local playerData = DataManager.getPlayerData()
	return playerData.upgrades and playerData.upgrades[upgradeType] or 0
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
	print("DEBUG: MainGui.setUpgradesCallback() called")
	MainGui.onUpgradesRequested = callback
end

return MainGui
