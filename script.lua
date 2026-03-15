-- KEEK DUEL HUB (SCROLLABLE)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-------------------------------------------------
-- STATE
-------------------------------------------------

local State = {
    Speed = false,
    InfJump = false,
    AntiRagdoll = false,
    AutoGrab = false,

    AutoPlayEnabled = false,
    AutoPlayDir = "right",
    AutoPlaySpeed = 5
}

-------------------------------------------------
-- GUI
-------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "KeekDuel"
gui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,260,0,320)
frame.Position = UDim2.new(0.7,0,0.35,0)
frame.BackgroundColor3 = Color3.fromRGB(25,15,40)
frame.Parent = gui

Instance.new("UICorner",frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "KEEK DUEL"
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(200,120,255)
title.Parent = frame

-------------------------------------------------
-- SCROLLING FRAME
-------------------------------------------------

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,0,1,-40)
scroll.Position = UDim2.new(0,0,0,40)
scroll.CanvasSize = UDim2.new(0,0,0,500)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1
scroll.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = scroll

-------------------------------------------------
-- TOGGLE CREATOR
-------------------------------------------------

local function createToggle(name,callback)

    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(0.9,0,0,32)
    holder.BackgroundColor3 = Color3.fromRGB(35,25,60)
    holder.Parent = scroll

    Instance.new("UICorner",holder).CornerRadius = UDim.new(0,8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = holder

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,45,0,22)
    btn.Position = UDim2.new(0.75,0,0.2,0)
    btn.Text = "OFF"
    btn.BackgroundColor3 = Color3.fromRGB(80,40,130)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = holder

    local enabled = false

    btn.MouseButton1Click:Connect(function()

        enabled = not enabled

        btn.Text = enabled and "ON" or "OFF"
        btn.BackgroundColor3 = enabled
            and Color3.fromRGB(160,90,255)
            or Color3.fromRGB(80,40,130)

        callback(enabled)

    end)

end

-------------------------------------------------
-- AUTO PLAY SETTINGS
-------------------------------------------------

local dirLabel = Instance.new("TextLabel")
dirLabel.Size = UDim2.new(1,0,0,20)
dirLabel.BackgroundTransparency = 1
dirLabel.Text = "Auto Play Direction"
dirLabel.TextColor3 = Color3.fromRGB(255,180,0)
dirLabel.Font = Enum.Font.Gotham
dirLabel.TextSize = 14
dirLabel.Parent = scroll

local dirFrame = Instance.new("Frame")
dirFrame.Size = UDim2.new(0.9,0,0,30)
dirFrame.BackgroundTransparency = 1
dirFrame.Parent = scroll

local right = Instance.new("TextButton")
right.Size = UDim2.new(0.45,0,1,0)
right.Text = "Right"
right.Parent = dirFrame

local left = Instance.new("TextButton")
left.Size = UDim2.new(0.45,0,1,0)
left.Position = UDim2.new(0.55,0,0,0)
left.Text = "Left"
left.Parent = dirFrame

right.MouseButton1Click:Connect(function()
    State.AutoPlayDir = "right"
end)

left.MouseButton1Click:Connect(function()
    State.AutoPlayDir = "left"
end)

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0.9,0,0,30)
speedBox.Text = tostring(State.AutoPlaySpeed)
speedBox.PlaceholderText = "Play Speed"
speedBox.Parent = scroll

speedBox.FocusLost:Connect(function()
    State.AutoPlaySpeed = tonumber(speedBox.Text) or State.AutoPlaySpeed
end)

-------------------------------------------------
-- TOGGLES
-------------------------------------------------

createToggle("Speed",function(v)
    State.Speed = v
end)

createToggle("Inf Jump",function(v)
    State.InfJump = v
end)

createToggle("Anti Ragdoll",function(v)
    State.AntiRagdoll = v
end)

createToggle("Auto Grab",function(v)
    State.AutoGrab = v
end)

createToggle("Auto Play",function(v)
    State.AutoPlayEnabled = v
end)

-------------------------------------------------
-- SPEED
-------------------------------------------------

RunService.RenderStepped:Connect(function()

    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")

    if hum then
        hum.WalkSpeed = State.Speed and 50 or 16
    end

end)

-------------------------------------------------
-- INFINITE JUMP
-------------------------------------------------

UIS.JumpRequest:Connect(function()

    if not State.InfJump then return end

    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")

    if hum then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end

end)

-------------------------------------------------
-- ANTI RAGDOLL
-------------------------------------------------

RunService.Heartbeat:Connect(function()

    if not State.AntiRagdoll then return end

    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")

    if hum and hum:GetState() == Enum.HumanoidStateType.Ragdoll then
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end

end)

-------------------------------------------------
-- AUTO GRAB
-------------------------------------------------

RunService.Heartbeat:Connect(function()

    if not State.AutoGrab then return end

    local char = player.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _,v in pairs(workspace:GetDescendants()) do

        if v:IsA("Tool") then

            local handle = v:FindFirstChild("Handle")

            if handle and (handle.Position-root.Position).Magnitude < 10 then
                firetouchinterest(root,handle,0)
                firetouchinterest(root,handle,1)
            end

        end

    end

end)

-------------------------------------------------
-- AUTO PLAY
-------------------------------------------------

RunService.Heartbeat:Connect(function()

    if not State.AutoPlayEnabled then return end

    local char = player.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local dir = State.AutoPlayDir == "right" and 1 or -1

    root.CFrame = root.CFrame * CFrame.new(dir * State.AutoPlaySpeed * 0.1,0,0)

end)
