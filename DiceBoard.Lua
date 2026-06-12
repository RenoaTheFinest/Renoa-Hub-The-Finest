-- ================================================
-- DICE BOARD (SMART TARGET + DEBUG)
-- ================================================
repeat task.wait() until getgenv().Window
local Window = getgenv().Window

local DiceBoardTab = Window:CreateTab("Dice Board", nil)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Remote = require(ReplicatedStorage.Shared.Framework.Network.Remote)

-- ================================
-- TILE DATA
-- ================================
local TILE_TARGETS = {
    ["Chance"] = {5,13,25,29,32,36,39,40,44,50,53,55,60,61,62,72,76,78,79,83},
    ["Dice-Key"] = {19,21,34,47,80},
    ["Dice"] = {4,12,16,41,42,54,59},
    ["Giant-Dice"] = {69},
    ["Golden-Dice"] = {10,20,26,28,45,49,75,86},
    ["Infinity"] = {17,64},
    ["Special-Egg"] = {27,57,63,71,82},
    ["Super-Ticket"] = {8,11,18,52,65,66}
}

-- ================================
-- STATE
-- ================================
local enabled = false
local selectedTarget = "Golden-Dice"
local thread = nil

-- ================================
-- DEBUG NODE DETECTION
-- ================================
local function getNode()
    -- coba beberapa kemungkinan
    local data = player:FindFirstChild("BoardData")
    if data then
        local node = data:FindFirstChild("Node")
        if node then
            print("[DEBUG] Node via BoardData:", node.Value)
            return node.Value
        end
    end

    -- fallback (kalau sistem beda)
    if player:FindFirstChild("leaderstats") then
        for _,v in pairs(player.leaderstats:GetChildren()) do
            if string.lower(v.Name):find("node") then
                print("[DEBUG] Node via leaderstats:", v.Value)
                return v.Value
            end
        end
    end

    print("[DEBUG] Node NOT FOUND")
    return nil
end

local function roll(type)
    print("[DEBUG] Rolling:", type)
    pcall(function()
        Remote:InvokeServer("RollDice", type)
    end)
end

local function chooseDice(current, target)
    local diff = target - current

    if diff <= 6 then
        return "Dice"
    elseif diff <= 12 then
        return "Giant Dice"
    else
        return "Dice"
    end
end

local function findClosestTarget(current)
    local list = TILE_TARGETS[selectedTarget]
    local best = nil
    local bestDiff = math.huge

    for _,tile in ipairs(list) do
        if tile > current then
            local diff = tile - current
            if diff < bestDiff then
                bestDiff = diff
                best = tile
            end
        end
    end

    print("[DEBUG] Current:", current, "Target:", best)
    return best
end

local function loop()
    while enabled do
        task.wait(2)

        local node = getNode()
        if not node then continue end

        local target = findClosestTarget(node)
        if not target then continue end

        local dice = chooseDice(node, target)
        roll(dice)
    end
end

-- ================================
-- UI
-- ================================
DiceBoardTab:CreateDropdown({
    Name = "Target Tile",
    Options = {"Chance","Dice-Key","Dice","Giant-Dice","Golden-Dice","Infinity","Special-Egg","Super-Ticket"},
    CurrentOption = {"Golden-Dice"},
    Callback = function(v)
        selectedTarget = v[1]
    end
})

DiceBoardTab:CreateToggle({
    Name = "Auto Smart Dice",
    CurrentValue = false,
    Callback = function(v)
        enabled = v
        if v then
            thread = task.spawn(loop)
            print("[DiceBoard] STARTED")
        else
            if thread then task.cancel(thread) end
            print("[DiceBoard] STOPPED")
        end
    end
})
