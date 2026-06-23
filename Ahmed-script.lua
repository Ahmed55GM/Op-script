------------------------------------------------
-- ADMIN PANEL GOD VERSION (FIXED)
------------------------------------------------

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")

local player = Players.LocalPlayer

if player:FindFirstChild("AdminBlocked") then return end

------------------------------------------------
-- SETTINGS & STATE
------------------------------------------------
local KEY = "@hM3d_i$-The-Best"

local unlocked = false
local flying = false
local noclip = false
local immortal = false
local infJump = false
local espActive = false

local flySpeed = 80
local walkSpeed = 16

local flyConn, noclipConn, immortalConn, espConn, infJumpConn
local checkpointPos = nil
local checkpointBeam = nil

------------------------------------------------
-- GUI SETUP
------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "GodAdminPanel"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

-- Helper function for UI Strokes
local function addStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

------------------------------------------------
-- NOTIFICATION SYSTEM
------------------------------------------------
local function notify(text, color)
    color = color or Color3.fromRGB(255, 255, 255)
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 300, 0, 50)
    notif.Position = UDim2.new(0.5, -150, 0, -60)
    notif.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    notif.Text = text
    notif.TextColor3 = color
    notif.TextScaled = true
    notif.Font = Enum.Font.GothamBold
    notif.BackgroundTransparency = 0.1
    notif.Parent = gui
    
    addStroke(notif, color, 2)
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
    
    TS:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -150, 0, 20)}):Play()
    
    task.delay(2.5, function()
        TS:Create(notif, TweenInfo.new(0.4, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -150, 0, -60)}):Play()
        task.wait(0.4)
        notif:Destroy()
    end)
end

------------------------------------------------
-- LOCK GUI
------------------------------------------------
local lock = Instance.new("Frame")
lock.Size = UDim2.new(1, 0, 1, 0)
lock.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
lock.BorderSizePixel = 0
lock.Parent = gui

local box = Instance.new("TextBox")
box.Size = UDim2.new(0.4, 0, 0.08, 0)
box.Position = UDim2.new(0.3, 0, 0.4, 0)
box.PlaceholderText = "Enter Key"
box.Text = ""
box.TextScaled = true
box.Font = Enum.Font.GothamBold
box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
box.TextColor3 = Color3.new(1,1,1)
box.Parent = lock
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)
addStroke(box, Color3.fromRGB(60, 60, 60), 1)

local unlock = Instance.new("TextButton")
unlock.Size = UDim2.new(0.3, 0, 0.08, 0)
unlock.Position = UDim2.new(0.35, 0, 0.5, 0)
unlock.Text = "Unlock"
unlock.TextScaled = true
unlock.Font = Enum.Font.GothamBold
unlock.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
unlock.TextColor3 = Color3.new(1,1,1)
unlock.Parent = lock
Instance.new("UICorner", unlock).CornerRadius = UDim.new(0, 8)
addStroke(unlock, Color3.fromRGB(50, 200, 50), 2)

local trial = Instance.new("TextButton")
trial.Size = UDim2.new(0.3, 0, 0.08, 0)
trial.Position = UDim2.new(0.35, 0, 0.6, 0)
trial.Text = "Use 60 Seconds"
trial.TextScaled = true
trial.Font = Enum.Font.GothamBold
trial.BackgroundColor3 = Color3.fromRGB(120, 80, 40)
trial.TextColor3 = Color3.new(1,1,1)
trial.Parent = lock
Instance.new("UICorner", trial).CornerRadius = UDim.new(0, 8)
addStroke(trial, Color3.fromRGB(200, 150, 50), 2)

------------------------------------------------
-- ADMIN PANEL
------------------------------------------------
local panel = Instance.new("Frame")
panel.Visible = false
panel.Size = UDim2.new(0.25, 0, 0.5, 0)
panel.Position = UDim2.new(0.02, 0, 0.25, 0)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
panel.Active = true
panel.Draggable = true
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)
addStroke(panel, Color3.fromRGB(100, 100, 255), 2)

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0.1, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
titleBar.BorderSizePixel = 0
titleBar.Parent = panel
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.8, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "ADMIN PANEL"
title.TextScaled = true
title.Font = Enum.Font.GothamBlack
title.TextColor3 = Color3.fromRGB(100, 150, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Minimize Button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0.2, 0, 1, 0)
minBtn.Position = UDim2.new(0.8, 0, 0, 0)
minBtn.BackgroundTransparency = 1
minBtn.Text = "-"
minBtn.TextScaled = true
minBtn.Font = Enum.Font.GothamBold
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.Parent = titleBar

-- Scrolling List for Buttons
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 0.9, 0)
scrollFrame.Position = UDim2.new(0, 0, 0.1, 0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 4
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scrollFrame

------------------------------------------------
-- BUTTON MAKER
------------------------------------------------
local function makeButton(text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.9, 0, 0.08, 0)
    b.TextScaled = true
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    b.TextColor3 = Color3.new(1,1,1)
    b.Parent = scrollFrame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    addStroke(b, Color3.fromRGB(70, 70, 80), 1)
    return b
end

------------------------------------------------
-- BUTTONS & INPUTS
------------------------------------------------
local flyBtn = makeButton("Fly OFF")
local noclipBtn = makeButton("Noclip OFF")
local immortalBtn = makeButton("Immortal OFF")
local infJumpBtn = makeButton("Inf Jump OFF")
local espBtn = makeButton("Player ESP OFF")

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0.9, 0, 0.08, 0)
speedBox.PlaceholderText = "Fly Speed (80)"
speedBox.Text = ""
speedBox.TextScaled = true
speedBox.Font = Enum.Font.GothamBold
speedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.Parent = scrollFrame
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 8)
addStroke(speedBox, Color3.fromRGB(70, 70, 80), 1)

local walkBox = Instance.new("TextBox")
walkBox.Size = UDim2.new(0.9, 0, 0.08, 0)
walkBox.PlaceholderText = "WalkSpeed (16)"
walkBox.Text = ""
walkBox.TextScaled = true
walkBox.Font = Enum.Font.GothamBold
walkBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
walkBox.TextColor3 = Color3.new(1,1,1)
walkBox.Parent = scrollFrame
Instance.new("UICorner", walkBox).CornerRadius = UDim.new(0, 8)
addStroke(walkBox, Color3.fromRGB(70, 70, 80), 1)

local destroyBtn = makeButton("Destroy GUI")

------------------------------------------------
-- CP BUTTONS
------------------------------------------------
local setCP = Instance.new("TextButton")
setCP.Visible = false
setCP.Size = UDim2.new(0.15, 0, 0.06, 0)
setCP.Position = UDim2.new(0.8, 0, 0.8, 0)
setCP.Text = "SET CP"
setCP.TextScaled = true
setCP.Font = Enum.Font.GothamBold
setCP.BackgroundColor3 = Color3.fromRGB(30, 60, 30)
setCP.TextColor3 = Color3.new(1,1,1)
setCP.Parent = gui
Instance.new("UICorner", setCP).CornerRadius = UDim.new(0, 8)
addStroke(setCP, Color3.fromRGB(50, 200, 50), 2)

local tpCP = Instance.new("TextButton")
tpCP.Visible = false
tpCP.Size = UDim2.new(0.15, 0, 0.06, 0)
tpCP.Position = UDim2.new(0.8, 0, 0.88, 0)
tpCP.Text = "TP CP"
tpCP.TextScaled = true
tpCP.Font = Enum.Font.GothamBold
tpCP.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
tpCP.TextColor3 = Color3.new(1,1,1)
tpCP.Parent = gui
Instance.new("UICorner", tpCP).CornerRadius = UDim.new(0, 8)
addStroke(tpCP, Color3.fromRGB(200, 50, 50), 2)

------------------------------------------------
-- LOGIC & CONNECTIONS
------------------------------------------------
local function enable()
    lock:Destroy()
    panel.Visible = true
    setCP.Visible = true
    tpCP.Visible = true
    unlocked = true
    notify("Panel Unlocked!", Color3.fromRGB(50, 255, 50))
end

-- Key Check
local function check()
    if string.gsub(box.Text, "%s+", "") == KEY then
        enable()
    else
        notify("Wrong Key!", Color3.fromRGB(255, 50, 50))
    end
end

unlock.MouseButton1Click:Connect(check)
box.FocusLost:Connect(function(enter) if enter then check() end end)

-- 60s Trial
trial.MouseButton1Click:Connect(function()
    enable()
    local timer = Instance.new("TextLabel")
    timer.Size = UDim2.new(0.3, 0, 0.05, 0)
    timer.Position = UDim2.new(0.35, 0, 0.02, 0)
    timer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    timer.TextScaled = true
    timer.Font = Enum.Font.GothamBold
    timer.TextColor3 = Color3.new(1,1,1)
    timer.Parent = gui
    addStroke(timer, Color3.fromRGB(200, 50, 50), 2)
    
    coroutine.wrap(function()
        for i = 60, 0, -1 do
            timer.Text = "Trial: "..i.."s"
            task.wait(1)
        end
        local blocked = Instance.new("BoolValue")
        blocked.Name = "AdminBlocked"
        blocked.Parent = player
        gui:Destroy()
    end)()
end)

