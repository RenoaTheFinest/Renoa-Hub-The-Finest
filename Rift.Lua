-- ================================================
-- EVENT TAB (OBSIDIAN SHOP + OBSIDIAN RIFT + SHRINE)
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
local obsidianShopRunning = false
local obsidianShopThread = nil

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
local function fireiceShrine()
    pcall(function()
        Remote:InvokeServer("DonateToFireIceShrine", "Speed", 6, FIREICE_AMOUNT)
        task.wait(1)
        RE:FireServer("ClaimFireIceBuff")
        print("[Event] Fire & Ice Shrine claimed!")
    end)
end

-- ======================================
-- UI - OBSIDIAN SHOP
-- ======================================
EventTab:CreateSection("Obsidian Shop")

EventTab:CreateToggle({
    Name = "Auto Buy Obsidian Key",
    CurrentValue = false,
    Callback = function(v)
        obsidianShopRunning = v
        if v then
            obsidianShopThread = task.spawn(function()
                while obsidianShopRunning do
                    pcall(function() Remote:FireServer("BuyShopItem", "obsidian-shop", 1, true) end)
                    print("[Event] Bought Obsidian Key!")
                    task.wait(3600)
                end
            end)
            print("[Event] Obsidian Shop started!")
        else
            if obsidianShopThread then task.cancel(obsidianShopThread) end
            print("[Event] Obsidian Shop stopped!")
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
                    while getgenv().questActive and obsidianEggRunning do
                        task.wait(5)
                    end
                    
                    pcall(function()
                        Remote:InvokeServer("SummonMoonRift", {
                            Type = "Egg",
                            Luck = 5,
                            Time = 5
                        })
                    end)
                    print("[Event] Obsidian Egg Rift summoned!")
                    
                    -- Spam teleport until it works
                    local teleported = false
                    while obsidianEggRunning and not teleported do
                        pcall(function() Remote:FireServer("TeleportToRift", "obsidian-rift") end)
                        task.wait(0.5)
                        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if root and root.Position.Y > 1000 then
                            teleported = true
                            print("[Event] Teleported to rift!")
                        end
                    end
                    
                    -- Hatch for 5 hours
                    local riftEndTime = os.time() + 18000
                    while obsidianEggRunning and os.time() < riftEndTime do
                        pcall(function() Remote:FireServer("HatchEgg", "Obsidian Egg", 12) end)
                        task.wait(0.3)
                    end
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
                    while getgenv().questActive and obsidianChestRunning do
                        task.wait(5)
                    end
                    
                    pcall(function()
                        Remote:InvokeServer("SummonMoonRift", {
                            Type = "Chest",
                            Time = 5
                        })
                    end)
                    print("[Event] Obsidian Chest Rift summoned!")
                    
                    -- Spam teleport until it works
                    local teleported = false
                    while obsidianChestRunning and not teleported do
                        pcall(function() Remote:FireServer("TeleportToRift", "obsidian-chest") end)
                        task.wait(0.5)
                        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if root and root.Position.Y > 1000 then
                            teleported = true
                            print("[Event] Teleported to chest rift!")
                        end
                    end
                    
                    -- Open for 5 hours
                    local riftEndTime = os.time() + 18000
                    while obsidianChestRunning and os.time() < riftEndTime do
                        pcall(function() Remote:FireServer("UnlockRiftChest", "obsidian-chest", false) end)
                        task.wait(0.3)
                    end
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
