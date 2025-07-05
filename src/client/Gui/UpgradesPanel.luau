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
local panel: Frame
local upgradeButtons: { [Types.UpgradeType]: Frame } = {}
local isOpen = false

--[[
    Panel Creation Functions
]]

function UpgradesPanel.create(parent: GuiObject)
	-- Create panel container
	panel = Instance.new("Frame")
	panel.Name = "UpgradesPanel"
	panel.Size = UDim2.new(0.8, 0, 0.8, 0)
	panel.Position = UDim2.new(0.1, 0, 0.1, 0)
	panel.BackgroundColor3 = GameConfig.UI.COLORS.BACKGROUND
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.Parent = parent

	-- Add rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, GameConfig.UI.SIZES.CORNER_RADIUS)
	corner.Parent = panel

	-- Add stroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = GameConfig.UI.COLORS.PRIMARY
	stroke.Thickness = GameConfig.UI.SIZES.STROKE_THICKNESS
	stroke.Parent = panel

	-- Create title
	local titleLabel =
		UIUtils.createTextLabel(panel, "TitleLabel", "Upgrades", UDim2.new(1, -40, 0, 60), UDim2.new(0, 20, 0, 20))
	titleLabel.TextColor3 = GameConfig.UI.COLORS.TEXT_PRIMARY
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 28

	-- Create close button
	local closeButton =
		UIUtils.createButton(panel, "CloseButton", "X", UDim2.new(0, 40, 0, 40), UDim2.new(1, -60, 0, 20))
	closeButton.TextSize = 20

	closeButton.MouseButton1Click:Connect(function()
		UpgradesPanel.close()
	end)

	-- Create upgrades grid
	UpgradesPanel.createUpgradesGrid()

	return panel
end

function UpgradesPanel.createUpgradesGrid()
	local gridContainer = Instance.new("Frame")
	gridContainer.Name = "GridContainer"
	gridContainer.Size = UDim2.new(1, -40, 1, -100)
	gridContainer.Position = UDim2.new(0, 20, 0, 80)
	gridContainer.BackgroundTransparency = 1
	gridContainer.Parent = panel

	-- Create grid layout
	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0.45, 0, 0.45, 0)
	gridLayout.CellPadding = UDim2.new(0.05, 0, 0.05, 0)
	gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	gridLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	gridLayout.Parent = gridContainer

	-- Create upgrade buttons for each upgrade type
	local upgradeTypes = { "fasterTyping", "interns", "laptopUpgrade", "studioHQ" }

	for i, upgradeType in ipairs(upgradeTypes) do
		local upgradeData = GameConfig.UPGRADES[upgradeType]
		if upgradeData then
			local upgradeButton = UIUtils.createUpgradeButton(
				gridContainer,
				upgradeType .. "Button",
				upgradeData,
				UDim2.new(1, 0, 1, 0),
				UDim2.new(0, 0, 0, 0)
			)

			upgradeButtons[upgradeType] = upgradeButton

			-- Set up click handler
			local costButton = upgradeButton:FindFirstChild("CostButton")
			if costButton then
				costButton.MouseButton1Click:Connect(function()
					UpgradesPanel.onUpgradeClick(upgradeType)
				end)
			end
		end
	end
end

--[[
    Event Handlers
]]

function UpgradesPanel.onUpgradeClick(upgradeType: Types.UpgradeType)
	local upgradeData = GameConfig.UPGRADES[upgradeType]
	if not upgradeData then
		return
	end

	local currentLevel = DataManager.getUpgradeLevel(upgradeType)
	if currentLevel >= upgradeData.maxLevel then
		UIUtils.playSound(GameConfig.SOUNDS.ERROR)
		return
	end

	local cost = DataManager.getUpgradeCost(upgradeType)
	if DataManager.purchaseUpgrade(upgradeType) then
		UIUtils.playSound(GameConfig.SOUNDS.UPGRADE)
		UpgradesPanel.updateUpgradeDisplay(upgradeType)

		-- Notify main GUI to update
		if UpgradesPanel.onUpgradePurchased then
			UpgradesPanel.onUpgradePurchased()
		end
	else
		UIUtils.playSound(GameConfig.SOUNDS.ERROR)
	end
end

--[[
    Display Update Functions
]]

function UpgradesPanel.updateUpgradeDisplay(upgradeType: Types.UpgradeType)
	local upgradeButton = upgradeButtons[upgradeType]
	if not upgradeButton then
		return
	end

	local upgradeData = GameConfig.UPGRADES[upgradeType]
	local currentLevel = DataManager.getUpgradeLevel(upgradeType)
	local cost = DataManager.getUpgradeCost(upgradeType)
	local canAfford = DataManager.canAffordUpgrade(upgradeType)

	-- Update cost button
	local costButton = upgradeButton:FindFirstChild("CostButton")
	if costButton then
		if currentLevel >= upgradeData.maxLevel then
			costButton.Text = "MAXED"
			costButton.BackgroundColor3 = GameConfig.UI.COLORS.ACCENT
		else
			costButton.Text = "Cost: " .. UIUtils.formatNumber(cost)
			costButton.BackgroundColor3 = canAfford and GameConfig.UI.COLORS.SUCCESS or GameConfig.UI.COLORS.ACCENT
		end
	end

	-- Update level label
	local levelLabel = upgradeButton:FindFirstChild("LevelLabel")
	if levelLabel then
		levelLabel.Text = "Level: " .. currentLevel .. "/" .. upgradeData.maxLevel
	end
end

function UpgradesPanel.updateAllDisplays()
	for upgradeType, _ in pairs(upgradeButtons) do
		UpgradesPanel.updateUpgradeDisplay(upgradeType)
	end
end

--[[
    Panel Control Functions
]]

function UpgradesPanel.open()
	if isOpen then
		return
	end

	panel.Visible = true
	panel.Size = UDim2.new(0, 0, 0, 0)
	panel.Position = UDim2.new(0.5, 0, 0.5, 0)

	-- Animate opening
	local openTween = UIUtils.tweenScale(panel, 1, GameConfig.UI.ANIMATIONS.PANEL_OPEN_DURATION)
	local positionTween =
		UIUtils.tweenPosition(panel, UDim2.new(0.1, 0, 0.1, 0), GameConfig.UI.ANIMATIONS.PANEL_OPEN_DURATION)

	openTween.Completed:Connect(function()
		isOpen = true
		UpgradesPanel.updateAllDisplays()
	end)
end

function UpgradesPanel.close()
	if not isOpen then
		return
	end

	-- Animate closing
	local closeTween = UIUtils.tweenScale(panel, 0, GameConfig.UI.ANIMATIONS.PANEL_OPEN_DURATION)
	local positionTween =
		UIUtils.tweenPosition(panel, UDim2.new(0.5, 0, 0.5, 0), GameConfig.UI.ANIMATIONS.PANEL_OPEN_DURATION)

	closeTween.Completed:Connect(function()
		panel.Visible = false
		isOpen = false
	end)
end

function UpgradesPanel.toggle()
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
