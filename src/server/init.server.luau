--[[
    Server Init Script
    Handles server-side initialization for Tycoon Tycoon
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("Tycoon Tycoon server started!")

-- Handle player joining
Players.PlayerAdded:Connect(function(player)
	print("Player joined: " .. player.Name)
end)

-- Handle player leaving
Players.PlayerRemoving:Connect(function(player)
	print("Player left: " .. player.Name)
end)