-- Minimize Logic
minBtn.MouseButton1Click:Connect(function()
    if panel.Size == UDim2.new(0.25, 0, 0.5, 0) then
        panel:TweenSize(UDim2.new(0.25, 0, 0.1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    else
        panel:TweenSize(UDim2.new(0.25, 0, 0.5, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    end
end)

-- Input Boxes
speedBox.FocusLost:Connect(function()
    local n = tonumber(speedBox.Text)
    if n then flySpeed = n notify("Fly Speed: "..n) end
end)

walkBox.FocusLost:Connect(function()
    local n = tonumber(walkBox.Text)
    if n then 
        walkSpeed = n 
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = n end
        notify("WalkSpeed: "..n) 
    end
end)

-- FLY (Space=Up, Ctrl=Down)
flyBtn.MouseButton1Click:Connect(function()
    if not unlocked then return end
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    flying = not flying
    flyBtn.Text = flying and "Fly ON" or "Fly OFF"
    flyBtn.BackgroundColor3 = flying and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(40, 40, 45)

    if flying then
        hum.PlatformStand = true
        flyConn = RS.RenderStepped:Connect(function()
            if not char or not char.Parent then return end
            local cam = workspace.CurrentCamera
            local move = hum.MoveDirection
            local vel = Vector3.zero

            if move.Magnitude > 0 then
                vel = cam.CFrame.RightVector * move.X + cam.CFrame.LookVector * move.Z
            end

            if UIS:IsKeyDown(Enum.KeyCode.Space) then vel += Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then vel -= Vector3.new(0, 1, 0) end

            hrp.AssemblyLinearVelocity = vel * flySpeed
        end)
    else
        hum.PlatformStand = false
        if flyConn then flyConn:Disconnect() end
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
end)

-- NOCLIP
noclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    noclipBtn.Text = noclip and "Noclip ON" or "Noclip OFF"
    noclipBtn.BackgroundColor3 = noclip and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(40, 40, 45)

    if noclip then
        noclipConn = RS.Stepped:Connect(function()
            local char = player.Character
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide then
                        v.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() end
    end
end)

-- IMMORTAL
immortalBtn.MouseButton1Click:Connect(function()
    immortal = not immortal
    immortalBtn.Text = immortal and "Immortal ON" or "Immortal OFF"
    immortalBtn.BackgroundColor3 = immortal and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(40, 40, 45)

    if immortal then
        immortalConn = RS.Heartbeat:Connect(function()
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = hum.MaxHealth end
        end)
    else
        if immortalConn then immortalConn:Disconnect() end
    end
end)

-- INFINITE JUMP
infJumpBtn.MouseButton1Click:Connect(function()
    infJump = not infJump
    infJumpBtn.Text = infJump and "Inf Jump ON" or "Inf Jump OFF"
    infJumpBtn.BackgroundColor3 = infJump and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(40, 40, 45)
end)

infJumpConn = UIS.JumpRequest:Connect(function()
    if infJump then
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- PLAYER ESP
espBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    espBtn.Text = espActive and "Player ESP ON" or "Player ESP OFF"
    espBtn.BackgroundColor3 = espActive and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(40, 40, 45)

    if espActive then
        espConn = RS.RenderStepped:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local hl = p.Character:FindFirstChild("ESPHighlight")
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "ESPHighlight"
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.5
                        hl.Parent = p.Character
                    end
                end
            end
        end)
    else
        if espConn then espConn:Disconnect() end
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                local hl = p.Character:FindFirstChild("ESPHighlight")
                if hl then hl:Destroy() end
            end
        end
    end
end)

-- Auto WalkSpeed on Respawn
player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").WalkSpeed = walkSpeed
end)

------------------------------------------------
-- CHECKPOINT BEAM
------------------------------------------------
local function createBeam(pos)
    if checkpointBeam then checkpointBeam:Destroy() end

    local base = Instance.new("Part")
    base.Anchored = true
    base.Transparency = 1
    base.CanCollide = false
    base.Position = pos
    base.Parent = workspace

    local top = Instance.new("Part")
    top.Anchored = true
    top.Transparency = 1
    top.CanCollide = false
    top.Position = pos + Vector3.new(0, 30, 0)
    top.Parent = workspace

    local a0 = Instance.new("Attachment")
    a0.Parent = base
    local a1 = Instance.new("Attachment")
    a1.Parent = top

    local beam = Instance.new("Beam")
    beam.Attachment0 = a0
    beam.Attachment1 = a1
    beam.Width0 = 2
    beam.Width1 = 2
    beam.FaceCamera = true
    beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 120))
    beam.Parent = base

    checkpointBeam = base
end

setCP.MouseButton1Click:Connect(function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        checkpointPos = hrp.Position
        createBeam(checkpointPos)
        notify("Checkpoint Set!", Color3.fromRGB(50, 255, 50))
    end
end)

tpCP.MouseButton1Click:Connect(function()
    if not checkpointPos then 
        notify("No Checkpoint Set!", Color3.fromRGB(255, 50, 50)) 
        return 
    end
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local old = hrp.Position
        hrp.CFrame = CFrame.new(checkpointPos + Vector3.new(0, 3, 0))
        checkpointPos = old
        createBeam(old)
    end
end)

------------------------------------------------
-- DESTROY GUI
------------------------------------------------
destroyBtn.MouseButton1Click:Connect(function()
    if flyConn then flyConn:Disconnect() end
    if noclipConn then noclipConn:Disconnect() end
    if immortalConn then immortalConn:Disconnect() end
    if espConn then espConn:Disconnect() end
    if infJumpConn then infJumpConn:Disconnect() end

    notify("Destroying GUI...", Color3.fromRGB(255, 50, 50))
    task.wait(2)
    gui:Destroy()
end)
