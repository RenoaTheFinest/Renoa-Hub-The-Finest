-- ================================================
-- AUTO TAB (BOUNTY + MORE)
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
local Remote = require(ReplicatedStorage.Shared.Framework.Network.Remote)

-- ======================================
-- EGG LOCATIONS
-- ======================================
local EGG_LOCATIONS = {
    ["Common Egg"] = Vector3.new(-59.7594, 13.7468, -4.9295),
    ["Inferno Egg"] = Vector3.new(61.6161, -38.2405, -36.4416),
    ["Classic Egg"] = Vector3.new(-89.3765, 13.9007, 30.5915),
    ["Vine Egg"] = Vector3.new(-60.7224, 13.9614, 11.0473),
    ["Lava Egg"] = Vector3.new(-68.9796, 14.1626, 19.3721),
    ["Icy Egg"] = Vector3.new(-54.2339, 13.7070, 0.9815),
    ["Iceshard Egg"] = Vector3.new(-119.0674, 11.4101, 13.9992),
    ["Spotted Egg"] = Vector3.new(-91.7780, 12.9166, 12.3185),
    ["Atlantis Egg"] = Vector3.new(-78.4374, 14.7693, 25.9414),
    ["Mining Egg"] = Vector3.new(-121.7517, 11.0727, -68.1152),
    ["Neon Egg"] = Vector3.new(-81.3096, 10.9481, -60.4263),
    ["Cyber Egg"] = Vector3.new(-92.2678, 10.9795, -66.6913),
    ["Spikey Egg"] = Vector3.new(-128.6110, 10.8857, 9.7908),
    ["Magma Egg"] = Vector3.new(-137.1953, 11.1698, 3.5342),
    ["Crystal Egg"] = Vector3.new(-144.1717, 10.9745, -4.9899),
    ["Rainbow Egg"] = Vector3.new(-140.0540, 10.9538, -56.0581),
    ["Void Egg"] = Vector3.new(-150.2729, 11.1749, -26.0208),
    ["Showman Egg"] = Vector3.new(-131.7554, 12.0426, -63.2838),
    ["Hell Egg"] = Vector3.new(-149.3270, 11.1268, -36.8873),
    ["Nightmare Egg"] = Vector3.new(-146.0093, 10.9916, -46.9943),
    ["Lunar Egg"] = Vector3.new(-148.4841, 11.1363, -15.2603),
    ["Dice Egg"] = Vector3.new(9832.3232, 27.8746, 172.1069),
    ["Secret Egg"] = Vector3.new(-19438.9062, 8.6763, 18838.1113),
    ["Seal Egg"] = Vector3.new(24.7512, 10.4872, -5081.8105),
    ["Tropical Egg"] = Vector3.new(-296, 12, -5008),
    ["Summer Egg"] = Vector3.new(-310, 12, -5002),
    ["Flower Kingdom Egg"] = Vector3.new(-6349, 81, -4732),
}

-- ======================================
-- VARIABLES
-- ======================================
local bountyEnabled = false
local bountyThread = nil
local currentBountyPet = "Unknown"
local currentBountyEgg = "Unknown"
local currentBountyChance = "Unknown"
local hatchedCount = 0
local HATCH_AMOUNT = 12

-- ======================================
-- FUNCTIONS
-- ======================================
local function getRoot()
    local char = player.Character
    if char then return char:FindFirstChild("HumanoidRootPart") end
end

local function teleportToEgg(eggName)
    local pos = EGG_LOCATIONS[eggName]
    if pos then
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(pos)
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

-- ======================================
-- UI
-- ======================================
updateBountyInfo()

AutoTab:CreateSection("🎯 Current Bounty")

AutoTab:CreateLabel("Pet: " .. currentBountyPet)
AutoTab:CreateLabel("Egg: " .. currentBountyEgg)
AutoTab:CreateLabel("Chance: " .. currentBountyChance)
AutoTab:CreateLabel("Resets in: " .. getTimeUntilReset())

AutoTab:CreateSection("⚙️ Settings")

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

AutoTab:CreateButton({
    Name = "🔄 Refresh Bounty Info",
    Callback = function()
        updateBountyInfo()
        print("[Auto] Refreshed: " .. currentBountyPet .. " | " .. currentBountyEgg)
    end
})

AutoTab:CreateToggle({
    Name = "Auto Bounty (Teleport + Hatch)",
    CurrentValue = false,
    Callback = function(v)
        bountyEnabled = v
        
        if v then
            updateBountyInfo()
            
            bountyThread = task.spawn(function()
                while bountyEnabled do
                    local success = teleportToEgg(currentBountyEgg)
                    if success then
                        pcall(function()
                            Remote:InvokeServer("HatchEgg", currentBountyEgg, HATCH_AMOUNT)
                        end)
                        hatchedCount = hatchedCount + HATCH_AMOUNT
                        print("[Auto] Hatched " .. HATCH_AMOUNT .. " | Total: " .. hatchedCount)
                    else
                        warn("[Auto] Could not find location for: " .. currentBountyEgg)
                    end
                    
                    task.wait(0.5)
                    updateBountyInfo()
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

AutoTab:CreateSection("📊 Stats")
AutoTab:CreateLabel("Total Hatched: " .. hatchedCount)

print("[Auto] Loaded! Current Bounty: " .. currentBountyPet .. " | " .. currentBountyEgg .. " 🔥")
