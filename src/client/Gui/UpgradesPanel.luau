--[[
    UpgradesPanel.luau
    Creates and manages the upgrades panel with upgrade buttons
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataManager = require(ReplicatedStorage.Shared.DataManager)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local UIUtils = require(ReplicatedStorage.Shared.UIUtils)
local Types = require(ReplicatedStorage.Shared.Types)

local UpgradesPanel = {}

-- GUI references
local panel: Frame = nil
local upgradeButtons = {} -- Use string keys for upgradeButtons
local isOpen = false
local overlay: Frame = nil

-- Ensure phase1Upgrades is defined only once at the top level and not inside any function
local phase1Upgrades = {
	mechanicalKeyboard = {
		name = "Mechanical Keyboard",
		description = "+1 click power",
		effect = "+1 per level",
		baseCost = 20,
		costMultiplier = 1.5,
		maxLevel = 20,
	},
	dualMonitor = {
		name = "Dual Monitor",
		description = "1.2x click earnings",
		effect = "x1.2 per level",
		baseCost = 100,
		costMultiplier = 2.0,
		maxLevel = 10,
	},
	fastWifi = {
		name = "Fast Wi-Fi",
		description = "Reduces click cooldown",
		effect = "-0.02s per level",
		baseCost = 80,
		costMultiplier = 1.7,
		maxLevel = 10,
	},
	energyDrinks = {
		name = "Energy Drinks",
		description = "Streak multiplier",
		effect = "+5% per streak",
		baseCost = 60,
		costMultiplier = 1.6,
		maxLevel = 10,
	},
}

--[[
    Panel Creation Functions
]]

function UpgradesPanel.create(parent: GuiObject)
	if panel then
		print("UpgradesPanel.create called again, returning existing panel")
		return panel
	end
	print("UpgradesPanel.create: creating new panel")

	-- Create background overlay
	overlay = Instance.new("Frame")
	overlay.Name = "UpgradesOverlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.Position = UDim2.new(0, 0, 0, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	overlay.BackgroundTransparency = 0.35
	overlay.ZIndex = 2
	overlay.Visible = false
	overlay.Parent = parent

	panel = Instance.new("Frame")
	panel.Name = "UpgradesPanel"
	panel.Size = UDim2.new(0.5, 0, 0.6, 0)
	panel.Position = UDim2.new(0.25, 0, 0.2, 0)
	panel.BackgroundColor3 = GameConfig.UI.COLORS.CARD_BACKGROUND
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.ZIndex = 100
	panel.Parent = parent

	-- Add rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, GameConfig.UI.SIZES.CORNER_RADIUS)
	corner.Parent = panel

	-- Add stroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = GameConfig.UI.COLORS.ACCENT
	stroke.Thickness = GameConfig.UI.SIZES.STROKE_THICKNESS
	stroke.Parent = panel

	-- Create title
	local titleLabel =
		UIUtils.createTextLabel(panel, "TitleLabel", "Upgrades", UDim2.new(1, -40, 0, 60), UDim2.new(0, 20, 0, 20))
	titleLabel.TextColor3 = GameConfig.UI.COLORS.TEXT_PRIMARY
	titleLabel.Font = GameConfig.UI.FONT
	titleLabel.TextSize = 32
	titleLabel.ZIndex = 101

	-- Create close button
	local closeButton =
		UIUtils.createButton(panel, "CloseButton", "X", UDim2.new(0, 44, 0, 44), UDim2.new(1, -64, 0, 20))
	closeButton.TextSize = 22
	closeButton.ZIndex = 101

	closeButton.MouseButton1Click:Connect(function()
		print("Close button clicked") -- Debug
		UpgradesPanel.close()
	end)

	-- Create upgrades grid (responsive)
	UpgradesPanel.createUpgradesGrid(panel)

	return panel
end

function UpgradesPanel.createUpgradesGrid(parent)
	print("[DEBUG] createUpgradesGrid called")
	local gridContainer = Instance.new("Frame")
	assert(gridContainer, "Failed to create gridContainer Frame")
	gridContainer.Name = "GridContainer"
	gridContainer.Size = UDim2.new(1, -40, 1, -120)
	gridContainer.Position = UDim2.new(0, 20, 0, 100)
	gridContainer.BackgroundTransparency = 1
	gridContainer.ZIndex = 101
	gridContainer.Parent = parent

	-- Create grid layout
	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0.48, 0, 0.45, 0)
	gridLayout.CellPadding = UDim2.new(0.04, 0, 0.04, 0)
	gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	gridLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	gridLayout.Parent = gridContainer

	local count = 0
	for upgradeKey, upgradeData in pairs(phase1Upgrades) do
		print("[DEBUG] Creating upgrade button for:", upgradeKey)
		count = count + 1
		local upgradeButton = UIUtils.createUpgradeButton(
			gridContainer,
			upgradeKey .. "Button",
			upgradeData,
			UDim2.new(1, 0, 1, 0),
			UDim2.new(0, 0, 0, 0)
		)
		upgradeButtons[upgradeKey] = upgradeButton

		-- Set up click handler
		local costButton = upgradeButton:FindFirstChild("CostButton")
		if costButton then
			costButton.MouseButton1Click:Connect(function()
				UpgradesPanel.onUpgradeClick(upgradeKey)
			end)
		end
	end
	print("[DEBUG] Total upgrades created:", count)
end

--[[
    Event Handlers
]]

