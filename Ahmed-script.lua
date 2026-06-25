------------------------------------------------
-- ADMIN PANEL GOD VERSION (100% MOBILE PERFECTED)
------------------------------------------------

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
print("[ADMIN PANEL] Script started...")

------------------------------------------------
-- SETTINGS & STATE
------------------------------------------------
local KEY = "@hM3d_i$-The-Best"

-- Add usernames here for auto-access
local AUTO_ACCESS = {
    ["ninjaman32352"] = true
}

local unlocked = false
local flying = false
local noclip = false
local immortal = false
local infJump = false
local espActive = false

local flySpeed = 80
local walkSpeed = 16

local flyConn, noclipConn, immortalConn, espConn, infJumpConn
local savedCheckpoints = {}

local holdingUp = false
local holdingDown = false
local isShuttingDown = false

------------------------------------------------
-- GUI SETUP
------------------------------------------------
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then return end

local gui = Instance.new("ScreenGui")
gui.Name = "GodAdminPanel"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local function addStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

-- Custom Drag Function (Works perfectly with fingers on mobile)
local function makeDraggable(frame)
    local dragging = false
    local dragInput, mousePos, framePos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

------------------------------------------------
-- NOTIFICATION SYSTEM
------------------------------------------------
local function notify(text, color)
    if isShuttingDown or not gui then return end
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
    notif.ZIndex = 100
    
    addStroke(notif, color, 2)
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
    
    TS:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -150, 0, 20)}):Play()
    
    task.delay(2.5, function()
        if not notif or not notif.Parent then return end
        TS:Create(notif, TweenInfo.new(0.4, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -150, 0, -60)}):Play()
    end)
    
    Debris:AddItem(notif, 3.5)
end

------------------------------------------------
-- LOCK GUI
------------------------------------------------
local lockBox = Instance.new("Frame")
lockBox.Size = UDim2.new(0.35, 0, 0.3, 0)
lockBox.Position = UDim2.new(0.325, 0, 0.35, 0)
lockBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
lockBox.Parent = gui
Instance.new("UICorner", lockBox).CornerRadius = UDim.new(0, 12)
addStroke(lockBox, Color3.fromRGB(100, 100, 255), 2)
makeDraggable(lockBox)

local closeLockBtn = Instance.new("TextButton")
closeLockBtn.Size = UDim2.new(0.15, 0, 0.2, 0)
closeLockBtn.Position = UDim2.new(0.82, 0, 0.05, 0)
closeLockBtn.Text = "X"
closeLockBtn.TextScaled = true
closeLockBtn.Font = Enum.Font.GothamBold
closeLockBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
closeLockBtn.TextColor3 = Color3.new(1, 1, 1)
closeLockBtn.Parent = lockBox
Instance.new("UICorner", closeLockBtn).CornerRadius = UDim.new(0, 8)
addStroke(closeLockBtn, Color3.fromRGB(255, 50, 50), 2)

local box = Instance.new("TextBox")
box.Size = UDim2.new(0.8, 0, 0.25, 0)
box.Position = UDim2.new(0.1, 0, 0.3, 0)
box.PlaceholderText = "Enter Key"
box.Text = ""
box.TextScaled = true
box.Font = Enum.Font.GothamBold
box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
box.TextColor3 = Color3.new(1,1,1)
box.Parent = lockBox
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)
addStroke(box, Color3.fromRGB(60, 60, 60), 1)

local unlock = Instance.new("TextButton")
unlock.Size = UDim2.new(0.45, 0, 0.2, 0)
unlock.Position = UDim2.new(0.275, 0, 0.6, 0)
unlock.Text = "Unlock"
unlock.TextScaled = true
unlock.Font = Enum.Font.GothamBold
unlock.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
unlock.TextColor3 = Color3.new(1,1,1)
unlock.Parent = lockBox
Instance.new("UICorner", unlock).CornerRadius = UDim.new(0, 8)
addStroke(unlock, Color3.fromRGB(50, 200, 50), 2)

local trial = Instance.new("TextButton")
trial.Size = UDim2.new(0.8, 0, 0.15, 0)
trial.Position = UDim2.new(0.1, 0, 0.82, 0)
trial.Text = "Use 60 Seconds"
trial.TextScaled = true
trial.Font = Enum.Font.GothamBold
trial.BackgroundColor3 = Color3.fromRGB(120, 80, 40)
trial.TextColor3 = Color3.new(1,1,1)
trial.Parent = lockBox
Instance.new("UICorner", trial).CornerRadius = UDim.new(0, 8)
addStroke(trial, Color3.fromRGB(200, 150, 50), 2)

