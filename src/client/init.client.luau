--[[
    Client Init Script
    Entry point for Tycoon Tycoon. GUI-only mode.
]]

-- GUI-only: Hide character, freeze camera, disable reset, disable all CoreGui
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Hide character
if player.Character then
	player.Character:Destroy()
end
player.CharacterAdded:Connect(function(char)
	char:Destroy()
end)

-- Freeze camera every frame
RunService.RenderStepped:Connect(function()
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
end)

-- Disable reset button
pcall(function()
	StarterGui:SetCore("ResetButtonCallback", false)
end)

-- Hide all Roblox Core UI
pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
end)

-- Start the game
local clientFolder = script.Parent:FindFirstChild("Client")
assert(clientFolder, "Client folder not found!")
local gameControllerModule = clientFolder:FindFirstChild("GameController")
assert(gameControllerModule, "GameController module not found!")
local GameController = require(gameControllerModule)
print("DEBUG: About to call GameController.init()")
GameController.init()
print("DEBUG: GameController.init() completed")
GameController.startGame()
