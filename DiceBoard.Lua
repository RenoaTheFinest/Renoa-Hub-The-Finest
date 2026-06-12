-- ================================================
-- DICE BOARD (FINAL FINAL FIX)
-- ================================================
repeat task.wait() until getgenv().Window
local Window = getgenv().Window

local DiceBoardTab = Window:CreateTab("Dice Board", nil)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local Remote = require(ReplicatedStorage.Shared.Framework.Network.Remote)
local Board = require(ReplicatedStorage.Client.Gui.Frames.Board)

-- ================================
-- TILE DATA
-- ================================
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

-- ================================
-- STATE
-- ================================
local enabled = false
local selectedTarget = "Golden-Dice"
local thread = nil

-- ================================
-- FIXED NODE GETTER (IMPORTANT)
-- ================================
local function getNode()
    for name, piece in pairs(Board.Pieces) do
        if name == player.Name then
            if piece and piece.Node then
                
                -- INI YANG FIX
                if typeof(piece.Node) == "number" then
                    return piece.Node
                end

                if piece.Node.Node then
                    return piece.Node.Node
                end

                if piece.Node.Value then
                    return piece.Node.Value
                end

                print("[DEBUG] Unknown node format:", piece.Node)
            end
        end
    end

    print("[DEBUG] Node ga kebaca")
    return nil
end

-- ================================
-- LOGIC
-- ================================
local function roll(type)
    print("[DEBUG] Roll:", type)
    pcall(function()
        Remote:InvokeServer("RollDice", type)
    end)
end

local function findTarget(current)
    local tiles = TILE_TYPES[selectedTarget]
    local best = nil
    local bestDist = math.huge

    for _,tile in ipairs(tiles) do
        if tile >= current then
            local dist = tile - current
            if dist < bestDist then
                bestDist = dist
                best = tile
            end
        end
    end

    if not best then
        for _,tile in ipairs(tiles) do
            local dist = (88 - current) + tile
            if dist < bestDist then
                bestDist = dist
                best = tile
            end
        end
    end

    print("[DEBUG] Current:", current, "Target:", best, "Dist:", bestDist)
    return best, bestDist
end

local function chooseDice(dist)
    if dist <= 2 then
        return "Golden Dice"
    elseif dist <= 10 and dist > 6 then
        return "Giant Dice"
    else
        return "Dice"
    end
end

local function loop()
    while enabled do
        task.wait(3)

        local node = getNode()
        if not node then continue end

        local target, dist = findTarget(node)
        if not target then continue end

        local dice = chooseDice(dist)
        roll(dice)
    end
end

-- ================================
-- UI
-- ================================
DiceBoardTab:CreateDropdown({
    Name = "Target Tile",
    Options = {
        "Chance","Dice-Key","Dice","Giant-Dice",
        "Golden-Dice","Infinity-Elixir","Random-Dice",
        "Special-Egg","Super-Ticket","Basic"
    },
    CurrentOption = {"Golden-Dice"},
    Callback = function(v)
        selectedTarget = v[1]
        print("[DiceBoard] Target:", selectedTarget)
    end
})

DiceBoardTab:CreateToggle({
    Name = "Auto Smart Dice",
    CurrentValue = false,
    Callback = function(v)
        enabled = v
        if v then
            thread = task.spawn(loop)
            print("[DiceBoard] STARTED 🔥")
        else
            if thread then task.cancel(thread) end
            print("[DiceBoard] STOPPED")
        end
    end
})
