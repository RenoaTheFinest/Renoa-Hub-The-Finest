-- ================================================
-- DICE BOARD TAB (REAL FINAL FIX)
-- ================================================
repeat task.wait() until getgenv().Window
local Window = getgenv().Window

local DiceBoardTab = Window:CreateTab("Dice Board", nil)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local RemoteFunction = ReplicatedStorage.Shared.Framework.Network.Remote.RemoteFunction
local RemoteEvent = ReplicatedStorage.Shared.Framework.Network.Remote.RemoteEvent

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
-- FORCE OPEN UI
-- ======================================
local function openBoard()
local gui = player:WaitForChild("PlayerGui")

for _,v in pairs(gui:GetDescendants()) do  
    if v.Name == "BoardHUD" or v.Name == "Minigame" then  
        pcall(function()  
            v.Enabled = true  
            v.Visible = true  
        end)  
    end  
end  

print("[DiceBoard] UI kebuka")

end

-- ======================================
-- WAIT BOARD READY (INI KUNCI)
-- ======================================
local function waitBoard()
local Board = require(ReplicatedStorage.Client.Gui.Frames.Board)

local timeout = 0  
repeat  
    for name, piece in pairs(Board.Pieces) do  
        if name == player.Name and piece.Node then  
            print("[DiceBoard] Board ready")  
            return true  
        end  
    end  

    task.wait(0.5)  
    timeout += 0.5  
until timeout > 10  

warn("[DiceBoard] Board gagal kebaca")  
return false

end

-- ======================================
-- GET NODE
-- ======================================
local function getNode()
local Board = require(ReplicatedStorage.Client.Gui.Frames.Board)

for name, piece in pairs(Board.Pieces) do  
    if name == player.Name then  
        if piece.Node and piece.Node.Part then  
            return tonumber(piece.Node.Part)  
        end  
    end  
end  

return nil

end

-- ======================================
-- TARGET
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
-- REMOTES
-- ======================================
local function roll(dice)
RemoteFunction:InvokeServer("RollDice", dice)
end

local function claim()
RemoteEvent:FireServer("ClaimTile")
end

-- ======================================
-- SMART LOOP
-- ======================================
local function loop()
while running do
local node = getNode()

if not node then  
        warn("node belum kebaca")  
        task.wait(1)  
        continue  
    end  

    local target, dist = getClosest(node, TILE_TYPES[targetTile])  

    local dice = "Dice"  

    if getgenv().boardSettings.UseGoldenDice and dist <= getgenv().boardSettings.GoldenDiceDistance then  
        dice = "Golden Dice"  
    elseif dist >= getgenv().boardSettings.GiantDiceDistance then  
        dice = "Giant Dice"  
    end  

    print("NODE:", node, "TARGET:", target, "DIST:", dist, "DICE:", dice)  

    roll(dice)  

    task.wait(2.5)  
    claim()  

    task.wait(2)  
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
"Infinity-Elixir","Special-Egg","Super-Ticket","Basic"
},
Callback = function(v)
targetTile = v[1]
print("Target:", targetTile)
end
})

DiceBoardTab:CreateToggle({
Name = "Auto Dice Board",
CurrentValue = false,
Callback = function(v)
running = v

if v then  
        openBoard()  

        task.wait(1)  

        if not waitBoard() then  
            warn("board ga ready")  
            return  
        end  

        thread = task.spawn(loop)  

        print("STARTED 😈")  
    else  
        if thread then task.cancel(thread) end  
        print("STOPPED")  
    end  
end

})

print("Dice Board Ready To Use! Make sure to teleport first to minigame paradise world before turn it on!")
