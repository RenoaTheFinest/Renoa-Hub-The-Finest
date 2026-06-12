-- ================================================
-- SMART DICE BOARD (FULL FINAL)
-- ================================================
repeat task.wait() until getgenv().Window
local Window = getgenv().Window

local DiceBoardTab = Window:CreateTab("Dice Board", nil)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local Remote = require(ReplicatedStorage.Shared.Framework.Network.Remote)

-- ======================================
-- CONFIG
-- ======================================
getgenv().boardSettings = {
    UseGoldenDice = true,
    GoldenDiceDistance = 3,
    DiceDistance = 6,
    GiantDiceDistance = 10,
}

-- ======================================
-- TILE TARGET
-- ======================================
local targetTile = "Chance"

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
-- STATE
-- ======================================
local enabled = false
local thread = nil

-- ======================================
-- GET CURRENT NODE (FIXED)
-- ======================================
local function getNode()
    local ok, Board = pcall(function()
        return require(ReplicatedStorage.Client.Gui.Frames.Board)
    end)

    if not ok or not Board then return nil end

    for name, piece in pairs(Board.Pieces) do
        if name == player.Name then
            if piece and piece.Node then
                local node = piece.Node
                if type(node) == "number" then
                    return node
                elseif type(node) == "table" and node.Index then
                    return node.Index
                end
            end
        end
    end

    return nil
end

-- ======================================
-- GET TARGET + DISTANCE
-- ======================================
local function getTarget(current)
    local tiles = TILE_TYPES[targetTile]
    local closest = nil
    local dist = math.huge

    for _,t in ipairs(tiles) do
        if t >= current then
            local d = t - current
            if d < dist then
                dist = d
                closest = t
            end
        end
    end

    if not closest then
        for _,t in ipairs(tiles) do
            local d = (88 - current) + t
            if d < dist then
                dist = d
                closest = t
            end
        end
    end

    return closest, dist
end

-- ======================================
-- CHOOSE DICE
-- ======================================
local function chooseDice(distance)
    local s = getgenv().boardSettings

    if distance >= s.GiantDiceDistance then
        return "Giant Dice"
    elseif distance >= s.DiceDistance then
        return "Dice"
    elseif s.UseGoldenDice and distance <= s.GoldenDiceDistance then
        return "Golden Dice"
    end

    return "Dice"
end

-- ======================================
-- OPEN BOARD
-- ======================================
local function openBoard()
    pcall(function()
        Remote:InvokeServer("JoinMinigame","Dice")
    end)
end

-- ======================================
-- ROLL
-- ======================================
local function roll(name)
    pcall(function()
        Remote:InvokeServer("RollDice",name)
    end)
end

-- ======================================
-- MAIN LOOP
-- ======================================
local function loop()
    openBoard()
    task.wait(1)

    while enabled do
        local node = getNode()

        if node then
            local target, dist = getTarget(node)
            local dice = chooseDice(dist)

            roll(dice)

            print("[SMART]",
                "Node:",node,
                "| Target:",target,
                "| Dist:",dist,
                "| Dice:",dice
            )
        else
            print("[ERR] Node ga kebaca")
        end

        task.wait(3)
    end
end

-- ======================================
-- UI
-- ======================================
DiceBoardTab:CreateDropdown({
    Name = "Target Tile",
    Options = {
        "Chance","Dice-Key","Dice","Giant-Dice",
        "Golden-Dice","Infinity-Elixir",
        "Special-Egg","Super-Ticket","Basic"
    },
    CurrentOption = {"Chance"},
    Callback = function(v)
        targetTile = v
    end
})

DiceBoardTab:CreateToggle({
    Name = "Auto Dice Board (SMART)",
    CurrentValue = false,
    Callback = function(v)
        enabled = v
        if v then
            thread = task.spawn(loop)
        else
            if thread then task.cancel(thread) end
        end
    end
})
