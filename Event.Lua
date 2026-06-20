-- ================================================
-- EVENT TAB (GIFT RAIN + OBSIDIAN RIFT + SHRINE)
-- ================================================
repeat task.wait() until getgenv().Window
local Window = getgenv().Window

local EventTab = Window:CreateTab("Event", nil)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local RE = ReplicatedStorage.Shared.Framework.Network.Remote.RemoteEvent
local Remote = require(ReplicatedStorage.Shared.Framework.Network.Remote)

local function fire(action, ...)
    if RE then RE:FireServer(action, ...) end
end

-- ======================================
-- SETTINGS
-- ======================================
local rainRunning = false
local rainThread = nil

local obsidianEggRunning = false
local obsidianEggThread = nil
local obsidianChestRunning = false
local obsidianChestThread = nil

local fireiceEnabled = false
local fireiceThread = nil
local FIREICE_AMOUNT = 400
local INTERVAL = 43200

-- ======================================
-- FUNCTIONS
-- ======================================
local function getRoot()
    local char = player.Character
    if char then return char:FindFirstChild("HumanoidRootPart") end
end

local function collectAllPresents()
    local rendered = workspace:FindFirstChild("Rendered")
    if not rendered then return 0 end
    
    local presentRain = rendered:FindFirstChild("PresentRain")
    if not presentRain then return 0 end
    
    local root = getRoot()
    local previousPos = root and root.Position or nil
    
    local collected = 0
    for _, model in ipairs(presentRain:GetChildren()) do
        if model:IsA("Model") then
            for _, part in ipairs(model:GetChildren()) do
                if part:IsA("BasePart") then
                    local root = getRoot()
                    if root then
                        root.CFrame = CFrame.new(part.Position + Vector3.new(0, 2, 0))
                        collected = collected + 1
                        task.wait(0.02)
                    end
                    break
                end
            end
        end
    end
    
    if previousPos then
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(previousPos)
        end
    end
    
    return collected
end

local function fireiceShrine()
    pcall(function()
        Remote:InvokeServer("DonateToFireIceShrine", "Speed", 6, FIREICE_AMOUNT)
        task.wait(1)
        RE:FireServer("ClaimFireIceBuff")
        print("[Event] Fire & Ice Shrine claimed!")
    end)
end

-- ======================================
-- UI - GIFT RAIN
-- ======================================
EventTab:CreateSection("Gift Rain")

EventTab:CreateToggle({
    Name = "Auto Collect Presents",
    CurrentValue = false,
    Callback = function(v)
        rainRunning = v
        if v then
            rainThread = task.spawn(function()
                while rainRunning do
                    local count = collectAllPresents()
                    if count > 0 then
                        print("[Event] Collected " .. count .. " presents!")
                    end
                    task.wait(0.5)
                end
            end)
            print("[Event] Gift Rain started!")
        else
            if rainThread then task.cancel(rainThread) end
            print("[Event] Gift Rain stopped!")
        end
    end
})

-- ======================================
-- UI - OBSIDIAN RIFT
-- ======================================
EventTab:CreateSection("Obsidian Rift")

EventTab:CreateToggle({
    Name = "Auto Obsidian Egg (Summon + TP + Hatch)",
    CurrentValue = false,
    Callback = function(v)
        obsidianEggRunning = v
        if v then
            obsidianEggThread = task.spawn(function()
                while obsidianEggRunning do
                    pcall(function()
                        Remote:InvokeServer("SummonMoonRift", {
                            Type = "Egg",
                            Luck = 5,
                            Time = 5
                        })
                    end)
                    print("[Event] Obsidian Egg Rift summoned!")
                    
                    task.wait(3)
                    
                    pcall(function() Remote:FireServer("TeleportToRift", "obsidian-rift") end)
                    task.wait(0.5)
                    
                    pcall(function() Remote:FireServer("HatchEgg", "Obsidian Egg", 12) end)
                    print("[Event] Hatching Obsidian Egg!")
                    
                    task.wait(1860)
                end
            end)
            print("[Event] Obsidian Egg started!")
        else
            if obsidianEggThread then task.cancel(obsidianEggThread) end
            print("[Event] Obsidian Egg stopped!")
        end
    end
})

EventTab:CreateToggle({
    Name = "Auto Obsidian Chest (Summon + TP + Open)",
    CurrentValue = false,
    Callback = function(v)
        obsidianChestRunning = v
        if v then
            obsidianChestThread = task.spawn(function()
                while obsidianChestRunning do
                    pcall(function()
                        Remote:InvokeServer("SummonMoonRift", {
                            Type = "Chest",
                            Time = 5
                        })
                    end)
                    print("[Event] Obsidian Chest Rift summoned!")
                    
                    task.wait(3)
                    
                    pcall(function() Remote:FireServer("TeleportToRift", "obsidian-chest") end)
                    task.wait(0.5)
                    
                    pcall(function() Remote:FireServer("UnlockRiftChest", "obsidian-chest", false) end)
                    print("[Event] Obsidian Chest opened!")
                    
                    task.wait(1860)
                end
            end)
            print("[Event] Obsidian Chest started!")
        else
            if obsidianChestThread then task.cancel(obsidianChestThread) end
            print("[Event] Obsidian Chest stopped!")
        end
    end
})

-- ======================================
-- UI - SHRINE
-- ======================================
EventTab:CreateSection("Shrine")

EventTab:CreateInput({
    Name = "Amount",
    CurrentValue = tostring(FIREICE_AMOUNT),
    PlaceholderText = "400",
    RemoveTextAfterFocusLost = false,
    Callback = function(v)
        local n = tonumber(v)
        if n then FIREICE_AMOUNT = n end
    end
})

EventTab:CreateToggle({
    Name = "Auto Fire & Ice Shrine",
    CurrentValue = false,
    Callback = function(v)
        fireiceEnabled = v
        if v then
            fireiceShrine()
            fireiceThread = task.spawn(function()
                while fireiceEnabled do
                    task.wait(INTERVAL)
                    fireiceShrine()
                end
            end)
            print("[Event] Fire & Ice Shrine started!")
        else
            if fireiceThread then task.cancel(fireiceThread) end
            print("[Event] Fire & Ice Shrine stopped!")
        end
    end
})

print("[Event] Loaded!")