------------------------------------------------
-- ADMIN PANEL
------------------------------------------------
local panel = Instance.new("Frame")
panel.Visible = false
panel.Size = UDim2.new(0.3, 0, 0.5, 0) -- Slightly wider for fingers
panel.Position = UDim2.new(0.02, 0, 0.25, 0)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)
addStroke(panel, Color3.fromRGB(100, 100, 255), 2)
makeDraggable(panel)

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

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0.2, 0, 1, 0)
minBtn.Position = UDim2.new(0.8, 0, 0, 0)
minBtn.BackgroundTransparency = 1
minBtn.Text = "-"
minBtn.TextScaled = true
minBtn.Font = Enum.Font.GothamBold
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.Parent = titleBar

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 0.9, 0)
scrollFrame.Position = UDim2.new(0, 0, 0.1, 0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 6
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scrollFrame

local function makeButton(text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.9, 0, 0.09, 0)
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

local flyBtn = makeButton("Fly OFF")
local noclipBtn = makeButton("Noclip OFF")
local immortalBtn = makeButton("Immortal OFF")
local infJumpBtn = makeButton("Inf Jump OFF")
local espBtn = makeButton("Player ESP OFF")

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0.9, 0, 0.09, 0)
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
walkBox.Size = UDim2.new(0.9, 0, 0.09, 0)
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
-- MOBILE FLY BUTTONS
------------------------------------------------
local flyUpBtn = Instance.new("TextButton")
flyUpBtn.Visible = false
flyUpBtn.Size = UDim2.new(0.15, 0, 0.15, 0)
flyUpBtn.Position = UDim2.new(0.8, 0, 0.5, 0)
flyUpBtn.Text = "UP"
flyUpBtn.TextScaled = true
flyUpBtn.Font = Enum.Font.GothamBold
flyUpBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
flyUpBtn.TextColor3 = Color3.new(1,1,1)
flyUpBtn.Parent = gui
Instance.new("UICorner", flyUpBtn).CornerRadius = UDim.new(0, 8)
addStroke(flyUpBtn, Color3.fromRGB(100, 100, 255), 2)

local flyDownBtn = Instance.new("TextButton")
flyDownBtn.Visible = false
flyDownBtn.Size = UDim2.new(0.15, 0, 0.15, 0)
flyDownBtn.Position = UDim2.new(0.8, 0, 0.7, 0)
flyDownBtn.Text = "DOWN"
flyDownBtn.TextScaled = true
flyDownBtn.Font = Enum.Font.GothamBold
flyDownBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
flyDownBtn.TextColor3 = Color3.new(1,1,1)
flyDownBtn.Parent = gui
Instance.new("UICorner", flyDownBtn).CornerRadius = UDim.new(0, 8)
addStroke(flyDownBtn, Color3.fromRGB(100, 100, 255), 2)

flyUpBtn.MouseButton1Down:Connect(function() holdingUp = true end)
flyUpBtn.MouseButton1Up:Connect(function() holdingUp = false end)
flyUpBtn.MouseLeave:Connect(function() holdingUp = false end)

flyDownBtn.MouseButton1Down:Connect(function() holdingDown = true end)
flyDownBtn.MouseButton1Up:Connect(function() holdingDown = false end)
flyDownBtn.MouseLeave:Connect(function() holdingDown = false end)

------------------------------------------------
-- CHECKPOINT MANAGER UI
------------------------------------------------
local cpManager = Instance.new("Frame")
cpManager.Visible = false
cpManager.Size = UDim2.new(0.25, 0, 0.4, 0)
cpManager.Position = UDim2.new(0.02, 0, 0.78, 0) -- Bottom left
cpManager.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
cpManager.Parent = gui
Instance.new("UICorner", cpManager).CornerRadius = UDim.new(0, 12)
addStroke(cpManager, Color3.fromRGB(100, 255, 100), 2)
makeDraggable(cpManager)

local cpTitle = Instance.new("TextLabel")
cpTitle.Size = UDim2.new(1, 0, 0.12, 0)
cpTitle.BackgroundTransparency = 1
cpTitle.Text = "CHECKPOINTS"
cpTitle.TextScaled = true
cpTitle.Font = Enum.Font.GothamBlack
cpTitle.TextColor3 = Color3.fromRGB(100, 255, 150)
cpTitle.Parent = cpManager

local cpInput = Instance.new("TextBox")
cpInput.Size = UDim2.new(0.9, 0, 0.12, 0)
cpInput.Position = UDim2.new(0.05, 0, 0.15, 0)
cpInput.PlaceholderText = "CP Name (e.g. Base)"
cpInput.Text = ""
cpInput.TextScaled = true
cpInput.Font = Enum.Font.GothamBold
cpInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
cpInput.TextColor3 = Color3.new(1,1,1)
cpInput.Parent = cpManager
Instance.new("UICorner", cpInput).CornerRadius = UDim.new(0, 8)
addStroke(cpInput, Color3.fromRGB(60, 60, 60), 1)

local saveCpBtn = Instance.new("TextButton")
saveCpBtn.Size = UDim2.new(0.45, 0, 0.12, 0)
saveCpBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
saveCpBtn.Text = "Save CP"
saveCpBtn.TextScaled = true
saveCpBtn.Font = Enum.Font.GothamBold
saveCpBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
saveCpBtn.TextColor3 = Color3.new(1,1,1)
saveCpBtn.Parent = cpManager
Instance.new("UICorner", saveCpBtn).CornerRadius = UDim.new(0, 8)
addStroke(saveCpBtn, Color3.fromRGB(50, 200, 50), 2)

