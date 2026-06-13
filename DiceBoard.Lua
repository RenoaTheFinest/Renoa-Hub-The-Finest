-- ================================================
-- DICE BOARD TAB (SMART ROLL - FINAL)
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
local goldenDistance = 2

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

local function smartRoll()
    local node = getNode()
    if not node then
        print("[DiceBoard] Waiting for board position...")
        return
    end
    
    local target, dist = getClosest(node, TILE_TYPES[targetTile])
    if not target then
        -- No target found, just roll normal
        Remote:InvokeServer("RollDice", "Dice")
        print("[DiceBoard] No target, rolling Dice")
        return
    end
    
    local dice
    if dist <= goldenDistance then
        dice = "Golden Dice"
    elseif dist >= 10 then
        dice = "Giant Dice"
    else
        dice = "Dice"
    end
    
    print("[DiceBoard] Node: " .. node .. " | Target: " .. target .. " | Dist: " .. dist .. " | " .. dice)
    Remote:InvokeServer("RollDice", dice)
    
    -- Claim tile after roll
    task.wait(2)
    Remote:FireServer("ClaimTile")
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

DiceBoardTab:CreateInput({
    Name = "Golden Dice Distance",
    CurrentValue = tostring(goldenDistance),
    PlaceholderText = "2",
    RemoveTextAfterFocusLost = false,
    Callback = function(v)
        local n = tonumber(v)
        if n then goldenDistance = n end
    end
})

DiceBoardTab:CreateSection("🎮 Auto Roll")

DiceBoardTab:CreateToggle({
    Name = "Auto Dice Board",
    CurrentValue = false,
    Callback = function(v)
        running = v
        if v then
            thread = task.spawn(function()
                while running do
                    smartRoll()
                    task.wait(2)
                end
            end)
            print("[DiceBoard] Started!")
        else
            if thread then task.cancel(thread) end
            print("[DiceBoard] Stopped!")
        end
    end
})

print("[DiceBoard] Loaded! 🎲")
