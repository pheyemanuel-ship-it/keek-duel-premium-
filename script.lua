-- ─── KEKE DUEL PREMIUM (WORKING GUI) ─────────────────────────────────────
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
local guiScale = 1

-- Feature toggles
local Features = { AutoSteal = false, AntiRagdoll = false }
local Values = { BoostSpeed=16, SpinSpeed=10, DEFAULT_GRAVITY=196, GalaxyGravityPercent=100, StealingSpeedValue=20, HOP_POWER=50, HOP_COOLDOWN=0.2 }

-- ─── GUI ────────────────────────────────────────────────────────────────
local sg = Instance.new("ScreenGui")
sg.Name = "KeekDuelPremium"
sg.ResetOnSpawn = false
sg.Parent = Player:WaitForChild("PlayerGui")

-- Main frame
local mainGui = Instance.new("Frame")
mainGui.Size = UDim2.new(0,500*guiScale,0,400*guiScale)
mainGui.Position = UDim2.new(0.5,-250*guiScale,0.5,-200*guiScale)
mainGui.BackgroundColor3 = Color3.fromRGB(25,25,25)
mainGui.BorderSizePixel = 0
mainGui.ClipsDescendants = true
mainGui.Parent = sg
Instance.new("UICorner", mainGui).CornerRadius = UDim.new(0,12)

-- Red outline
local stroke = Instance.new("UIStroke", mainGui)
stroke.Color = Color3.fromRGB(255,0,0)
stroke.Thickness = 2

-- Top bar with title and close button
local title = Instance.new("TextLabel", mainGui)
title.Size = UDim2.new(1,-40,0,30)
title.Position = UDim2.new(0,5,0,0)
title.BackgroundTransparency = 1
title.Text = "Keek Duel Premium"
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255,0,0)
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", mainGui)
closeBtn.Size = UDim2.new(0,24,0,24)
closeBtn.Position = UDim2.new(1,-28,0,3)
closeBtn.BackgroundColor3 = Color3.fromRGB(255,0,0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.TextSize = 14
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)

-- Open circle button
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0,40,0,40)
openBtn.Position = UDim2.new(0,10,0,10)
openBtn.BackgroundColor3 = Color3.fromRGB(255,0,0)
openBtn.Text = "K"
openBtn.TextColor3 = Color3.fromRGB(255,255,255)
openBtn.Font = Enum.Font.GothamBlack
openBtn.TextSize = 20
openBtn.Visible = false
openBtn.Parent = sg
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1,0)

closeBtn.MouseButton1Click:Connect(function()
    mainGui.Visible = false
    openBtn.Visible = true
end)
openBtn.MouseButton1Click:Connect(function()
    mainGui.Visible = true
    openBtn.Visible = false
end)

-- Content area
local content = Instance.new("Frame", mainGui)
content.Size = UDim2.new(1,-10,1,-35)
content.Position = UDim2.new(0,5,0,30)
content.BackgroundTransparency = 1

-- LEFT COLUMN
local leftColumn = Instance.new("Frame", content)
leftColumn.Size = UDim2.new(0.46,0,1,0)
leftColumn.BackgroundTransparency = 1
local leftScroll = Instance.new("ScrollingFrame", leftColumn)
leftScroll.Size = UDim2.new(1,0,1,0)
leftScroll.BackgroundTransparency = 1
leftScroll.ScrollBarThickness = 6
local leftLayout = Instance.new("UIListLayout", leftScroll)
leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
leftLayout.Padding = UDim.new(0,6)

-- RIGHT COLUMN
local rightColumn = Instance.new("Frame", content)
rightColumn.Size = UDim2.new(0.46,0,1,0)
rightColumn.Position = UDim2.new(0.52,0,0,0)
rightColumn.BackgroundTransparency = 1
local rightScroll = Instance.new("ScrollingFrame", rightColumn)
rightScroll.Size = UDim2.new(1,0,1,0)
rightScroll.BackgroundTransparency = 1
rightScroll.ScrollBarThickness = 6
local rightLayout = Instance.new("UIListLayout", rightScroll)
rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
rightLayout.Padding = UDim.new(0,6)

