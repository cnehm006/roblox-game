--[[
    Client Init Script
    Entry point for Tycoon Tycoon. GUI-only mode.
]]

-- GUI-only: Hide character, freeze camera, disable reset, disable all CoreGui
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

-- Hide character
if player.Character then
	player.Character:Destroy()
end
player.CharacterAdded:Connect(function(char)
	char:Destroy()
end)

-- Freeze camera
workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable

-- Disable reset button
pcall(function()
	StarterGui:SetCore("ResetButtonCallback", false)
end)

-- Hide all Roblox Core UI
pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
end)

-- Start the game
local gameControllerModule = script.Parent:FindFirstChild("GameController")
assert(gameControllerModule, "GameController module not found!")
local GameController = require(gameControllerModule)
GameController.init()
GameController.startGame()