local loadCpBtn = Instance.new("TextButton")
loadCpBtn.Size = UDim2.new(0.45, 0, 0.12, 0)
loadCpBtn.Position = UDim2.new(0.5, 0, 0.3, 0)
loadCpBtn.Text = "Load CP"
loadCpBtn.TextScaled = true
loadCpBtn.Font = Enum.Font.GothamBold
loadCpBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 120)
loadCpBtn.TextColor3 = Color3.new(1,1,1)
loadCpBtn.Parent = cpManager
Instance.new("UICorner", loadCpBtn).CornerRadius = UDim.new(0, 8)
addStroke(loadCpBtn, Color3.fromRGB(50, 100, 200), 2)

local cpListScroll = Instance.new("ScrollingFrame")
cpListScroll.Size = UDim2.new(0.9, 0, 0.4, 0)
cpListScroll.Position = UDim2.new(0.05, 0, 0.45, 0)
cpListScroll.BackgroundTransparency = 1
cpListScroll.ScrollBarThickness = 4
cpListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
cpListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
cpListScroll.Parent = cpManager

local cpLayout = Instance.new("UIListLayout")
cpLayout.Padding = UDim.new(0, 4)
cpLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
cpLayout.SortOrder = Enum.SortOrder.LayoutOrder
cpLayout.Parent = cpListScroll

local function refreshCpList()
    for _, child in pairs(cpListScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    for name, pos in pairs(savedCheckpoints) do
        -- Container for the CP button and delete button
        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(1, 0, 0, 30)
        itemFrame.BackgroundTransparency = 1
        itemFrame.Parent = cpListScroll
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.8, 0, 1, 0)
        btn.Position = UDim2.new(0, 0, 0, 0)
        btn.Text = "TP: "..name
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Parent = itemFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        -- Tap to teleport
        btn.MouseButton1Click:Connect(function()
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                notify("Teleported to: "..name, Color3.fromRGB(50, 255, 50))
            end
        end)
        
        -- Mobile-Friendly Delete Button (Red X)
        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0.18, 0, 1, 0)
        delBtn.Position = UDim2.new(0.82, 0, 0, 0)
        delBtn.Text = "X"
        delBtn.TextScaled = true
        delBtn.Font = Enum.Font.GothamBold
        delBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        delBtn.TextColor3 = Color3.new(1, 1, 1)
        delBtn.Parent = itemFrame
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 6)
        
        -- Tap to delete
        delBtn.MouseButton1Click:Connect(function()
            savedCheckpoints[name] = nil
            refreshCpList()
            notify("Deleted CP: "..name, Color3.fromRGB(255, 50, 50))
        end)
    end
end

------------------------------------------------
-- CLEANUP FUNCTION
------------------------------------------------
local function cleanup()
    isShuttingDown = true
    
    if flyConn then flyConn:Disconnect() end
    if noclipConn then noclipConn:Disconnect() end
    if immortalConn then immortalConn:Disconnect() end
    if espConn then espConn:Disconnect() end
    if infJumpConn then infJumpConn:Disconnect() end
    
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hum then
            hum.PlatformStand = false
            hum.WalkSpeed = 16
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        end
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                v.CanCollide = true
            end
        end
        local ff = char:FindFirstChild("AdminForceField")
        if ff then ff:Destroy() end
    end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            local hl = p.Character:FindFirstChild("ESPHighlight")
            if hl then hl:Destroy() end
        end
    end
    
    if gui then gui:Destroy() end
end

------------------------------------------------
-- LOGIC & CONNECTIONS
------------------------------------------------
local function enable()
    if lockBox then lockBox:Destroy() end
    panel.Visible = true
    cpManager.Visible = true
    unlocked = true
    notify("Panel Unlocked!", Color3.fromRGB(50, 255, 50))
end

local function check()
    if string.gsub(box.Text, "%s+", "") == KEY then
        enable()
    else
        notify("Wrong Key!", Color3.fromRGB(255, 50, 50))
    end
end

unlock.MouseButton1Click:Connect(check)
box.FocusLost:Connect(function(enter) if enter then check() end end)

closeLockBtn.MouseButton1Click:Connect(function()
    cleanup()
end)

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
            if isShuttingDown then return end
            timer.Text = "Trial: "..i.."s"
            task.wait(1)
        end
        cleanup()
    end)()
end)

-- Auto-Access Check
if AUTO_ACCESS[player.Name] then
    enable()
end

minBtn.MouseButton1Click:Connect(function()
    if panel.Size == UDim2.new(0.3, 0, 0.5, 0) then
        panel:TweenSize(UDim2.new(0.3, 0, 0.1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    else
        panel:TweenSize(UDim2.new(0.3, 0, 0.5, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    end
end)

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

flyBtn.MouseButton1Click:Connect(function()
    if not unlocked then return end
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRoo
