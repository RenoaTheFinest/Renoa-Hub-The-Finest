-- ================================================
-- AUTO TAB (AUTO HATCH + BOUNTY + RIFT)
-- ================================================
repeat task.wait() until getgenv().Window
local Window = getgenv().Window

local AutoTab = Window:CreateTab("Auto", nil)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- ======================================
-- DATA MODULES
-- ======================================
local SecretBountyUtil = require(ReplicatedStorage.Shared.Utils.Stats.SecretBountyUtil)
local Rifts = require(ReplicatedStorage.Shared.Data.Rifts)
local Remote = require(ReplicatedStorage.Shared.Framework.Network.Remote)
local RemoteFunction = ReplicatedStorage.Shared.Framework.Network.Remote.RemoteFunction

-- ======================================
-- ALL EGG LOCATIONS (Permanent + Event)
-- ======================================
local EGG_LOCATIONS = {
    ["Common Egg"] = Vector3.new(-60, 13, -65),
    ["Inferno Egg"] = Vector3.new(61, -39, -37),
    ["Classic Egg"] = Vector3.new(-90, 13, 30),
    ["Vine Egg"] = Vector3.new(-61, 13, 11),
    ["Lava Egg"] = Vector3.new(-69, 14, 19),
    ["Icy Egg"] = Vector3.new(-55, 14, 0),
    ["Iceshard Egg"] = Vector3.new(9905, 20087, 210),
    ["Spotted Egg"] = Vector3.new(-11, 10, -69),
    ["Atlantis Egg"] = Vector3.new(-79, 14, 25),
    ["Mining Egg"] = Vector3.new(-122, 11, -69),
    ["Neon Egg"] = Vector3.new(9913, 20089, 212),
    ["Cyber Egg"] = Vector3.new(9916, 20088, 214),
    ["Rainbow Egg"] = Vector3.new(9919, 20089, 219),
    ["Nightmare Egg"] = Vector3.new(9910, 20087, 208),
    ["Infinity Egg"] = Vector3.new(-106, 12, -28),
    ["Spikey Egg"] = Vector3.new(-128, 10, 9),
    ["Magma Egg"] = Vector3.new(-137, 11, 3),
    ["Crystal Egg"] = Vector3.new(-144, 10, -5),
    ["Lunar Egg"] = Vector3.new(-148, 11, -15),
    ["Void Egg"] = Vector3.new(-150, 11, -26),
    ["Hell Egg"] = Vector3.new(-149, 11, -37),
    ["Tropical Egg"] = Vector3.new(-303, 12, -5012),
    ["Research Egg"] = Vector3.new(-323, 13, -5006),
    ["Summer Egg"] = Vector3.new(-313, 13, -5009),
    ["Oceanic Egg"] = Vector3.new(-6548, 13, -8350),
    ["Flower Kingdom Egg"] = Vector3.new(-6348, 83, -4740),
    ["600M Egg"] = Vector3.new(2366, 3162, 972),
}

-- World mapping
local EGG_WORLDS = {
    ["Common Egg"] = "The Overworld",
    ["Inferno Egg"] = "The Overworld",
    ["Classic Egg"] = "The Overworld",
    ["Vine Egg"] = "The Overworld",
    ["Lava Egg"] = "The Overworld",
    ["Icy Egg"] = "The Overworld",
    ["Iceshard Egg"] = "The Overworld",
    ["Spotted Egg"] = "The Overworld",
    ["Atlantis Egg"] = "The Overworld",
    ["Mining Egg"] = "Minigame Paradise",
    ["Neon Egg"] = "Minigame Paradise",
    ["Cyber Egg"] = "Minigame Paradise",
    ["Rainbow Egg"] = "The Overworld",
    ["Nightmare Egg"] = "The Overworld",
    ["Infinity Egg"] = "The Overworld",
    ["Spikey Egg"] = "The Overworld",
    ["Magma Egg"] = "The Overworld",
    ["Crystal Egg"] = "The Overworld",
    ["Lunar Egg"] = "The Overworld",
    ["Void Egg"] = "The Overworld",
    ["Hell Egg"] = "The Overworld",
    ["Tropical Egg"] = "The Overworld",
    ["Research Egg"] = "The Overworld",
    ["Summer Egg"] = "The Overworld",
    ["Oceanic Egg"] = "The Overworld",
    ["Flower Kingdom Egg"] = "The Overworld",
    ["600M Egg"] = "The Overworld",
}

