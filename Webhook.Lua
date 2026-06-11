-- ================================================
-- WEBHOOK TAB (SAFE FIX)
-- ================================================
repeat task.wait() until getgenv().Window
local Window = getgenv().Window

local WebhookTab = Window:CreateTab("Webhook", nil)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- CONFIG (isi manual di UI)
_G.WEBHOOK_URL = ""
_G.DISCORD_USER_ID = ""
_G.webhookEnabled = false

local webhookHooked = false

local request = http_request or request or (syn and syn.request)
if not request then
    warn("executor lu ga support webhook 💀")
    return
end

local Pets, LocalData
pcall(function() Pets = require(ReplicatedStorage.Shared.Data.Pets) end)
pcall(function() LocalData = require(ReplicatedStorage.Client.Framework.Services.LocalData) end)

local TRACKED = {
    ["Secret"]=true,
    ["Celestial"]=true,
    ["Infinity"]=true,
    ["Void"]=true,
    ["Super Legendary"]=true,
}

local function formatNum(n)
    if not n then return "0" end
    if n>=1e9 then return string.format("%.1fB",n/1e9)
    elseif n>=1e6 then return string.format("%.1fM",n/1e6)
    elseif n>=1e3 then return string.format("%.1fK",n/1e3)
    else return tostring(math.floor(n)) end
end

local function getStats(egg)
    if not LocalData then return "0","0","0" end
    local ok,data = pcall(function() return LocalData:Get() end)
    if not ok or not data then return "0","0","0" end

    return
        formatNum(data.Coins or 0),
        formatNum(data.Gems or 0),
        formatNum((data.EggsOpened and data.EggsOpened[egg]) or 0)
end

local function getImg(name,ex)
    local n = name:lower():gsub("%s+","-")
    local p = ""
    if ex.Shiny and ex.Mythic then p="shiny-mythic-"
    elseif ex.Shiny then p="shiny-"
    elseif ex.Mythic then p="mythic-" end
    return "https://cdn.bgsi.gg/items/"..p..n..".png"
end

local function send(petName,egg,ex)
    if not _G.webhookEnabled then return end
    if _G.WEBHOOK_URL=="" then return end
    if not Pets then return end

    local info = Pets[petName]
    if not info then return end

    local rarity = info.Rarity
    if not TRACKED[rarity] then return end

    local coins,gems,eggs = getStats(egg)

    local embed = {
        title = petName.." ("..rarity..")",
        description =
            "User: "..player.Name.."\n"..
            "Coins: "..coins.." | Gems: "..gems.."\n"..
            "Eggs: "..eggs,
        color = 16711680,
        thumbnail = {url = getImg(petName,ex)},
        footer = {text=os.date("%H:%M:%S")}
    }

    pcall(function()
        request({
            Url = _G.WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"]="application/json"},
            Body = HttpService:JSONEncode({
                content = (_G.DISCORD_USER_ID~="") and "<@".._G.DISCORD_USER_ID..">" or nil,
                embeds = {embed}
            })
        })
    end)
end

local function hook()
    if webhookHooked then return end

    local ok,mod = pcall(function()
        return require(ReplicatedStorage.Client.Effects.HatchEgg)
    end)

    if ok and mod then
        hookfunction(mod.Play,newcclosure(function(_,data)
            if type(data)=="table" and data.Pets then
                for _,p in ipairs(data.Pets) do
                    local pet = p.Pet
                    if pet and pet.Name then
                        task.spawn(function()
                            send(
                                pet.Name,
                                data.Name or "Egg",
                                {Shiny=pet.Shiny,Mythic=pet.Mythic}
                            )
                        end)
                    end
                end
            end
            return
        end))
        webhookHooked = true
        print("[Webhook] hooked 🔥")
    end
end

-- UI
WebhookTab:CreateSection("Webhook")

WebhookTab:CreateInput({
    Name = "Webhook URL",
    CurrentValue = "",
    Callback = function(v)
        _G.WEBHOOK_URL = v
    end
})

WebhookTab:CreateInput({
    Name = "Discord ID",
    CurrentValue = "",
    Callback = function(v)
        _G.DISCORD_USER_ID = v
    end
})

WebhookTab:CreateToggle({
    Name = "Enable Webhook",
    CurrentValue = false,
    Callback = function(v)
        _G.webhookEnabled = v
        if v then hook() end
    end
})
