-- =========================
-- LOAD RAYFIELD 
-- =========================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Renoa Hub | The Finest Hub",
    LoadingTitle = "Loading Renoa Hub...",
    LoadingSubtitle = "by Scythme",
})

-- kasih ke global biar file lain bisa pake
_G.Rayfield = Rayfield
_G.Window = Window

-- =========================
-- LOADER FUNCTION
-- =========================
local function load(url)
    local s, r = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not s then
        warn("Failed load:", url, r)
    end
end

-- =========================
-- LOAD MODULE (URUTAN TAB)
-- =========================

load("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/refs/heads/main/Eggs.Lua")
load("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/refs/heads/main/Effect.Lua")
load("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/refs/heads/main/Rift.Lua")
load("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/refs/heads/main/Shrine.Lua")
load("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/refs/heads/main/Pets.Lua")
load("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/refs/heads/main/Enchant.Lua")
load("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/refs/heads/main/Webhook.Lua")

print("Renoa Is Coming😈")
