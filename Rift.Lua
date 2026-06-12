-- ================================================
-- RIFT TAB (SUMMON + TP + HATCH/OPEN)
-- ================================================
repeat task.wait() until getgenv().Window
local Window = getgenv().Window

local RiftTab = Window:CreateTab("Rift", nil)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

local RemoteEvent = ReplicatedStorage.Shared.Framework.Network.Remote.RemoteEvent
local RemoteFunction = ReplicatedStorage.Shared.Framework.Network.Remote.RemoteFunction

-- ======================================
-- EGG LOCATIONS
-- ======================================
local EGG_LOCATIONS = {
    ["Spikey Egg"] = Vector3.new(-128, 10, 9),
    ["Magma Egg"] = Vector3.new(-137, 11, 3),
    ["Crystal Egg"] = Vector3.new(-144, 10, -5),
    ["Lunar Egg"] = Vector3.new(-148, 11, -15),
    ["Void Egg"] = Vector3.new(-150, 11, -26),
    ["Hell Egg"] = Vector3.new(-149, 11, -37),
    ["Nightmare Egg"] = Vector3.new(9910, 20087, 208),
    ["Rainbow Egg"] = Vector3.new(9919, 20089, 219),
    ["Mining Egg"] = Vector3.new(-122, 11, -69),
    ["Cyber Egg"] = Vector3.new(9916, 20088, 214),
    ["Neon Egg"] = Vector3.new(9913, 20089, 212),
}

local WORLDS = {"The Overworld", "Minigame Paradise"}

local WORLD_EGGS = {
    ["The Overworld"] = {"Spikey Egg","Magma Egg","Crystal Egg","Lunar Egg","Void Egg","Hell Egg","Nightmare Egg","Rainbow Egg"},
    ["Minigame Paradise"] = {"Mining Egg","Cyber Egg","Neon Egg"},
}

local WORLD_CHESTS = {
    ["The Overworld"] = {"Golden Chest","Royal Chest","Super Chest"},
    ["Minigame Paradise"] = {"Dice Chest"},
}

local selectedEggWorld = "The Overworld"
local selectedEgg = "Spikey Egg"
local selectedChestWorld = "The Overworld"
local selectedChest = "Golden Chest"

local eggLoop = false
local chestLoop = false
local eggThread = nil
local chestThread = nil

local HATCH_AMOUNT = 12

-- ======================================
-- FUNCTIONS
-- ======================================
local function getRoot()
    local char = player.Character
    if char then return char:FindFirstChild("HumanoidRootPart") end
end

local function eggNameToKey(name)
    return name:lower():gsub("%s+", "-")
end

local function getRiftPosition(name)
    local key = eggNameToKey(name)
    local riftFolder = workspace:FindFirstChild("Rendered")
    if riftFolder then
        riftFolder = riftFolder:FindFirstChild("Rifts")
        if riftFolder then
            local rift = riftFolder:FindFirstChild(key)
            if rift then
                -- Try EggPlatformSpawn first
                local spawn = rift:FindFirstChild("EggPlatformSpawn")
                if spawn then
                    local part = spawn:FindFirstChild("Part")
                    if part then return part.Position end
                end
                -- Try Chest model
                local chest = rift:FindFirstChild("Chest")
                if chest then
                    for _, child in ipairs(chest:GetDescendants()) do
                        if child:IsA("BasePart") then
                            return child.Position
                        end
                    end
                end
                -- Fallback: any part
                for _, child in ipairs(rift:GetDescendants()) do
                    if child:IsA("BasePart") then
                        return child.Position
                    end
                end
            end
        end
    end
    return nil
end

local function teleportToRift(name)
    local pos = getRiftPosition(name)
    if pos then
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(pos)
            return true
        end
    end
    -- Fallback to normal egg
    local eggPos = EGG_LOCATIONS[name]
    if eggPos then
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(eggPos)
            return true
        end
    end
    return false
