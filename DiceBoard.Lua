-- ================================================
-- DICE BOARD TAB (FINAL FIXED - SMART AUTO ROLL)
-- ================================================
repeat task.wait() until getgenv().Window
local Window = getgenv().Window

local DiceBoardTab = Window:CreateTab("Dice Board", nil)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local Remote = require(ReplicatedStorage.Shared.Framework.Network.Remote)

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

local settings = {
    UseGoldenDice = true,
    GoldenDiceDistance = 2,
    DiceDistance = 6,
    GiantDiceDistance = 10,
}

-- ======================================
-- GET NODE (FIX FINAL)
-- ======================================
local function getMyNode()
    local success, node = pcall(function()
        return require(game:GetService("ReplicatedStorage")
            .Client.Gui.Frames.Board).GetCurrentNode()
    end)

    if success and node then
        if type(node) == "number" then
            return node
        elseif type(node) == "table" then
            if node.Id then return node.Id end
            if node.Index then return node.Index end
            if node.Node then return node.Node end

            -- DEBUG kalau masih goblok formatnya
            print("[DEBUG NODE RAW]:", HttpService:JSONEncode(node))
        end
    end

    print("[DEBUG] Node ga kebaca")
    return nil
end

-- ======================================
-- TARGET CALC
-- ======================================
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

-- ======================================
-- ROLL
-- ======================================
local function rollDice(diceName)
    pcall(function()
        Remote:InvokeServer("RollDice", diceName)
    end)
    print("[ROLL]:", diceName)
end

-- ======================================
-- SMART LOGIC
-- ======================================
local function smartRoll()
    local myNode = getMyNode()

    if not myNode then
        rollDice("Dice")
        return
    end
    
    local target, distance = getClosestTarget(myNode, targetTile)

    if not target then
        rollDice("Dice")
        return
    end

    print("[INFO] Node:", myNode, "Target:", target, "Dist:", distance)

    if settings.UseGoldenDice and distance <= settings.GoldenDiceDistance then
        rollDice("Golden Dice")
    elseif distance <= settings.GiantDiceDistance and distance > settings.DiceDistance then
        rollDice("Giant Dice")
    else
        rollDice("Dice")
    end
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
        "Random-Dice",
        "Special-Egg",
        "Super-Ticket",
        "Basic"
    },
    Callback = function(v)
        targetTile = v
        print("Target:", v)
    end
})

DiceBoardTab:CreateButton({
    Name = "Teleport Board",
    Callback = function()
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(9912, 29, 172)
        end
    end
})

DiceBoardTab:CreateToggle({
    Name = "Auto Smart Roll",
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
        else
            if boardThread then task.cancel(boardThread) end
        end
    end
})

print("Dice Board Loaded 🔥")
