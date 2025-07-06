--[[
    Types.luau
    Defines all data structures and types used in Tycoon Tycoon
]]

export type UpgradeType = "mechanicalKeyboard" | "dualMonitor" | "fastWifi" | "energyDrinks"

export type UpgradeData = {
	name: string,
	description: string,
	baseCost: number,
	costMultiplier: number,
	maxLevel: number,
	effect: string,
}

export type PlayerData = {
	robux: number,
	upgrades: { [UpgradeType]: number },
	lastSave: number,
}

export type GameStats = {
	clicksPerSecond: number,
	passiveIncome: number,
	totalClicks: number,
	totalEarned: number,
}

return {}