function UpgradesPanel.onUpgradeClick(upgradeType)
	print("Upgrade clicked:", upgradeType) -- Debug
	local upgradeData = phase1Upgrades[upgradeType]
	if not upgradeData then
		print("No upgrade data found for:", upgradeType) -- Debug
		return
	end

	local DataManager = require(game.ReplicatedStorage.Shared.DataManager)
	print("Attempting to purchase upgrade:", upgradeType) -- Debug
	if DataManager.purchaseUpgrade(upgradeType) then
		print("Upgrade purchased successfully:", upgradeType) -- Debug
		UpgradesPanel.updateUpgradeDisplay(upgradeType)
		-- Notify main GUI to update
		if UpgradesPanel.onUpgradePurchased then
			UpgradesPanel.onUpgradePurchased()
		end
	else
		print("Failed to purchase upgrade:", upgradeType) -- Debug
	end
end

--[[
    Display Update Functions
]]

function UpgradesPanel.updateUpgradeDisplay(upgradeType)
	local upgradeButton = upgradeButtons[upgradeType]
	if not upgradeButton then
		return
	end
	local upgradeData = phase1Upgrades[upgradeType]
	local DataManager = require(game.ReplicatedStorage.Shared.DataManager)
	local playerData = DataManager.getPlayerData()
	local currentLevel = playerData.upgrades[upgradeType] or 0
	local cost = DataManager.getUpgradeCost(upgradeType)
	local canAfford = DataManager.canAffordUpgrade(upgradeType)

	print("DEBUG: Upgrade:", upgradeType)
	print("DEBUG: Player Robux:", playerData.robux)
	print("DEBUG: Upgrade Cost:", cost)
	print("DEBUG: Can Afford:", canAfford)

	-- Update cost button
	local costButton = upgradeButton:FindFirstChild("CostButton")
	if costButton then
		local stroke = costButton:FindFirstChild("UIStroke")
		if currentLevel >= upgradeData.maxLevel then
			costButton.Text = "MAXED"
			costButton.TextColor3 = GameConfig.UI.COLORS.ACCENT2
			costButton.TextStrokeColor3 = GameConfig.UI.COLORS.ACCENT2
			costButton.AutoButtonColor = false
			if stroke then
				stroke.Color = GameConfig.UI.COLORS.ACCENT2 -- Red for maxed
				stroke.Transparency = 0
			end
		else
			costButton.Text = "Cost: " .. UIUtils.formatNumber(cost)
			local green = GameConfig.UI.COLORS.SUCCESS
			local accent = GameConfig.UI.COLORS.ACCENT2
			costButton.TextColor3 = canAfford and green or accent
			costButton.TextStrokeColor3 = canAfford and green or accent
			costButton.AutoButtonColor = canAfford
			if stroke then
				stroke.Transparency = 1 -- No outline for affordable or not affordable
			end
		end
	end
	-- Update level label
	local levelLabel = upgradeButton:FindFirstChild("LevelLabel")
	if levelLabel then
		levelLabel.Text = "Level: " .. currentLevel .. "/" .. upgradeData.maxLevel
	end
end

function UpgradesPanel.updateAllDisplays()
	print("DEBUG: updateAllDisplays() called")
	print("DEBUG: Number of upgrade buttons:", #upgradeButtons)
	for upgradeType, _ in pairs(upgradeButtons) do
		print("DEBUG: Updating display for:", upgradeType)
		UpgradesPanel.updateUpgradeDisplay(upgradeType)
	end
end

--[[
    Panel Control Functions
]]

function UpgradesPanel.open()
	print("DEBUG: UpgradesPanel.open() called")
	if isOpen then
		print("DEBUG: Panel already open, returning")
		return
	end
	if overlay then
		overlay.Visible = true
	end
	if panel then
		panel.Visible = true
		panel.ZIndex = 100
		panel.Size = UDim2.new(0.5, 0, 0.6, 0)
		panel.Position = UDim2.new(0.25, 0, 0.2, 0)
	end
	-- Animate opening
	local openTween = UIUtils.tweenScale(panel, 1, GameConfig.UI.ANIMATIONS.PANEL_OPEN_DURATION)
	local positionTween =
		UIUtils.tweenPosition(panel, UDim2.new(0.25, 0, 0.2, 0), GameConfig.UI.ANIMATIONS.PANEL_OPEN_DURATION)

	-- Update displays immediately and after animation
	UpgradesPanel.updateAllDisplays()

	openTween.Completed:Connect(function()
		print("DEBUG: Panel animation completed")
		isOpen = true
		UpgradesPanel.updateAllDisplays()
	end)
end

function UpgradesPanel.close()
	print("UpgradesPanel.close called") -- Debug
	if not isOpen then
		return
	end
	isOpen = false
	if panel then
		panel.Visible = false
	end
	if overlay then
		overlay.Visible = false
	end
end

function UpgradesPanel.toggle()
	print("DEBUG: UpgradesPanel.toggle() called, isOpen =", isOpen)
	if isOpen then
		UpgradesPanel.close()
	else
		UpgradesPanel.open()
	end
end

--[[
    Public Interface
]]

function UpgradesPanel.getPanel(): Frame
	return panel
end

function UpgradesPanel.isPanelOpen(): boolean
	return isOpen
end

-- Callback for when upgrades are purchased
UpgradesPanel.onUpgradePurchased = nil

function UpgradesPanel.setUpgradeCallback(callback)
	UpgradesPanel.onUpgradePurchased = callback
end

return UpgradesPanel
