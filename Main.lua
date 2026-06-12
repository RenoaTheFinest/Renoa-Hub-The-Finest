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

loadTab("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/refs/heads/main/Webhook.Lua")
loadTab("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/refs/heads/main/Eggs.Lua")
loadTab("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/refs/heads/main/Rift.Lua")
loadTab("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/refs/heads/main/Enchant.Lua")
loadTab("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/refs/heads/main/Shrine.Lua")
loadTab("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/refs/heads/main/Pets.Lua")
loadTab("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/refs/heads/main/DiceBoard.Lua")
loadTab("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/refs/heads/main/Other.Lua")
