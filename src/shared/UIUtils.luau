--[[
    UIUtils.luau
    Utility functions for creating and styling UI elements (modern, animated)
]]

local TweenService = game:GetService("TweenService")
local GameConfig = require(script.Parent.GameConfig)

local UIUtils = {}

--[[
    UI Creation Functions
]]

function UIUtils.createFrame(parent: GuiObject, name: string, size: UDim2, position: UDim2): Frame
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = size
	frame.Position = position
	frame.BackgroundColor3 = GameConfig.UI.COLORS.CARD_BACKGROUND
	frame.BorderSizePixel = 0
	frame.BackgroundTransparency = 0.08
	frame.Parent = parent

	-- Add rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, GameConfig.UI.SIZES.CORNER_RADIUS)
	corner.Parent = frame

	-- Add drop shadow
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "DropShadow"
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://1316045217"
	shadow.ImageColor3 = GameConfig.UI.COLORS.SHADOW
	shadow.ImageTransparency = 0.7
	shadow.Size = UDim2.new(1, 24, 1, 24)
	shadow.Position = UDim2.new(0, -12, 0, -12)
	shadow.ZIndex = frame.ZIndex - 1
	shadow.Parent = frame

	-- Add stroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = GameConfig.UI.COLORS.PRIMARY
	stroke.Thickness = GameConfig.UI.SIZES.STROKE_THICKNESS
	stroke.Transparency = 0.7
	stroke.Parent = frame

	return frame
end

function UIUtils.createTextLabel(parent: GuiObject, name: string, text: string, size: UDim2, position: UDim2): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = GameConfig.UI.COLORS.TEXT_PRIMARY
	label.TextScaled = true
	label.Font = GameConfig.UI.FONT
	label.Parent = parent
	label.ZIndex = 2
	return label
end

function UIUtils.createButton(
	parent: GuiObject,
	name: string,
	text: string,
	size: UDim2,
	position: UDim2,
	soundId: string?
): TextButton
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = size
	button.Position = position
	button.BackgroundColor3 = GameConfig.UI.COLORS.PRIMARY
	button.Text = text
	button.TextColor3 = GameConfig.UI.COLORS.TEXT_PRIMARY
	button.TextScaled = true
	button.Font = GameConfig.UI.FONT
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Parent = parent
	button.ZIndex = 2

	local originalSize = size

	-- Add rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, GameConfig.UI.SIZES.CORNER_RADIUS)
	corner.Parent = button

	-- Add gradient (skip for CostButton)
	if name ~= "CostButton" then
		local gradient = Instance.new("UIGradient")
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, GameConfig.UI.COLORS.GRADIENT1),
			ColorSequenceKeypoint.new(1, GameConfig.UI.COLORS.GRADIENT2),
		})
		gradient.Rotation = 45
		gradient.Parent = button
	end

	-- Add stroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = GameConfig.UI.COLORS.ACCENT
	stroke.Thickness = GameConfig.UI.SIZES.STROKE_THICKNESS
	stroke.Transparency = 0.0
	stroke.Parent = button

	-- Add drop shadow
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "DropShadow"
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://1316045217"
	shadow.ImageColor3 = GameConfig.UI.COLORS.SHADOW
	shadow.ImageTransparency = 0.8
	shadow.Size = UDim2.new(1, 16, 1, 16)
	shadow.Position = UDim2.new(0, -8, 0, -8)
	shadow.ZIndex = button.ZIndex - 1
	shadow.Parent = button

	-- Button hover/press effects (fix: always scale from originalSize)
	local currentTween = nil
	local function tweenTo(scale, duration)
		if currentTween then
			currentTween:Cancel()
		end
		local newSize = UDim2.new(
			originalSize.X.Scale * scale,
			originalSize.X.Offset * scale,
			originalSize.Y.Scale * scale,
			originalSize.Y.Offset * scale
		)
		currentTween = TweenService:Create(
			button,
			TweenInfo.new(duration, GameConfig.UI.ANIMATIONS.TWEEN_STYLE, GameConfig.UI.ANIMATIONS.TWEEN_DIRECTION),
			{ Size = newSize }
		)
		currentTween:Play()
		return currentTween
	end
	button.MouseEnter:Connect(function()
		tweenTo(GameConfig.UI.ANIMATIONS.BUTTON_HOVER_SCALE, 0.15)
	end)
	button.MouseLeave:Connect(function()
		tweenTo(1, 0.15)
	end)
	button.MouseButton1Down:Connect(function()
		tweenTo(0.97, 0.08)
	end)
	button.MouseButton1Up:Connect(function()
		tweenTo(GameConfig.UI.ANIMATIONS.BUTTON_HOVER_SCALE, 0.12)
	end)

	return button