-- ─── PROGRESS BAR ─────────────────────────────────────────────
local PB_W, PB_H = 260,28
local progressBar = Instance.new("Frame", sg)
progressBar.Size = UDim2.new(0,PB_W,0,PB_H)
progressBar.Position = UDim2.new(0.5,-PB_W/2,1,-90)
progressBar.BackgroundColor3 = Color3.fromRGB(10,10,10)
progressBar.BackgroundTransparency = 0.15
progressBar.BorderSizePixel = 0
Instance.new("UICorner", progressBar).CornerRadius = UDim.new(1,0)
local pStroke = Instance.new("UIStroke", progressBar)
pStroke.Thickness = 2
local pTrack = Instance.new("Frame", progressBar)
pTrack.Size = UDim2.new(1,-8,0,6)
pTrack.Position = UDim2.new(0,4,1,-9)
pTrack.BackgroundColor3 = Color3.fromRGB(30,30,30)
Instance.new("UICorner", pTrack).CornerRadius = UDim.new(1,0)
local ProgressBarFill = Instance.new("Frame", pTrack)
ProgressBarFill.Size = UDim2.new(0,0,1,0)
ProgressBarFill.BackgroundColor3 = Color3.fromRGB(255,220,0)
Instance.new("UICorner", ProgressBarFill).CornerRadius = UDim.new(1,0)
local ProgressPercentLabel = Instance.new("TextLabel", progressBar)
ProgressPercentLabel.Size = UDim2.new(1,0,1,-8)
ProgressPercentLabel.BackgroundTransparency = 1
ProgressPercentLabel.Text = "0%"
ProgressPercentLabel.Font = Enum.Font.GothamBlack
ProgressPercentLabel.TextSize = 13
ProgressPercentLabel.TextXAlignment = Enum.TextXAlignment.Center
ProgressPercentLabel.TextYAlignment = Enum.TextYAlignment.Center

-- Progress update function
local function updateProgress(percent)
    percent = math.clamp(percent,0,1)
    ProgressBarFill.Size = UDim2.new(percent,0,1,0)
    ProgressPercentLabel.Text = string.format("%d%%", percent*100)
end

-- ─── SLIDERS ─────────────────────────────────────────────
local sliderDefs = {
    {label="Boost Speed", key="BoostSpeed", min=16,max=80},
    {label="Spin Speed", key="SpinSpeed", min=1,max=50},
    {label="Gravity", key="DEFAULT_GRAVITY", min=50,max=500},
    {label="Galaxy Gravity %", key="GalaxyGravityPercent", min=0,max=100},
    {label="Stealing Speed", key="StealingSpeedValue", min=10,max=50},
    {label="Hop Power", key="HOP_POWER", min=20,max=100},
    {label="Hop Cooldown", key="HOP_COOLDOWN", min=0.05,max=0.5},
}

-- Dummy createSlider function for testing
function createSlider(parent,label,min,max,key,callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1,0,0,30)
    frame.BackgroundTransparency = 1
    local txt = Instance.new("TextLabel", frame)
    txt.Size = UDim2.new(1,0,1,0)
    txt.BackgroundTransparency = 1
    txt.Text = label..": "..Values[key]
    txt.TextColor3 = Color3.fromRGB(255,255,255)
    txt.Font = Enum.Font.Gotham
    txt.TextSize = 14
    callback(Values[key])
end

for _,s in ipairs(sliderDefs) do
    createSlider(leftScroll,s.label,s.min,s.max,s.key,function(val) Values[s.key]=val end)
end

-- ─── AUTO STEAL ─────────────────────────────────────────────
local autoStealConn = nil
local function getNearestPlayer()
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local root = char.HumanoidRootPart
    local nearest, nearestDist = nil, math.huge
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=Player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (plr.Character.HumanoidRootPart.Position - root.Position).Magnitude
            if dist < nearestDist then nearestDist=dist nearest=plr end
        end
    end
    return nearest
end
local function startAutoSteal()
    if autoStealConn then return end
    autoStealConn = RunService.Heartbeat:Connect(function()
        if not Features.AutoSteal then return end
        local char = Player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local target = getNearestPlayer()
        if root and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local dir = (target.Character.HumanoidRootPart.Position - root.Position).Unit
            root.AssemblyLinearVelocity = Vector3.new(dir.X*Values.StealingSpeedValue,root.AssemblyLinearVelocity.Y,dir.Z*Values.StealingSpeedValue)
        end
    end)
end
local function stopAutoSteal()
    if autoStealConn then autoStealConn:Disconnect() autoStealConn=nil end
end
