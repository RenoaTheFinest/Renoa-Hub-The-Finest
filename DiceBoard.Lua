repeat task.wait() until getgenv().Window
local Window = getgenv().Window

local DiceBoardTab = Window:CreateTab("Dice Board", nil)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Board = require(ReplicatedStorage.Client.Gui.Frames.Board)

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
local GOLDEN_DICE_DIST = 5

local function getNode()
    for name, piece in pairs(Board.Pieces) do
        if name == player.Name then
            local raw = piece.Node.Part
            if typeof(raw) == "number" then
                return raw
            elseif typeof(raw) == "string" then
                return tonumber(raw)
            elseif typeof(raw) == "Instance" then
                return tonumber(raw.Name)
            end
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

local function getBoardHUD()
    local ok, playerGui = pcall(function() return player.PlayerGui end)
    if not ok then return nil end
    local screenGui = playerGui:FindFirstChild("ScreenGui")
    if not screenGui then return nil end
    return screenGui:FindFirstChild("BoardHUD")
end

local function selectDice(diceName)
    local hud = getBoardHUD()
    if not hud then return false end
    local diceFrame = hud.Dice.Inventory:FindFirstChild(diceName)
    if not diceFrame then return false end
    local button = diceFrame:FindFirstChild("Button")
    if not button then return false end
    firesignal(button.Activated)
    return true
end

local function pressRoll()
    local hud = getBoardHUD()
    if not hud then return false end
    local rollButton = hud.Dice.Actions.Roll.Button
    if not rollButton then return false end
    firesignal(rollButton.Activated)
    return true
end

local function waitForNodeChange(oldNode, timeout)
    local elapsed = 0
    while elapsed < timeout do
        task.wait(0.3)
        elapsed = elapsed + 0.3
        local current = getNode()
        if current and current ~= oldNode then
            return current
        end
    end
    return getNode()
end

local function loop()
    while running do
        local node = getNode()

        if not node then
            warn("[DiceBoard] No node found! Make sure the board UI is open.")
            task.wait(2)
            continue
        end

        local target, dist = getClosest(node, TILE_TYPES[targetTile])

        local diceName = "Dice"
        local waitTime = 2.5

        if dist <= GOLDEN_DICE_DIST then
            diceName = "Golden Dice"
            waitTime = 1.5
        elseif dist >= 10 then
            diceName = "Giant Dice"
            waitTime = 4.5
        else
            diceName = "Dice"
            waitTime = 2.5
        end

        print("[DiceBoard] Node: "..node.." | Target: "..tostring(target).." | Dist: "..dist.." | Using: "..diceName)

        local selected = selectDice(diceName)
        if not selected then
            warn("[DiceBoard] Failed to select " .. diceName .. ", falling back to Dice")
            selectDice("Dice")
            diceName = "Dice"
            waitTime = 2.5
        end

        task.wait(0.3)

        local rolled = pressRoll()
        if not rolled then
            warn("[DiceBoard] Failed to press Roll button!")
            task.wait(2)
            continue
        end

        local newNode = waitForNodeChange(node, waitTime + 2)

        print("[DiceBoard] Done! Now on node: " .. tostring(newNode))

        task.wait(1)
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
    end
})

DiceBoardTab:CreateInput({
    Name = "Golden Dice Distance",
    PlaceholderText = "5",
    CurrentValue = tostring(GOLDEN_DICE_DIST),
    RemoveTextAfterFocusLost = false,
    Callback = function(v)
        local n = tonumber(v)
        if n then
            GOLDEN_DICE_DIST = n
        end
    end
})

DiceBoardTab:CreateToggle({
    Name = "Auto Dice Board",
    CurrentValue = false,
    Callback = function(v)
        running = v
        if v then
            if not getBoardHUD() then
                warn("[DiceBoard] Board UI not open! Open the dice board first.")
                running = false
                return
            end
            thread = task.spawn(loop)
        else
            running = false
            if thread then
                task.cancel(thread)
                thread = nil
            end
        end
    end
})

print("[DiceBoard] Loaded!")