end

function UIUtils.createUpgradeButton(
	parent: GuiObject,
	name: string,
	upgradeData: any,
	size: UDim2,
	position: UDim2
): Frame
	local container = UIUtils.createFrame(parent, name, size, position)
	container.BackgroundColor3 = GameConfig.UI.COLORS.CARD_BACKGROUND
	container.BackgroundTransparency = 0.12
	container.ZIndex = 101

	-- Upgrade name
	local nameLabel = UIUtils.createTextLabel(
		container,
		"NameLabel",
		upgradeData.name,
		UDim2.new(1, -20, 0.3, 0),
		UDim2.new(0, 10, 0, 5)
	)
	nameLabel.TextColor3 = GameConfig.UI.COLORS.TEXT_PRIMARY
	nameLabel.Font = GameConfig.UI.FONT
	nameLabel.ZIndex = 102

	-- Upgrade description
	local descLabel = UIUtils.createTextLabel(
		container,
		"DescLabel",
		upgradeData.description,
		UDim2.new(1, -20, 0.2, 0),
		UDim2.new(0, 10, 0.3, 0)
	)
	descLabel.TextColor3 = GameConfig.UI.COLORS.TEXT_SECONDARY
	descLabel.Font = GameConfig.UI.FONT
	descLabel.ZIndex = 102

	-- Cost button
	local costButton =
		UIUtils.createButton(container, "CostButton", "Cost: 0", UDim2.new(1, -20, 0.3, 0), UDim2.new(0, 10, 0.6, 0))
	costButton.ZIndex = 102

	-- Level label
	local levelLabel = UIUtils.createTextLabel(
		container,
		"LevelLabel",
		"Level: 0",
		UDim2.new(1, -20, 0.2, 0),
		UDim2.new(0, 10, 0.9, 0)
	)
	levelLabel.TextColor3 = GameConfig.UI.COLORS.SUCCESS
	levelLabel.Font = GameConfig.UI.FONT
	levelLabel.ZIndex = 102

	return container
end

--[[
    Animation Functions
]]

function UIUtils.tweenScale(object: GuiObject, scale: number, duration: number)
	local tweenInfo =
		TweenInfo.new(duration, GameConfig.UI.ANIMATIONS.TWEEN_STYLE, GameConfig.UI.ANIMATIONS.TWEEN_DIRECTION)
	local newSize = UDim2.new(
		object.Size.X.Scale * scale,
		object.Size.X.Offset * scale,
		object.Size.Y.Scale * scale,
		object.Size.Y.Offset * scale
	)
	local tween = TweenService:Create(object, tweenInfo, {
		Size = newSize,
	})
	tween:Play()
	return tween
end

function UIUtils.tweenPosition(object: GuiObject, position: UDim2, duration: number)
	local tweenInfo =
		TweenInfo.new(duration, GameConfig.UI.ANIMATIONS.TWEEN_STYLE, GameConfig.UI.ANIMATIONS.TWEEN_DIRECTION)
	local tween = TweenService:Create(object, tweenInfo, {
		Position = position,
	})
	tween:Play()
	return tween
end

function UIUtils.tweenTransparency(object: GuiObject, transparency: number, duration: number)
	local tweenInfo =
		TweenInfo.new(duration, GameConfig.UI.ANIMATIONS.TWEEN_STYLE, GameConfig.UI.ANIMATIONS.TWEEN_DIRECTION)
	local tween = TweenService:Create(object, tweenInfo, {
		BackgroundTransparency = transparency,
	})
	tween:Play()
	return tween
end

function UIUtils.buttonClickAnimation(button: TextButton)
	-- Scale up
	local scaleUp = UIUtils.tweenScale(button, 1.12, GameConfig.UI.ANIMATIONS.BUTTON_CLICK_DURATION)
	scaleUp.Completed:Connect(function()
		-- Scale back down
		UIUtils.tweenScale(
			button,
			GameConfig.UI.ANIMATIONS.BUTTON_HOVER_SCALE,
			GameConfig.UI.ANIMATIONS.BUTTON_CLICK_DURATION
		)
	end)
end

--[[
    Utility Functions
]]

function UIUtils.formatNumber(number: number): string
	if number >= 1000000 then
		return string.format("%.1fM", number / 1000000)
	elseif number >= 1000 then
		return string.format("%.1fK", number / 1000)
	else
		return tostring(number)
	end
end

function UIUtils.playSound(soundId: string)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = 0.5
	sound.Parent = game:GetService("SoundService")
	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

return UIUtils
