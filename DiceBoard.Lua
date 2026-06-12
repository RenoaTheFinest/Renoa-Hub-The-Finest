-- ================================================
-- DICE BOARD TAB (FINAL FIX NO TP + LOOP FIX)
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
-- TILE MAPPING
-- ======================================
local TILE_TYPES = {
    ["Chance"] = {5,13,25,29,32,36,39,40,44,50,53,55,60,61,62,72,76,78,79,83},
    ["Dice-Key"] = {19,21,34,47,80},
    ["Dice"] = {4,12,16,41,42,54,59},
    ["Giant-Dice"] = {69},
    ["Golden-Dice"] = {10,20,26,28,45,49,75,86},
    ["Infinity-Elixir"] = {17,64},
    ["Random-Dice"] = {3,33,38,46,88},
    ["Special-Egg"] = {27,57,63,71,82},
    ["Super-Ticket"] = {8,11,18,52,65,66},
    ["Basic"] = {1,6,7,9,14,15,22,23,24,30,31,35,37,48,51,56,58,67,68,70,73,74,81,84,85,87},
}

-- ======================================
-- SETTINGS
-- ======================================
local boardEnabled = false
local targetTile = "Chance"

-- ======================================
-- GET NODE FIX
-- ======================================
local function getNode()
    for name, piece in pairs(Board.Pieces) do
        if name == player.Name then
            local node = piece.Node
            if type(node) == "table" then
                if node.Index then return node.Index end
                if node.Id then return node.Id end
                if node.Number then return node.Number end
            end
        end
    end
    return nil
end

-- ======================================
-- TARGET
-- ======================================
local function getTarget(current, targetType)
    local tiles = TILE_TYPES[targetType]
    if not tiles then return nil,999 end

    local best = nil
    local dist = 999

    for _,t in ipairs(tiles) do
        if t >= current then
            local d = t - current
            if d < dist then
                dist = d
                best = t
            end
        end
    end

    if not best then
        for _,t in ipairs(tiles) do
            local d = (88 - current) + t
            if d < dist then
                dist = d
                best = t
            end
        end
    end

    return best, dist
end

-- ======================================
-- ROLL FIX (IMPORTANT)
-- ======================================
local function roll(d)
    pcall(function()
        Remote:InvokeServer("RollDice", d)
    end)
end

local function smartRoll()
    local node = getNode()

    if not node then
        print("[DiceBoard] node null → spam dice")
        roll("Dice")
        return
    end

    local target, dist = getTarget(node, targetTile)

    if not target then
        roll("Dice")
        return
    end

    -- FIX LOGIC BIAR GA KEKUNCI DI DICE BIASA
    if dist <= 2 then
        roll("Golden Dice")
        print("🔥 GOLDEN | dist:", dist)

    elseif dist <= 10 then
        roll("Giant Dice")
        print("💀 GIANT | dist:", dist)

    else
        roll("Dice")
        print("🙂 NORMAL | dist:", dist)
    end
end

-- ======================================
-- UI
-- ======================================
DiceBoardTab:CreateDropdown({
    Name = "Target Tile",
    CurrentOption = {"Chance"},
    Options = {
        "Chance","Dice-Key","Dice","Giant-Dice","Golden-Dice",
        "Infinity-Elixir","Random-Dice","Special-Egg","Super-Ticket","Basic"
    },
    Callback = function(v)
        targetTile = v
    end
})

DiceBoardTab:CreateToggle({
    Name = "Auto Roll Dice (FIXED)",
    CurrentValue = false,
    Callback = function(v)
        boardEnabled = v

        if v then
            task.spawn(function()
                while boardEnabled do
                    smartRoll()
                    task.wait(2) -- jangan 3, biar ga ke skip server tick
                end
            end)
        end
    end
})

print("[DiceBoard] FINAL FIX READY 🔥")