end

local function pressE()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.01)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- =========================
-- EGG RIFT
-- =========================
RiftTab:CreateSection("🥚 Egg Rift")

RiftTab:CreateDropdown({
    Name = "Egg World",
    Options = WORLDS,
    CurrentOption = {selectedEggWorld},
    Callback = function(v)
        selectedEggWorld = v[1]
        selectedEgg = WORLD_EGGS[selectedEggWorld][1]
    end
})

RiftTab:CreateDropdown({
    Name = "Egg",
    Options = WORLD_EGGS[selectedEggWorld],
    CurrentOption = {selectedEgg},
    Callback = function(v)
        selectedEgg = v[1]
    end
})

RiftTab:CreateInput({
    Name = "Hatch Amount",
    CurrentValue = tostring(HATCH_AMOUNT),
    PlaceholderText = "12",
    RemoveTextAfterFocusLost = false,
    Callback = function(v)
        local n = tonumber(v)
        if n then HATCH_AMOUNT = n end
    end
})

RiftTab:CreateToggle({
    Name = "Auto Egg Rift (Summon + TP + Hatch)",
    CurrentValue = false,
    Callback = function(v)
        eggLoop = v

        if v then
            eggThread = task.spawn(function()
                while eggLoop do
                    -- Summon rift
                    pcall(function()
                        RemoteFunction:InvokeServer(
                            "SummonRift",
                            {
                                Type = "Egg",
                                Name = selectedEgg,
                                Time = 5,
                                Luck = 5,
                                World = selectedEggWorld
                            }
                        )
                    end)
                    print("[Rift] 🌌 Summoned: " .. selectedEgg)
                    
                    -- Wait for rift
                    task.wait(3)
                    
                    -- Teleport
                    teleportToRift(selectedEgg)
                    
                    -- Hatch
                    pcall(function()
                        RemoteEvent:FireServer("HatchEgg", selectedEgg, HATCH_AMOUNT)
                    end)
                    print("[Rift] 🥚 Hatched " .. HATCH_AMOUNT)
                    
                    task.wait(1860)
                end
            end)
        else
            eggLoop = false
            if eggThread then task.cancel(eggThread) end
        end
    end
})

-- =========================
-- CHEST RIFT
-- =========================
RiftTab:CreateSection("💎 Chest Rift")

RiftTab:CreateDropdown({
    Name = "Chest World",
    Options = WORLDS,
    CurrentOption = {selectedChestWorld},
    Callback = function(v)
        selectedChestWorld = v[1]
        selectedChest = WORLD_CHESTS[selectedChestWorld][1]
    end
})

RiftTab:CreateDropdown({
    Name = "Chest",
    Options = WORLD_CHESTS[selectedChestWorld],
    CurrentOption = {selectedChest},
    Callback = function(v)
        selectedChest = v[1]
    end
})

RiftTab:CreateToggle({
    Name = "Auto Chest Rift (Summon + TP + Open)",
    CurrentValue = false,
    Callback = function(v)
        chestLoop = v

        if v then
            chestThread = task.spawn(function()
                while chestLoop do
                    -- Summon chest rift
                    pcall(function()
                        RemoteFunction:InvokeServer(
                            "SummonRift",
                            {
                                Type = "Chest",
                                Name = selectedChest,
                                Time = 5,
                                World = selectedChestWorld
                            }
                        )
                    end)
                    print("[Rift] 🌌 Summoned chest: " .. selectedChest)
                    
                    -- Wait for rift
                    task.wait(3)
                    
                    -- Teleport to chest
                    teleportToRift(selectedChest)
                    task.wait(0.5)
                    
                    -- Spam E until toggle turned off
                    while chestLoop do
                        pressE()
                        task.wait(0.01)
                    end
                end
            end)
        else
            chestLoop = false
            if chestThread then task.cancel(chestThread) end
        end
    end
})

print("[Rift] Loaded! 🔥")
