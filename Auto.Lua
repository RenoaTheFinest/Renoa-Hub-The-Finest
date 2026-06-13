-- ================================================
-- AUTO TAB (BUBBLE + PICKUP)
-- ================================================
repeat task.wait() until getgenv().Window
local Window = getgenv().Window

local AutoTab = Window:CreateTab("Auto", nil)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Remote = require(ReplicatedStorage.Shared.Framework.Network.Remote)
local LocalData = require(ReplicatedStorage.Client.Framework.Services.LocalData)

-- ======================================
-- SETTINGS
-- ======================================
local bubbleEnabled = false
local pickupEnabled = false
local bubbleThread = nil
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
                        print("[Auto] 🧲 Magnetism added to " .. pet.Name)
                    end
                end
            end
        end
    end
    print("[Auto] 🧲 Re-equip your pets to apply!")
end

-- ======================================
-- UI
-- ======================================
AutoTab:CreateSection("🫧 Bubble")

AutoTab:CreateToggle({
    Name = "Auto Blow Bubble",
    CurrentValue = false,
    Callback = function(v)
        bubbleEnabled = v
        if v then
            bubbleThread = task.spawn(function()
                while bubbleEnabled do
                    pcall(function() Remote:FireServer("BlowBubble") end)
                    task.wait(0.05)
                end
            end)
            print("[Auto] Bubble started!")
        else
            if bubbleThread then task.cancel(bubbleThread) end
            print("[Auto] Bubble stopped!")
        end
    end
})

AutoTab:CreateSection("🧲 Pickup")

AutoTab:CreateToggle({
    Name = "Auto Pickup (Inject Magnetism)",
    CurrentValue = false,
    Callback = function(v)
        pickupEnabled = v
        if v then
            injectMagnetism()
            print("[Auto] 🧲 Magnetism injected! Re-equip pets now!")
        else
            print("[Auto] Pickup disabled!")
        end
    end
})

print("[Auto] Loaded! 🔥")
