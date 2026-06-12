-- ================================================
-- DICE BOARD TAB (FIXED - ROLL + CLAIM)
-- ================================================
repeat task.wait() until getgenv().Window
local Window = getgenv().Window

local DiceBoardTab = Window:CreateTab("Dice Board", nil)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local Remote = require(ReplicatedStorage.Shared.Framework.Network.Remote)
local Board = require(ReplicatedStorage.Client.Gui.Frames.Board)

-- ======================================
-- TILE MAPPINGS
-- ======================================
local TILE_TYPES = {
    ["Chance"] = {5,13,25,29,32,36,39,40,44,50,53,55,60,61,62,72,76,78,79,83},
    ["Dice-Key"] = {19,21,34,47,80},
    ["Dice"] = {4,12,16,41,42,54,59},
    ["Giant-Dice"] = {69},
    ["Golden-Dice"] = {10,20,26,28,45,49,75,86},
    ["Infinity-Elixir"] = {17,64},
    ["Special-Egg"] = {27,57,63,71,82},
    ["Super-Ticket"] = {8,11,18,52,65,66},
    ["Basic"] = {1,6,7,9,14,15,22,23,24,30,31,35,37,48,51,56,58,67,68,70,73,74,81,84,85,87},
}

-- ======================================
-- SETTINGS
-- ======================================
local targetTile = "Chance"
local running = false
local thread = nil
local USE_GOLDEN_DICE = true
local GOLDEN_DICE_DIST = 2

-- ======================================
-- FUNCTIONS
-- ======================================
local function getNode()
    for name, piece in pairs(Board.Pieces) do
        if name == player.Name and piece and piece.Node then
            return piece.Node.Part
        end
    end
    return nil
end

local function getClosest(current, list)
    local closest = nil
    local dist = math.huge
    for _, num in ipairs(list) do
        local d = (num >= current) and (num - current) or (88 - current + num)
        if d < dist then
            dist = d
            closest = num
        end
    end
    return closest, dist
end

local function rollDice(diceName)
    pcall(function()
        Remote:InvokeServer("RollDice", diceName)
    end)
end

local function claimTile()
    pcall(function()
        Remote:FireServer("ClaimTile")
    end)
end

local function loop()
    while running do
        local node = getNode()
        
        if node then
            local target, dist = getClosest(node, TILE_TYPES[targetTile])
            
            local dice = "Dice"
            if USE_GOLDEN_DICE and dist <= GOLDEN_DICE_DIST then
                dice = "Golden Dice"
            elseif dist >= 10 then
                dice = "Giant Dice"
            end
            
            print("[DiceBoard] Node: "..node.." | Dist: "..dist.." | "..dice)
            rollDice(dice)
            
            -- Wait for roll animation
            task.wait(2)
            
            -- Claim whatever tile we landed on
            claimTile()
            print("[DiceBoard] Claimed tile!")
        else
            print("[DiceBoard] Waiting for board...")
        end
        
        task.wait(2)
    end
end

-- ======================================
-- UI
-- ======================================
DiceBoardTab:CreateSection("🎯 Settings")

DiceBoardTab:CreateDropdown({
    Name = "Target Tile",
    CurrentOption = {"Chance"},
    Options = {"Chance","Dice-Key","Dice","Giant-Dice","Golden-Dice","Infinity-Elixir","Special-Egg","Super-Ticket","Basic"},
    Callback = function(v)
        targetTile = v
    end
})

DiceBoardTab:CreateToggle({
    Name = "Use Golden Dice",
    CurrentValue = USE_GOLDEN_DICE,
    Callback = function(v)
        USE_GOLDEN_DICE = v
    end
})

DiceBoardTab:CreateToggle({
    Name = "Auto Dice Board",
    CurrentValue = false,
    Callback = function(v)
        running = v
        if v then
            thread = task.spawn(loop)
            print("[DiceBoard] Started!")
        else
            if thread then task.cancel(thread) end
            print("[DiceBoard] Stopped!")
        end
    end
})

print("[DiceBoard] Loaded! 🎲")
