-- ================================================
-- OTHER TAB (STATS TRACKER + MORE)
-- ================================================
repeat task.wait() until getgenv().Window
local Window = getgenv().Window

local OtherTab = Window:CreateTab("Other", nil)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- ======================================
-- STATS TRACKER
-- ======================================
local startTime = os.clock()
local totalHatched = 0

-- Hook into hatching to count
local HatchEggModule = require(ReplicatedStorage.Client.Effects.HatchEgg)
local oldPlay = HatchEggModule.Play

HatchEggModule.Play = newcclosure(function(self, data)
    if type(data) == "table" and data.Pets then
        totalHatched = totalHatched + #data.Pets
    end
    return oldPlay(self, data)
end)

OtherTab:CreateSection("📊 Stats Tracker")

local statsTimeLabel = OtherTab:CreateLabel("Time Playing: 0s")
local statsHatchedLabel = OtherTab:CreateLabel("Total Hatched: 0")
local statsRateLabel = OtherTab:CreateLabel("Rate: 0/min | 0/hr")

task.spawn(function()
    while true do
        local elapsed = os.clock() - startTime
        local minutes = elapsed / 60
        local hours = elapsed / 3600
        
        local perMin = minutes > 0 and math.floor(totalHatched / minutes) or 0
        local perHour = hours > 0 and math.floor(totalHatched / hours) or 0
        
        -- Format time
        local h = math.floor(elapsed / 3600)
        local m = math.floor((elapsed % 3600) / 60)
        local s = math.floor(elapsed % 60)
        local timeStr = string.format("%dh %dm %ds", h, m, s)
        
        pcall(function() statsTimeLabel:SetText("Time Playing: " .. timeStr) end)
        pcall(function() statsHatchedLabel:SetText("Total Hatched: " .. totalHatched) end)
        pcall(function() statsRateLabel:SetText("Rate: " .. perMin .. "/min | " .. perHour .. "/hr") end)
        
        task.wait(1)
    end
end)

print("[Other] Loaded! 🔥")