-- All egg names
local ALL_EGG_NAMES = {}
for eggName, _ in pairs(EGG_LOCATIONS) do
    table.insert(ALL_EGG_NAMES, eggName)
end
table.sort(ALL_EGG_NAMES)

-- ======================================
-- VARIABLES
-- ======================================
local autoHatchEnabled = false
local bountyEnabled = false
local riftEnabled = false
local autoHatchThread = nil
local bountyThread = nil
local riftThread = nil
local selectedEgg = "Common Egg"
local currentBountyPet = "Unknown"
local currentBountyEgg = "Unknown"
local currentBountyChance = "Unknown"
local HATCH_AMOUNT = 12

-- ======================================
-- FUNCTIONS
-- ======================================
local function getRoot()
    local char = player.Character
    if char then return char:FindFirstChild("HumanoidRootPart") end
end

local function eggNameToKey(eggName)
    return eggName:lower():gsub("%s+", "-")
end

local function isRiftActive(eggName)
    local key = eggNameToKey(eggName) .. "-egg"
    return Rifts[key] ~= nil
end

local function getRiftPosition(eggName)
    local world = EGG_WORLDS[eggName] or "The Overworld"
    local worldObj = workspace.Worlds:FindFirstChild(world)
    if worldObj then
        local islands = worldObj:FindFirstChild("Islands")
        if islands then
            for _, island in ipairs(islands:GetChildren()) do
                if island.Name:lower():find("rift") or island.Name:lower():find(eggNameToKey(eggName)) then
                    if island:IsA("Model") then
                        return island:GetPivot().Position
                    end
                end
            end
        end
    end
    return nil
end

local function teleportToEgg(eggName)
    -- Check if rift is active
    if isRiftActive(eggName) then
        local riftPos = getRiftPosition(eggName)
        if riftPos then
            local root = getRoot()
            if root then
                root.CFrame = CFrame.new(riftPos)
                print("[Auto] 🌀 Teleported to RIFT for: " .. eggName)
                return true
            end
        end
    end
    
    -- Fallback to normal egg
    local pos = EGG_LOCATIONS[eggName]
    if pos then
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(pos)
            print("[Auto] 🥚 Teleported to normal egg: " .. eggName)
            return true
        end
    end
    return false
end

local function updateBountyInfo()
    local ok, bounty = pcall(function()
        return SecretBountyUtil:Get()
    end)
    if ok and bounty then
        currentBountyPet = bounty.Name or "Unknown"
        currentBountyEgg = bounty.Egg or "Unknown"
        currentBountyChance = bounty.Chance and "1/" .. tostring(math.floor(1/bounty.Chance)) or "Unknown"
        return true
    end
    return false
end

local function getTimeUntilReset()
    local sign = workspace:FindFirstChild("Worlds")
    if sign then
        sign = sign:FindFirstChild("The Overworld")
        if sign then
            sign = sign:FindFirstChild("SecretBounty")
            if sign then
                local label = sign:FindFirstChild("Counter")
                if label then
                    label = label:FindFirstChild("Display")
                    if label then
                        label = label:FindFirstChild("SurfaceGui")
                        if label then
                            label = label:FindFirstChild("Label")
                            if label then
                                return label.Text
                            end
                        end
                    end
                end
            end
        end
    end
    return "Unknown"
end

local function summonRift()
    local world = EGG_WORLDS[currentBountyEgg] or "The Overworld"
    pcall(function()
        RemoteFunction:InvokeServer(
            "SummonRift",
            {
                Type = "Egg",
                Name = currentBountyEgg,
                Time = 5,
                Luck = 5,
                World = world
            }
        )
    end)
    print("[Auto] Rift summoned for: " .. currentBountyEgg)
end

-- ======================================
-- UI - AUTO HATCH SELECTED EGG
-- ======================================
AutoTab:CreateSection("🥚 Auto Hatch Selected Egg")

