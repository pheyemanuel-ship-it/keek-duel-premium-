--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--// ScreenGui
local sg = Instance.new("ScreenGui")
sg.Name = "KeekDuel"
sg.Parent = PlayerGui
sg.ResetOnSpawn = false

--// Main Frame
local main = Instance.new("Frame")
main.Parent = sg
main.Size = UDim2.new(0,560,0,600)
main.Position = UDim2.new(0.5,-280,0.5,-300)
main.BackgroundColor3 = Color3.fromRGB(1,1,1)
main.BackgroundTransparency = 1

local corner = Instance.new("UICorner")
corner.Parent = main
corner.CornerRadius = UDim.new(0,12)

-- 🔴 Red Outline
local outline = Instance.new("UIStroke")
outline.Parent = main
outline.Color = Color3.fromRGB(255,0,0)
outline.Thickness = 2

--// Header
local header = Instance.new("Frame")
header.Parent = main
header.Size = UDim2.new(1,0,0,54)
header.BackgroundTransparency = 1

-- Title
local title = Instance.new("TextLabel")
title.Parent = header
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "Keek Duel"
title.Font = Enum.Font.GothamBlack
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(255,0,0)

-- Close Button
local close = Instance.new("TextButton")
close.Parent = header
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-35,0.5,-15)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(150,0,0)
close.TextColor3 = Color3.fromRGB(255,255,255)

close.MouseButton1Click:Connect(function()
    sg:Destroy()
end)

--// Columns
local left = Instance.new("Frame")
left.Parent = main
left.Position = UDim2.new(0,10,0,70)
left.Size = UDim2.new(0.45,0,0.8,0)
left.BackgroundTransparency = 1

local right = Instance.new("Frame")
right.Parent = main
right.Position = UDim2.new(0.55,0,0,70)
right.Size = UDim2.new(0.45,0,0.8,0)
right.BackgroundTransparency = 1

--// Feature Tables
local Features = {
SpeedBoost = false,
AntiRagdoll = false,
AutoSteal = false,
SpamBat = false,
SpeedWhileStealing = false
}

local Values = {
BoostSpeed = 30
}

--// Toggle Creator
local function createToggle(parent,text,y)
local btn = Instance.new("TextButton")
btn.Parent = parent
btn.Size = UDim2.new(1,0,0,40)
btn.Position = UDim2.new(0,0,0,y)
btn.Text = text.." : OFF"
btn.BackgroundColor3 = Color3.fromRGB(20,20,20)
btn.TextColor3 = Color3.fromRGB(255,255,255)

local state = false

btn.MouseButton1Click:Connect(function()
state = not state
btn.Text = text.." : "..(state and "ON" or "OFF")
Features[text] = state
end)

return btn
end

-- Toggles
local speedBtn = createToggle(left,"SpeedBoost",0)
local ragdollBtn = createToggle(left,"AntiRagdoll",50)
local stealBtn = createToggle(left,"AutoSteal",100)

local batBtn = createToggle(right,"SpamBat",0)
local speedStealBtn = createToggle(right,"SpeedWhileStealing",50)

--// SpeedBoost
RunService.Heartbeat:Connect(function()
if Features.SpeedBoost then
local char = Player.Character
if char then
local hum = char:FindFirstChildOfClass("Humanoid")
if hum then
hum.WalkSpeed = Values.BoostSpeed
end
end
end
end)

--// SpamBat
RunService.Heartbeat:Connect(function()
if Features.SpamBat then
local char = Player.Character
if char then
local tool = char:FindFirstChildOfClass("Tool")
if tool then
tool:Activate()
end
end
end
end)

--// SpeedWhileStealing
RunService.Heartbeat:Connect(function()
if Features.SpeedWhileStealing then
local char = Player.Character
if char then
local hum = char:FindFirstChildOfClass("Humanoid")
if hum then
hum.WalkSpeed = 29
end
end
end
end)

--// AutoSteal Placeholder
task.spawn(function()
while task.wait(0.5) do
if Features.AutoSteal then
print("Auto stealing...")
end
end
end)

--// Anti Ragdoll System
local antiRagdollMode = nil
local cachedCharData = {}

local function cacheChar()
local char = Player.Character
if not char then return end
cachedCharData.humanoid = char:FindFirstChildOfClass("Humanoid")
cachedCharData.root = char:FindFirstChild("HumanoidRootPart")
end

local function forceUnragdoll()
if not cachedCharData.humanoid then return end
cachedCharData.humanoid:ChangeState(Enum.HumanoidStateType.Running)
end

task.spawn(function()
while task.wait() do
if Features.AntiRagdoll then
cacheChar()
if cachedCharData.humanoid then
local state = cachedCharData.humanoid:GetState()
if state == Enum.HumanoidStateType.Ragdoll
or state == Enum.HumanoidStateType.Physics
or state == Enum.HumanoidStateType.FallingDown then
forceUnragdoll()
end
end
end
end
end)
