-- ================================================
-- AUTO TAB (BUBBLE + SELL + PICKUP)
-- ================================================
repeat task.wait() until getgenv().Window
local Window = getgenv().Window

local AutoTab = Window:CreateTab("Auto", nil)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local LocalData = require(ReplicatedStorage.Client.Framework.Services.LocalData)

local RE = ReplicatedStorage.Shared.Framework.Network.Remote.RemoteEvent

local function fire(action, ...)
    if RE then RE:FireServer(action, ...) end
end

-- ======================================
-- SETTINGS
-- ======================================
local bubbleEnabled = false
local sellEnabled = false
local pickupEnabled = false
local bubbleThread = nil
local sellThread = nil
local pickupThread = nil

-- ======================================
-- FUNCTIONS
-- ======================================
local function injectMagnetism()
    local data = LocalData:Get()
    local activeTeam = data.Teams[data.TeamEquipped or 1]
    if activeTeam and activeTeam.Pets then
        for _, petId in ipairs(activeTeam.Pets) do
            for _, pet in pairs(data.Pets) do
                if pet.Id == petId then
                    local hasMagnetism = false
                    for _, enchant in pairs(pet.Enchants) do
                        if type(enchant) == "table" and enchant.Id == "magnetism" then
                            hasMagnetism = true
                            break
                        end
                    end
                    if not hasMagnetism then
                        local nextKey = #pet.Enchants + 1
                        pet.Enchants[nextKey] = {
                            Id = "magnetism",
                            Level = 1,
                            Extra = 999999
                        }
                        print("[Auto] Magnetism added to " .. pet.Name)
                    end
                end
            end
        end
    end
    print("[Auto] Re-equip your pets to apply!")
end

local function getPickups()
    local pickups = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "Pickup" or v:FindFirstChild("PickupId") then
            local id = v:GetAttribute("Id") 
                or v:GetAttribute("PickupId") 
                or v.Name
            if id then
                table.insert(pickups, id)
            end
        end
    end
    return pickups
end

local function collectAll()
    local list = getPickups()
    for _, id in ipairs(list) do
        pcall(function()
            RE:FireServer("CollectPickup", id)
        end)
    end
end

-- ======================================
-- UI
-- ======================================
AutoTab:CreateSection("Bubble")

AutoTab:CreateToggle({
    Name = "Auto Blow Bubble",
    CurrentValue = false,
    Callback = function(v)
        bubbleEnabled = v
        if v then
            bubbleThread = task.spawn(function()
                while bubbleEnabled do
                    pcall(function() fire("BlowBubble") end)
                    task.wait(0.01)
                end
            end)
            print("[Auto] Bubble started!")
        else
            if bubbleThread then task.cancel(bubbleThread) end
            print("[Auto] Bubble stopped!")
        end
    end
})

AutoTab:CreateSection("Sell")

AutoTab:CreateToggle({
    Name = "Auto Sell Bubble",
    CurrentValue = false,
    Callback = function(v)
        sellEnabled = v
        if v then
            local sellRoot = nil
            local originalPos = nil
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name == "Root" and obj.Parent and obj.Parent.Name == "Sell" then
                    sellRoot = obj
                    originalPos = obj.Position
                    break
                end
            end
            
            if not sellRoot then
                print("[Auto] No sell area found!")
                sellEnabled = false
                return
            end
            
            sellThread = task.spawn(function()
                while sellEnabled do
                    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        sellRoot.Position = root.Position + Vector3.new(0, -3, 0)
                    end
                    pcall(function() fire("SellBubble") end)
                    task.wait(1)
                end
                if originalPos then
                    sellRoot.Position = originalPos
                    print("[Auto] Sell Root returned!")
                end
            end)
            print("[Auto] Auto Sell started!")
        else
            if sellThread then task.cancel(sellThread) end
            print("[Auto] Auto Sell stopped!")
        end
    end
})

AutoTab:CreateSection("Pickup")

AutoTab:CreateToggle({
    Name = "Auto Collect Pickups",
    CurrentValue = false,
    Callback = function(v)
        pickupEnabled = v
        if v then
            pickupThread = task.spawn(function()
                while pickupEnabled do
                    collectAll()
                    task.wait(0.5)
                end
            end)
            print("[Auto] Pickup started!")
        else
            if pickupThread then task.cancel(pickupThread) end
            print("[Auto] Pickup stopped!")
        end
    end
})

print("[Auto] Loaded!")