AutoTab:CreateDropdown({
    Name = "Select Egg",
    CurrentOption = {"Common Egg"},
    Options = ALL_EGG_NAMES,
    Callback = function(v)
        selectedEgg = v[1] or v
        print("[Auto] Selected egg: " .. selectedEgg)
    end
})

AutoTab:CreateInput({
    Name = "Hatch Amount",
    CurrentValue = tostring(HATCH_AMOUNT),
    PlaceholderText = "12",
    RemoveTextAfterFocusLost = false,
    Callback = function(v)
        local n = tonumber(v)
        if n then
            HATCH_AMOUNT = n
        end
    end
})

AutoTab:CreateToggle({
    Name = "Auto Hatch (Teleport + Hatch)",
    CurrentValue = false,
    Callback = function(v)
        autoHatchEnabled = v
        
        if v then
            autoHatchThread = task.spawn(function()
                while autoHatchEnabled do
                    local success = teleportToEgg(selectedEgg)
                    if success then
                        pcall(function()
                            Remote:InvokeServer("HatchEgg", selectedEgg, HATCH_AMOUNT)
                        end)
                        print("[Auto] Hatched " .. HATCH_AMOUNT .. " | " .. selectedEgg)
                    end
                    task.wait(0.5)
                end
            end)
        else
            if autoHatchThread then
                task.cancel(autoHatchThread)
                autoHatchThread = nil
            end
        end
    end
})

-- ======================================
-- UI - BOUNTY SECTION
-- ======================================
updateBountyInfo()

AutoTab:CreateSection("🎯 Current Bounty")

local bountyPetLabel = AutoTab:CreateLabel("Pet: " .. currentBountyPet)
local bountyEggLabel = AutoTab:CreateLabel("Egg: " .. currentBountyEgg)
local bountyChanceLabel = AutoTab:CreateLabel("Chance: " .. currentBountyChance)
local bountyResetLabel = AutoTab:CreateLabel("Resets in: " .. getTimeUntilReset())

local function refreshBountyLabels()
    updateBountyInfo()
    bountyPetLabel:SetText("Pet: " .. currentBountyPet)
    bountyEggLabel:SetText("Egg: " .. currentBountyEgg)
    bountyChanceLabel:SetText("Chance: " .. currentBountyChance)
    bountyResetLabel:SetText("Resets in: " .. getTimeUntilReset())
end

AutoTab:CreateToggle({
    Name = "Auto Bounty (Teleport + Hatch)",
    CurrentValue = false,
    Callback = function(v)
        bountyEnabled = v
        
        if v then
            refreshBountyLabels()
            
            bountyThread = task.spawn(function()
                while bountyEnabled do
                    local oldEgg = currentBountyEgg
                    refreshBountyLabels()
                    
                    if currentBountyEgg ~= oldEgg then
                        print("[Auto] 🔄 Bounty changed! New: " .. currentBountyPet .. " | " .. currentBountyEgg)
                    end
                    
                    local success = teleportToEgg(currentBountyEgg)
                    if success then
                        pcall(function()
                            Remote:InvokeServer("HatchEgg", currentBountyEgg, HATCH_AMOUNT)
                        end)
                        print("[Auto] Hatched " .. HATCH_AMOUNT .. " | " .. currentBountyEgg)
                    end
                    
                    task.wait(0.5)
                end
            end)
        else
            if bountyThread then
                task.cancel(bountyThread)
                bountyThread = nil
            end
        end
    end
})

-- ======================================
-- UI - RIFT SECTION
-- ======================================
AutoTab:CreateSection("🌌 Auto Rift")

AutoTab:CreateToggle({
    Name = "Auto Summon Rift",
    CurrentValue = false,
    Callback = function(v)
        riftEnabled = v
        
        if v then
            refreshBountyLabels()
            summonRift()
            
            riftThread = task.spawn(function()
                while riftEnabled do
                    task.wait(1860)
                    refreshBountyLabels()
                    summonRift()
                end
            end)
        else
            if riftThread then
                task.cancel(riftThread)
                riftThread = nil
            end
        end
    end
})

print("[Auto] Loaded! 🔥")
