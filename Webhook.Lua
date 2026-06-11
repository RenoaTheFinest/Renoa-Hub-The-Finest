-- ================================================
-- WEBHOOK TAB (RAYFIELD - FOOLPROOF)
-- ================================================
repeat task.wait() until getgenv().Window
local Window = getgenv().Window

local WebhookTab = Window:CreateTab("Webhook", nil)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- CONFIG
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

-- ======================================
-- FORMAT
-- ======================================
local function formatNum(n)
    if not n then return "0" end
    if n>=1e9 then return string.format("%.1fB",n/1e9)
    elseif n>=1e6 then return string.format("%.1fM",n/1e6)
    elseif n>=1e3 then return string.format("%.1fK",n/1e3)
    else return tostring(math.floor(n)) end
end

local function formatExist(n)
    if not n then return "0" end
    local s=tostring(math.floor(n))
    return s:reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","")
end

-- ======================================
-- STATS
-- ======================================
local function getStats(eggName)
    if not LocalData then return "0","0","0" end
    local ok,data = pcall(function() return LocalData:Get() end)
    if not ok or not data then return "0","0","0" end

    return
        formatNum(data.Coins or 0),
        formatNum(data.Gems or 0),
        formatNum((data.EggsOpened and data.EggsOpened[eggName]) or 0)
end

-- ======================================
-- PET EXTRA
-- ======================================
local function getPetExtra(petInfo)
    local odds="Unknown"
    local exist="Unknown"

    if petInfo.Chance then
        local calc=math.floor(1/petInfo.Chance)
        if calc>0 then odds="1/"..formatExist(calc) end
    elseif petInfo.Odds then
        odds="1/"..formatExist(petInfo.Odds)
    end

    if petInfo.Exists then
        exist=formatExist(petInfo.Exists)
    end

    return odds,exist
end

-- ======================================
-- VARIANT
-- ======================================
local function getVariant(ex)
    if ex.Shiny and ex.Mythic then return "ShinyMythic"
    elseif ex.Shiny then return "Shiny"
    elseif ex.Mythic then return "Mythic"
    else return "Normal" end
end

local function getVariantText(v)
    if v=="ShinyMythic" then return "Shiny Mythic"
    elseif v=="Shiny" then return "Shiny"
    elseif v=="Mythic" then return "Mythic"
    else return "Normal" end
end

-- ======================================
-- IMAGE
-- ======================================
local function getImage(petInfo)
    local raw = petInfo.Image or petInfo.ImageId
    if not raw then return nil end

    local id = tostring(raw):gsub("rbxassetid://",""):match("%d+")
    if not id then return nil end

    return "https://www.roblox.com/asset-thumbnail/image?assetId="..id.."&width=420&height=420&format=png"
end

-- ======================================
-- QUEUE (ANTI RATELIMIT)
-- ======================================
local queue={}
local processing=false

local function process()
    if processing then return end
    processing=true

    task.spawn(function()
        while #queue>0 do
            local p=table.remove(queue,1)
            pcall(function()
                request({
                    Url=_G.WEBHOOK_URL,
                    Method="POST",
                    Headers={["Content-Type"]="application/json"},
                    Body=HttpService:JSONEncode(p)
                })
            end)
            task.wait(1)
        end
        processing=false
    end)
end

-- ======================================
-- SEND
-- ======================================
local function send(petName, eggName, ex)
    if not _G.webhookEnabled then return end
    if _G.WEBHOOK_URL=="" then return end
    if not Pets then return end

    local info = Pets[petName]
    if not info then return end

    local rarity = info.Rarity
    if not TRACKED[rarity] then return end

    local variant = getVariant(ex)
    local variantText = getVariantText(variant)

    local coins,gems,opened = getStats(eggName)
    local odds,exist = getPetExtra(info)
    local img = getImage(info)

    local embed = {
        title = "🎉 Congrats You Hatched A "..variantText.." "..rarity.." "..petName.."!",
        color = 16711680,

        fields = {
            {
                name = "• User Info",
                value =
                    "👤 Name : "..player.Name.."\n"..
                    "🪙 Coin : "..coins.."\n"..
                    "💎 Gems : "..gems.."\n"..
                    "🥚 Egg Hatched : "..opened,
                inline = false
            },
            {
                name = "🐾 Pet Info",
                value =
                    "Odds : "..odds.."\n"..
                    "Exist : "..exist,
                inline = false
            }
        },

        footer = {
            text = "Renoa The Finest has Blessed You! • "..os.date("%Y-%m-%d %H:%M:%S")
        }
    }

    if img then
        embed.thumbnail = {url = img}
    end

    table.insert(queue, {
        content = (_G.DISCORD_USER_ID~="") and "<@".._G.DISCORD_USER_ID..">" or nil,
        embeds = {embed}
    })

    process()
end

-- ======================================
-- HOOK
-- ======================================
local function hook()
    if webhookHooked then return end

    local ok,mod = pcall(function()
        return require(ReplicatedStorage.Client.Effects.HatchEgg)
    end)

    if ok and mod then
        hookfunction(mod.Play, newcclosure(function(_, data)
            if type(data)=="table" and data.Pets then
                for _, p in ipairs(data.Pets) do
                    local pet = p.Pet or p
                    if pet and pet.Name then
                        task.spawn(function()
                            send(
                                pet.Name,
                                data.Name or "Egg",
                                {Shiny=pet.Shiny, Mythic=pet.Mythic}
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

-- ================================================
-- UI (FOOLPROOF - no Enter needed)
-- ================================================
local urlInput
local idInput

WebhookTab:CreateSection("Webhook Settings")

urlInput = WebhookTab:CreateInput({
    Name = "Webhook URL",
    CurrentValue = "",
    PlaceholderText = "https://discord.com/api/webhooks/...",
    RemoveTextAfterFocusLost = false,
    Callback = function(v)
        _G.WEBHOOK_URL = v
    end
})

idInput = WebhookTab:CreateInput({
    Name = "Discord ID",
    CurrentValue = "",
    PlaceholderText = "735361388515688490",
    RemoveTextAfterFocusLost = false,
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

-- 🔄 Override send to read directly from input fields (no Enter needed)
local oldSend = send
send = function(petName, egg, ex)
    if urlInput and urlInput.Text then
        _G.WEBHOOK_URL = urlInput.Text
    end
    if idInput and idInput.Text then
        _G.DISCORD_USER_ID = idInput.Text
    end
    return oldSend(petName, egg, ex)
end

print("Webhook udah bener, kalo masih jelek berarti lu nya 😭")
