--// KEEK DUEL HUB

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- states
local AutoPlay = false
local Aimbot = false
local TpRagdoll = false
local AutoGrab = false

local AimRadius = 60
local AutoDir = "right"

--=====================
-- GUI
--=====================

local gui = Instance.new("ScreenGui")
gui.Name = "KeekDuel"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,240,0,220)
frame.Position = UDim2.new(0.5,-120,0.5,-110)
frame.BackgroundColor3 = Color3.fromRGB(15,15,25)
frame.Parent = gui

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0,120,255)
stroke.Thickness = 2
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "KEEK DUEL"
title.TextColor3 = Color3.fromRGB(0,170,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,6)
layout.Parent = frame

-- toggle creator
local function createToggle(name, callback)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-10,0,32)
    btn.Position = UDim2.new(0,5,0,0)
    btn.Text = name.." : OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.BackgroundColor3 = Color3.fromRGB(25,25,40)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Parent = frame

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(0,120,255)
    s.Parent = btn

    local state = false

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name.." : "..(state and "ON" or "OFF")
        callback(state)
    end)

end

--=====================
-- TOGGLES
--=====================

createToggle("Auto Play",function(v)
    AutoPlay = v
end)

createToggle("Aimbot",function(v)
    Aimbot = v
end)

createToggle("TP Ragdoll",function(v)
    TpRagdoll = v
end)

createToggle("Auto Grab",function(v)
    AutoGrab = v
end)

--=====================
-- FEATURES
--=====================

RunService.RenderStepped:Connect(function()

    local char = player.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")

    if not hrp or not humanoid then return end

    -- AUTO PLAY
    if AutoPlay then
        if AutoDir == "right" then
            humanoid:Move(Vector3.new(1,0,0),true)
        else
            humanoid:Move(Vector3.new(-1,0,0),true)
        end
    end

    -- AUTO GRAB
    if AutoGrab then
        for _,v in pairs(workspace:GetDescendants()) do
            if v.Name == "Grab" and v:IsA("BasePart") then
                if (v.Position - hrp.Position).Magnitude < 15 then
                    firetouchinterest(hrp,v,0)
                    firetouchinterest(hrp,v,1)
                end
            end
        end
    end

end)

-- AIMBOT
RunService.Heartbeat:Connect(function()

    if not Aimbot then return end

    local char = player.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local nearest
    local dist = math.huge

    for _,obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "AnimalPodium" then

            local d = (obj.Position - hrp.Position).Magnitude

            if d < AimRadius and d < dist then
                nearest = obj
                dist = d
            end

        end
    end

    if nearest then
        hrp.CFrame = CFrame.lookAt(hrp.Position,nearest.Position)
    end

end)

-- TP RAGDOLL
RunService.Heartbeat:Connect(function()

    if not TpRagdoll then return end

    local char = player.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _,p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local rag = p.Character:FindFirstChild("HumanoidRootPart")

            if rag then
                hrp.CFrame = rag.CFrame * CFrame.new(0,0,2)
                break
            end
        end
    end

end)

print("Keek Duel Loaded")
