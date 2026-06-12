-- ================================================
-- DICE BOARD TAB (FINAL FIX + AUTO UI)
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
    GoldenDiceDistance = 2,
    DiceDistance = 6,
    GiantDiceDistance = 10,
}

-- ======================================
-- TILE TARGET
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

local targetTile = "Chance"

-- ======================================
-- STATE
-- ======================================
local running = false
local thread = nil

-- ======================================
-- FORCE OPEN BOARD UI
-- ======================================
local function openBoard()
    local gui = player:WaitForChild("PlayerGui")
    local screen = gui:FindFirstChild("ScreenGui")

    if not screen then return end

    local board = screen:FindFirstChild("BoardHUD")
    if board then
        board.Enabled = true
    end

    local mini = screen:FindFirstChild("Minigame")
    if mini then
        mini.Enabled = true
    end

    print("[DiceBoard] UI forced open")
end

-- ======================================
-- GET NODE
-- ======================================
local function getNode()
    local Board = require(ReplicatedStorage.Client.Gui.Frames.Board)

    for name, piece in pairs(Board.Pieces) do
        if name == player.Name then
            if piece.Node and piece.Node.Part then
                return piece.Node.Part
            end
        end
    end

    return nil
end

-- ======================================
-- GET TARGET
-- ======================================
local function getClosest(current, list)
    local closest = nil
    local dist = math.huge

    for _,num in ipairs(list) do
        local d = (num >= current) and (num - current) or (88 - current + num)
        if d < dist then
            dist = d
            closest = num
        end
    end

    return closest, dist
end

-- ======================================
-- ROLL
-- ======================================
local function roll(dice)
    pcall(function()
        Remote:InvokeServer("RollDice", dice)
    end)
end

-- ======================================
-- SMART LOGIC
-- ======================================
local function smartRoll()
    local node = getNode()
    if not node then
        warn("[DiceBoard] node ga kebaca")
        return
    end

    local list = TILE_TYPES[targetTile]
    if not list then return end

    local target, dist = getClosest(node, list)

    local diceToUse = "Dice"

    if getgenv().boardSettings.UseGoldenDice and dist <= getgenv().boardSettings.GoldenDiceDistance then
        diceToUse = "Golden Dice"

    elseif dist >= getgenv().boardSettings.GiantDiceDistance then
        diceToUse = "Giant Dice"

    elseif dist >= getgenv().boardSettings.DiceDistance then
        diceToUse = "Dice"

    else
        diceToUse = "Dice"
    end

    print("[SMART]", "Node:", node, "Target:", target, "Dist:", dist, "Dice:", diceToUse)

    roll(diceToUse)
end

-- ======================================
-- UI
-- ======================================
DiceBoardTab:CreateSection("Target")

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
        "Special-Egg",
        "Super-Ticket",
        "Basic"
    },
    Callback = function(v)
        targetTile = v[1] -- FIX
        print("Target set:", targetTile)
    end
})

DiceBoardTab:CreateSection("Auto")

DiceBoardTab:CreateToggle({
    Name = "Auto Dice Board",
    CurrentValue = false,
    Callback = function(v)
        running = v

        if v then
            openBoard() -- 🔥 penting
            task.wait(1)

            thread = task.spawn(function()
                while running do
                    smartRoll()
                    task.wait(3)
                end
            end)

            print("STARTED")
        else
            if thread then task.cancel(thread) end
            print("STOPPED")
        end
    end
})

print("DICE BOARD FINAL LOADED 😈")
