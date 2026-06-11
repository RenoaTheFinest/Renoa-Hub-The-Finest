-- ================================================
-- WEBHOOK TAB (HYBRID FIX - Working Reference Logic)
-- ================================================
repeat task.wait() until getgenv().Window
local Window = getgenv().Window

local WebhookTab = Window:CreateTab("Webhook", nil)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- CONFIG
_G.WEBHOOK_URL = ""
_G.DISCORD_USER_ID = ""
_G.webhookEnabled = false

local webhookHooked = false

-- Use the EXACT same request method that works in your reference
local request = http_request
if not request then
    warn("executor lu ga support webhook 💀")
    return
end

local Pets
pcall(function() Pets = require(ReplicatedStorage.Shared.Data.Pets) end)

local TRACKED = {
    ["Secret"] = true,
    ["Celestial"] = true,
    ["Infinity"] = true,
    ["Void"] = true,
    ["Super Legendary"] = true,
}

-- ======================================
-- QUEUE SYSTEM (from working reference)
-- ======================================
local webhookQueue = {}
local webhookProcessing = false

local function sendWebhookRaw(msg)
    local ok, err = pcall(function()
        request({
            Url = _G.WEBHOOK_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode({
                content = (_G.DISCORD_USER_ID ~= "" and "<@" .. _G.DISCORD_USER_ID .. ">" or nil),
                embeds = {{
                    title = "🎉 Secret Pet Hatched!",
                    description = msg,
                    color = 16711680
                }}
            })
        })
    end)
    return ok, err
end

local function processWebhookQueue()
    if webhookProcessing then return end
    webhookProcessing = true

    task.spawn(function()
        while #webhookQueue > 0 do
            local item = table.remove(webhookQueue, 1)
            sendWebhookRaw(item.msg)
            task.wait(1)
        end
        webhookProcessing = false
    end)
end

local function queueWebhook(petName, eggName, extras)
    if not _G.webhookEnabled then return end
    if _G.WEBHOOK_URL == "" then return end

    local tags = {}
    if extras.Shiny then table.insert(tags, "✨ Shiny") end
    if extras.Mythic then table.insert(tags, "🌟 Mythic") end
    if extras.XL then table.insert(tags, "📏 XL") end

    local tagStr = #tags > 0 and (" | " .. table.concat(tags, " | ")) or ""

    local msg = ("**%s** from **%s**\n👤 Player: **%s**\n🕐 Time: **%s**%s"):format(
        petName,
        eggName,
        player.Name,
        os.date("%H:%M:%S"),
        tagStr
    )

    table.insert(webhookQueue, { msg = msg })
    processWebhookQueue()
end

-- ======================================
-- HOOK (from working reference)
-- ======================================
local function hook()
    if webhookHooked then return end

    local success, HatchingModule = pcall(function()
        return require(ReplicatedStorage.Client.Effects.HatchEgg)
    end)

    if success and HatchingModule then
        hookfunction(HatchingModule.Play, newcclosure(function(self, data)
            if type(data) == "table" and data.Pets then
                for _, petData in ipairs(data.Pets) do
                    local pet = petData.Pet
                    if pet and pet.Name then
                        local ok, petInfo = pcall(function()
                            return Pets[pet.Name]
                        end)
                        if ok and petInfo and TRACKED[petInfo.Rarity] then
                            queueWebhook(
                                pet.Name,
                                data.Name or "Unknown",
                                {
                                    Shiny = pet.Shiny,
                                    Mythic = pet.Mythic,
                                    XL = pet.XL
                                }
                            )
                        end
                    end
                end
            end
            return
        end))
        webhookHooked = true
        print("[Webhook] hooked 🔥")
    else
        warn("[Webhook] Failed to hook HatchEgg module")
    end
end

-- ================================================
-- UI (RAYFIELD - Foolproof)
-- ================================================
local urlInput
local idInput

WebhookTab:CreateSection("Webhook Settings")

urlInput = WebhookTab:CreateInput({
    Name = "Webhook URL",
    CurrentValue = "",
    PlaceholderText = "https://webhook.lewisakura.moe/api/webhooks/...",
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

-- 🔄 Auto-read input fields (no Enter needed)
local oldQueueWebhook = queueWebhook
queueWebhook = function(petName, eggName, extras)
    if urlInput and urlInput.Text then
        _G.WEBHOOK_URL = urlInput.Text
    end
    if idInput and idInput.Text then
        _G.DISCORD_USER_ID = idInput.Text
    end
    return oldQueueWebhook(petName, eggName, extras)
end

print("Webhook udah bener, kalo masih jelek berarti lu nya 😭")
