-- ================================================
-- LOAD RAYFIELD
-- ================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ================================================
-- SETTINGS SYSTEM
-- ================================================
local HttpService = game:GetService("HttpService")

local function saveSettings(settings)
    pcall(function()
        writefile("RenoaHub_Settings.json", HttpService:JSONEncode(settings))
    end)
end

local function loadSettings()
    local ok, data = pcall(function()
        if isfile("RenoaHub_Settings.json") then
            return HttpService:JSONDecode(readfile("RenoaHub_Settings.json"))
        end
        return {}
    end)
    if ok and data then return data end
    return {}
end

local Settings = loadSettings()

function getSetting(key, default)
    if Settings[key] ~= nil then return Settings[key] end
    return default
end

function setSetting(key, value)
    Settings[key] = value
    saveSettings(Settings)
end

-- ================================================
-- WINDOW
-- ================================================
local Window = Rayfield:CreateWindow({
    Name = "Renoa Hub",
    LoadingTitle = "Loading Renoa Hub...",
    LoadingSubtitle = "by Scythme",
})

-- ================================================
-- LOAD TABS (ORDER FIXED)
-- ================================================
local function loadTab(url)
    pcall(function()
        loadstring(game:HttpGet(url))()
    end)
end

-- urutan tab lu
loadTab("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/refs/heads/main/Eggs.Lua")
loadTab("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/refs/heads/main/Effect.Lua")
loadTab("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/refs/heads/main/Rift.Lua")
loadTab("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/refs/heads/main/Shrine.Lua")
loadTab("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/refs/heads/main/Pets.Lua")
loadTab("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/refs/heads/main/Enchant.Lua")
loadTab("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/refs/heads/main/Webhook.Lua")

print("[Renoa Hub] Loaded!")load("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/refs/heads/main/Enchant.Lua")
load("https://raw.githubusercontent.com/RenoaTheFinest/Renoa-Hub-The-Finest/refs/heads/main/Webhook.Lua")

print("Renoa Is Coming😈")
