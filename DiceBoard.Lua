-- ================================================
-- DICE BOARD TAB (AUTO-DETECT GOLDEN DICE)
-- ================================================
repeat task.wait() until getgenv().Window
local Window = getgenv().Window

local DiceBoardTab = Window:CreateTab("Dice Board", nil)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local RemoteFunction = ReplicatedStorage.Shared.Framework.Network.Remote.RemoteFunction
local RemoteEvent = ReplicatedStorage.Shared.Framework.Network.Remote.RemoteEvent

local Board = nil
local myPiece = nil

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
local running = false
local thread = nil
local GOLDEN_DICE_DIST = 2

local function loadBoard()
    local ok, b = pcall(function()
        return require(ReplicatedStorage.Client.Gui.Frames.Board)
    end)
    if not ok or not b then
        warn("[DiceBoard] Failed to load Board module!")
        return false
    end
    Board = b

    for name, piece in pairs(Board.Pieces) do
        if name == player.Name then
            myPiece = piece
            print("[DiceBoard] Found piece! Node: " .. tostring(myPiece.Node.Part))
            return true
        end
    end

    warn("[DiceBoard] Player piece not found!")
    return false
end

local function getNode()
    if not myPiece then return nil end
    local raw = myPiece.Node.Part
    if typeof(raw) == "number" then return raw end
    if typeof(raw) == "string" then return tonumber(raw) end
    if typeof(raw) == "Instance" then return tonumber(raw.Name) end
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

local function waitForNodeChange(oldNode, timeout)
    local elapsed = 0
    while elapsed < timeout do
        task.wait(0.3)
        elapsed = elapsed + 0.3
        local current = getNode()
        if current and current ~= oldNode then
            print("[DiceBoard] Node updated: " .. oldNode .. " -> " .. current)
            return current
        end
    end
    warn("[DiceBoard] Node didn't change after " .. timeout .. "s")
    return getNode()
end

local function loop()
    while running do
        local node = getNode()

        if not node then
            warn("[DiceBoard] No node found, retrying...")
            task.wait(2)
            for name, piece in pairs(Board.Pieces) do
                if name == player.Name then
                    myPiece = piece
                    break
                end
            end
            continue
        end

        local target, dist = getClosest(node, TILE_TYPES[targetTile])

        -- If already on target, just claim and continue
        if dist == 0 then
            print("[DiceBoard] Already on target! Claiming...")
            pcall(function()
                RemoteEvent:FireServer("ClaimTile")
            end)
            task.wait(1.5)
            -- Force refresh and find next target
            for name, piece in pairs(Board.Pieces) do
                if name == player.Name then
                    myPiece = piece
                    break
                end
            end
            continue
        end

        -- Check Golden Dice count
        local hasGolden = false
        local LocalData = require(ReplicatedStorage.Client.Framework.Services.LocalData)
        local localData = LocalData:Get()
        if localData and localData.Powerups then
            local gd = localData.Powerups["Golden Dice"] or 0
            if gd > 0 then hasGolden = true end
        end

        -- Smart dice selection
        local dice = "Dice"
        local waitTime = 2.5

        if hasGolden and dist <= GOLDEN_DICE_DIST then
            dice = "Golden Dice"
            waitTime = 1.5
        elseif dist >= 10 then
            dice = "Giant Dice"
            waitTime = 4.5
        elseif dist >= 6 then
            dice = "Dice"
            waitTime = 2.5
        else
            dice = "Dice"
            waitTime = 2.5
        end

        print("[DiceBoard] Node: "..node.." | Target: "..tostring(target).." | Dist: "..dist.." | Using: "..dice)

        -- Roll
        pcall(function()
            RemoteFunction:InvokeServer("RollDice", dice)
        end)

        -- Force refresh piece after roll
        task.wait(1)
        for name, piece in pairs(Board.Pieces) do
            if name == player.Name then
                myPiece = piece
                break
            end
        end

        -- Wait for node to update
        local newNode = waitForNodeChange(node, waitTime + 2)

        -- Claim tile
        pcall(function()
            RemoteEvent:FireServer("ClaimTile")
        end)

        -- Extra wait after claim
        task.wait(1.5)

        print("[DiceBoard] Done! Now on node: " .. tostring(newNode))
    end
end

-- ======================================
-- UI
-- ======================================
DiceBoardTab:CreateSection("Settings")

DiceBoardTab:CreateDropdown({
    Name = "Target Tile",
    CurrentOption = {"Chance"},
    Options = {
        "Chance","Dice-Key","Dice","Giant-Dice","Golden-Dice",
        "Infinity-Elixir","Special-Egg","Super-Ticket","Basic"
    },
    Callback = function(v)
        targetTile = v[1]
        print("[DiceBoard] Target: " .. targetTile)
    end
})

DiceBoardTab:CreateInput({
    Name = "Golden Dice Distance",
    PlaceholderText = "2",
    CurrentValue = tostring(GOLDEN_DICE_DIST),
    RemoveTextAfterFocusLost = false,
    Callback = function(v)
        local n = tonumber(v)
        if n then
            GOLDEN_DICE_DIST = n
            print("[DiceBoard] Golden Dice distance set to: " .. n)
        end
    end
})

DiceBoardTab:CreateToggle({
    Name = "Auto Dice Board",
    CurrentValue = false,
    Callback = function(v)
        running = v
        if v then
            if not loadBoard() then
                warn("[DiceBoard] Not in dice board! Join the game first.")
                running = false
                return
            end
            thread = task.spawn(loop)
            print("[DiceBoard] Started!")
        else
            running = false
            if thread then
                task.cancel(thread)
                thread = nil
            end
            print("[DiceBoard] Stopped!")
        end
    end
})

print("[DiceBoard] Loaded!")
