--[[
    GameConfig.luau
    Contains all game configuration, constants, and upgrade definitions
]]

local Types = require(script.Parent.Types)

local GameConfig = {}

-- Game constants
GameConfig.INITIAL_ROBUX = 0
GameConfig.BASE_CLICK_VALUE = 1
GameConfig.PASSIVE_INCOME_INTERVAL = 5 -- seconds
GameConfig.AUTO_CLICK_INTERVAL = 1 -- seconds

-- Upgrade definitions
GameConfig.UPGRADES = {
	fasterTyping = {
		name = "Faster Typing",
		description = "Increase Robux per click",
		baseCost = 10,
		costMultiplier = 1.5,
		maxLevel = 10,
		effect = "+1 Robux per click",
	},

	interns = {
		name = "Interns",
		description = "Auto-click every second",
		baseCost = 50,
		costMultiplier = 2.0,
		maxLevel = 5,
		effect = "Auto-click every second",
	},

	laptopUpgrade = {
		name = "Laptop Upgrade",
		description = "Double click income",
		baseCost = 100,
		costMultiplier = 3.0,
		maxLevel = 3,
		effect = "Double click income",
	},

	studioHQ = {
		name = "Studio HQ",
		description = "Passive income every 5 seconds",
		baseCost = 500,
		costMultiplier = 2.5,
		maxLevel = 5,
		effect = "Passive income every 5 seconds",
	},
}

-- UI Configuration
GameConfig.UI = {
	COLORS = {
		PRIMARY = Color3.fromRGB(36, 41, 46), -- Modern dark
		SECONDARY = Color3.fromRGB(24, 26, 28), -- Even darker
		ACCENT = Color3.fromRGB(0, 184, 255), -- Cyan/blue accent
		ACCENT2 = Color3.fromRGB(255, 89, 94), -- Red accent
		SUCCESS = Color3.fromRGB(0, 200, 83), -- Green
		BACKGROUND = Color3.fromRGB(18, 20, 22), -- Deep dark
		CARD_BACKGROUND = Color3.fromRGB(28, 30, 34), -- Card dark
		TEXT_PRIMARY = Color3.fromRGB(240, 240, 240),
		TEXT_SECONDARY = Color3.fromRGB(180, 180, 180),
		SHADOW = Color3.fromRGB(0, 0, 0),
		GRADIENT1 = Color3.fromRGB(0, 184, 255),
		GRADIENT2 = Color3.fromRGB(0, 131, 176),
	},

	SIZES = {
		BUTTON_HEIGHT = 50,
		CARD_PADDING = 12,
		CORNER_RADIUS = 12,
		STROKE_THICKNESS = 3,
	},

	ANIMATIONS = {
		BUTTON_CLICK_DURATION = 0.12,
		BUTTON_HOVER_SCALE = 1.04,
		PANEL_OPEN_DURATION = 0.32,
		TWEEN_STYLE = Enum.EasingStyle.Quad,
		TWEEN_DIRECTION = Enum.EasingDirection.Out,
	},

	FONT = Enum.Font.Gotham,
}

-- Sound IDs (you can replace these with actual sound IDs)
GameConfig.SOUNDS = {
	CLICK = "rbxasset://sounds/electronicpingshort.wav",
	UPGRADE = "rbxasset://sounds/electronicpingshort.wav",
	ERROR = "rbxasset://sounds/electronicpingshort.wav",
}

return GameConfig
