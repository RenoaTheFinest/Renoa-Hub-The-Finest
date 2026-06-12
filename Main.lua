-- ======================================
-- RENOA HUB | THE FINEST HUB
-- ======================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Renoa Hub | The Finest Hub",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "By Renoa The Finest"
})

getgenv().Window = Window

local function loadTab(url)
    local success, err = pcall(function()
        loadstring(game:HttpGet(url))()
    end)
    if not success then
        warn("FAILED:", url)
        warn(err)
    end
end

loadTab("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/main/Webhook.Lua")
loadTab("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/main/Eggs.Lua")
loadTab("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/main/Rift.Lua")
loadTab("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/main/Enchant.Lua")
loadTab("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/main/Shrine.Lua")
loadTab("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/main/Pets.Lua")
loadTab("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/main/DiceBoard.Lua")
loadTab("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/main/Other.Lua")
