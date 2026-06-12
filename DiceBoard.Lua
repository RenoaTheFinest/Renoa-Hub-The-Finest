-- ================================================
-- DICE BOARD TAB (SIMPLIFIED)
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
    ["Chance"] = {5, 13, 25, 29, 32, 36, 39, 40, 44, 50, 53, 55, 60, 61, 62, 72, 76, 78, 79, 83},
    ["Dice-Key"] = {19, 21, 34, 47, 80},
    ["Dice"] = {4, 12, 16, 41, 42, 54, 59},
    ["Giant-Dice"] = {69},
    ["Golden-Dice"] = {10, 20, 26, 28, 45, 49, 75, 86},
    ["Infinity-Elixir"] = {17, 64},
    ["Random-Dice"] = {3, 33, 38, 46, 88},
    ["Special-Egg"] = {27, 57, 63, 71, 82},
    ["Super-Ticket"] = {8, 11, 18, 52, 65, 66},
    ["Basic"] = {1, 6, 7, 9, 14, 15, 22, 23, 24, 30, 31, 35, 37, 48, 51, 56, 58, 67, 68, 70, 73, 74, 81, 84, 85, 87},
}

-- ======================================
-- SETTINGS
-- ======================================
local boardEnabled = false
local boardThread = nil
local targetTile = "Chance"
local goldenDistance = 2

-- ======================================
-- FUNCTIONS
-- ======================================
local function getMyNode()
    for playerName, piece in pairs(Board.Pieces) do
        if playerName == player.Name then
            if piece and piece.Node then
                return piece.Node.Part
            end
        end
    end
    return nil
end

local function getClosestTarget(currentNode, targetType)
    local tiles = TILE_TYPES[targetType] or {}
    local closest = nil
    local closestDist = 999
    
    for _, tileNum in ipairs(tiles) do
        if tileNum >= currentNode then
            local dist = tileNum - currentNode
            if dist < closestDist then
                closestDist = dist
                closest = tileNum
            end
        end
    end
    
    if not closest then
        for _, tileNum in ipairs(tiles) do
            local dist = (88 - currentNode) + tileNum
            if dist < closestDist then
                closestDist = dist
                closest = tileNum
            end
        end
    end
    
    return closest, closestDist
end

local function rollDice(diceName)
    pcall(function()
        Remote:InvokeServer("RollDice", diceName)
    end)
end

local function smartRoll()
    local myNode = getMyNode()
    
    if myNode then
        local target, distance = getClosestTarget(myNode, targetTile)
        
        if target and distance <= goldenDistance then
            rollDice("Golden Dice")
            print("[DiceBoard] 🎯 Target " .. distance .. " tiles → Golden Dice!")
            return
        elseif target and distance <= 6 then
            rollDice("Dice")
            print("[DiceBoard] 🎯 Target " .. distance .. " tiles → Dice")
            return
        elseif target and distance <= 10 then
            rollDice("Giant Dice")
            print("[DiceBoard] 🎯 Target " .. distance .. " tiles → Giant Dice!")
            return
        end
    end
    
    rollDice("Dice")
    print("[DiceBoard] Rolling Dice")
end

-- ======================================
-- UI
-- ======================================
DiceBoardTab:CreateSection("🎯 Target Settings")

DiceBoardTab:CreateDropdown({
    Name = "Target Tile",
    CurrentOption = {"Chance"},
    Options = {
        "Chance",
        "Dice-Key",
        "Dice",
        "Giant-Dice",
        "Golden-Dice",
        "Infinity-Elixir",
        "Random-Dice",
        "Special-Egg",
        "Super-Ticket",
        "Basic"
    },
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
        boardEnabled = v
        if v then
            boardThread = task.spawn(function()
                while boardEnabled do
                    smartRoll()
                    task.wait(3)
                end
            end)
            print("[DiceBoard] Started!")
        else
            if boardThread then task.cancel(boardThread) end
            print("[DiceBoard] Stopped!")
        end
    end
})

print("[DiceBoard] Loaded! 🎲")
