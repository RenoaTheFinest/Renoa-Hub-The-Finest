-- =========================
-- EFFECTS TAB (FIX GLOBAL)
-- =========================

local Rayfield = _G.Rayfield
local Window = _G.Window

local EffectsTab = Window:CreateTab("Effects", nil)

local ToDisable = {
    Textures = true,
    VisualEffects = true,
    Parts = true,
    Particles = true,
    Sky = true,
}

local function safeSet(obj, prop, value)
    pcall(function() obj[prop] = value end)
end

local function RunEffectsDisabler()
    for _, v in pairs(game:GetDescendants()) do
        if ToDisable.Parts and v:IsA("BasePart") then
            safeSet(v, "Material", Enum.Material.SmoothPlastic)
        end

        if ToDisable.Particles then
            if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                safeSet(v, "Enabled", false)
            end
        end

        if ToDisable.VisualEffects then
            if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") then
                safeSet(v, "Enabled", false)
            end
        end

        if ToDisable.Textures then
            if v:IsA("Decal") or v:IsA("Texture") then
                safeSet(v, "Transparency", 1)
            end
        end

        if ToDisable.Sky and v:IsA("Sky") then
            safeSet(v, "Parent", nil)
        end
    end

    print("Effects dimatiin 🔥")
end

local function RunFullBright()
    local Lighting = game:GetService("Lighting")

    safeSet(Lighting, "Brightness", 5)
    safeSet(Lighting, "Ambient", Color3.fromRGB(255,255,255))
    safeSet(Lighting, "OutdoorAmbient", Color3.fromRGB(255,255,255))
    safeSet(Lighting, "FogEnd", math.huge)

    print("FullBright nyala 🔥")
end

EffectsTab:CreateSection("Disable Effects")

EffectsTab:CreateToggle({
    Name = "Disable Textures",
    CurrentValue = true,
    Callback = function(V) ToDisable.Textures = V end
})

EffectsTab:CreateToggle({
    Name = "Disable Visual Effects",
    CurrentValue = true,
    Callback = function(V) ToDisable.VisualEffects = V end
})

EffectsTab:CreateToggle({
    Name = "Disable Parts",
    CurrentValue = true,
    Callback = function(V) ToDisable.Parts = V end
})

EffectsTab:CreateToggle({
    Name = "Disable Particles",
    CurrentValue = true,
    Callback = function(V) ToDisable.Particles = V end
})

EffectsTab:CreateToggle({
    Name = "Disable Sky",
    CurrentValue = true,
    Callback = function(V) ToDisable.Sky = V end
})

EffectsTab:CreateButton({
    Name = "Apply Effects",
    Callback = function()
        RunEffectsDisabler()
    end
})

EffectsTab:CreateSection("FullBright")

EffectsTab:CreateButton({
    Name = "Enable FullBright",
    Callback = function()
        RunFullBright()
    end
})
