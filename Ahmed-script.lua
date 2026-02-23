------------------------------------------------
-- ADMIN PANEL GOD VERSION
------------------------------------------------

local Players=game:GetService("Players")
local RS=game:GetService("RunService")

local player=Players.LocalPlayer

if player:FindFirstChild("AdminBlocked") then return end

------------------------------------------------
-- SETTINGS
------------------------------------------------

local KEY="@hM3d_i$-The-Best"

local unlocked=false

local flying=false
local noclip=false
local immortal=false

local flySpeed=80

local flyConn
local noclipConn
local immortalConn

local checkpointPos=nil
local checkpointBeam=nil

------------------------------------------------
-- GUI
------------------------------------------------

local gui=Instance.new("ScreenGui",player.PlayerGui)
gui.ResetOnSpawn=false

------------------------------------------------
-- LOCK GUI
------------------------------------------------

local lock=Instance.new("Frame",gui)
lock.Size=UDim2.new(1,0,1,0)
lock.BackgroundColor3=Color3.fromRGB(15,15,15)

local box=Instance.new("TextBox",lock)
box.Size=UDim2.new(.4,0,.08,0)
box.Position=UDim2.new(.3,0,.4,0)
box.PlaceholderText="Enter Key"
box.TextScaled=true

local unlock=Instance.new("TextButton",lock)
unlock.Size=UDim2.new(.3,0,.08,0)
unlock.Position=UDim2.new(.35,0,.5,0)
unlock.Text="Unlock"

local trial=Instance.new("TextButton",lock)
trial.Size=UDim2.new(.3,0,.08,0)
trial.Position=UDim2.new(.35,0,.6,0)
trial.Text="Use 60 Seconds"

------------------------------------------------
-- ADMIN PANEL
------------------------------------------------

local panel=Instance.new("Frame",gui)

panel.Visible=false
panel.Size=UDim2.new(.32,0,.48,0)
panel.Position=UDim2.new(.02,0,.25,0)

panel.BackgroundColor3=Color3.fromRGB(35,35,35)

panel.Active=true
panel.Draggable=true

Instance.new("UICorner",panel).CornerRadius=UDim.new(0,12)

local title=Instance.new("TextLabel",panel)

title.Size=UDim2.new(1,0,.12,0)
title.BackgroundTransparency=1
title.Text="ADMIN PANEL"
title.TextScaled=true
title.TextColor3=Color3.new(1,1,1)

------------------------------------------------
-- BUTTON MAKER
------------------------------------------------

local y=.14

local function makeButton(text)

local b=Instance.new("TextButton",panel)

b.Size=UDim2.new(.9,0,.1,0)
b.Position=UDim2.new(.05,0,y,0)

b.TextScaled=true
b.Text=text

b.BackgroundColor3=Color3.fromRGB(65,65,65)

Instance.new("UICorner",b).CornerRadius=UDim.new(0,10)

y=y+.12

return b

end

------------------------------------------------
-- BUTTONS
------------------------------------------------

local flyBtn=makeButton("Fly OFF")
local noclipBtn=makeButton("Noclip OFF")
local immortalBtn=makeButton("Immortal OFF")

------------------------------------------------
-- FLY SPEED BOX
------------------------------------------------

local speedBox=Instance.new("TextBox",panel)

speedBox.Size=UDim2.new(.9,0,.1,0)
speedBox.Position=UDim2.new(.05,0,y,0)

speedBox.PlaceholderText="Fly Speed (80)"
speedBox.TextScaled=true

Instance.new("UICorner",speedBox)

y=y+.12

speedBox.FocusLost:Connect(function()

local n=tonumber(speedBox.Text)

if n then flySpeed=n end

end)

------------------------------------------------
-- DESTROY BUTTON
------------------------------------------------

local destroyBtn=makeButton("Destroy GUI")

------------------------------------------------
-- CP BUTTONS (LOCKED FIRST)
------------------------------------------------

local setCP=Instance.new("TextButton",gui)
setCP.Visible=false

setCP.Size=UDim2.new(.17,0,.07,0)
setCP.Position=UDim2.new(.8,0,.7,0)
setCP.Text="SET CP"

Instance.new("UICorner",setCP)

local tpCP=Instance.new("TextButton",gui)
tpCP.Visible=false

tpCP.Size=UDim2.new(.17,0,.07,0)
tpCP.Position=UDim2.new(.8,0,.8,0)
tpCP.Text="TP CP"

Instance.new("UICorner",tpCP)

------------------------------------------------
-- ENABLE PANEL
------------------------------------------------

local function enable()

lock:Destroy()

panel.Visible=true

setCP.Visible=true
tpCP.Visible=true

unlocked=true

end

------------------------------------------------
-- KEY
------------------------------------------------

local function check()

if string.gsub(box.Text,"%s+","")==KEY then
enable()
end

end

unlock.MouseButton1Click:Connect(check)

box.FocusLost:Connect(function(enter)
if enter then check() end
end)

------------------------------------------------
-- 60 SECOND TRIAL
------------------------------------------------

trial.MouseButton1Click:Connect(function()

enable()

local timer=Instance.new("TextLabel",gui)

timer.Size=UDim2.new(.3,0,.05,0)
timer.Position=UDim2.new(.35,0,.02,0)

for i=60,0,-1 do

timer.Text="Time "..i

task.wait(1)

end

Instance.new("BoolValue",player).Name="AdminBlocked"

gui:Destroy()

end)

------------------------------------------------
-- FLY
------------------------------------------------

flyBtn.MouseButton1Click:Connect(function()

if not unlocked then return end

local char=player.Character
local hum=char and char:FindFirstChildOfClass("Humanoid")
local hrp=char and char:FindFirstChild("HumanoidRootPart")

if not hum or not hrp then return end

flying=not flying

flyBtn.Text=flying and "Fly ON" or "Fly OFF"

if flying then

hum.PlatformStand=true

flyConn=RS.RenderStepped:Connect(function()

local move=hum.MoveDirection

local cam=workspace.CurrentCamera

local vel=Vector3.zero

if move.Magnitude>0 then
vel=cam.CFrame:VectorToWorldSpace(move)*flySpeed
end

if hum.Jump then
vel+=Vector3.new(0,flySpeed,0)
end

hrp.AssemblyLinearVelocity=vel

end)

else

hum.PlatformStand=false

if flyConn then flyConn:Disconnect() end

hrp.AssemblyLinearVelocity=Vector3.zero

end

end)

------------------------------------------------
-- NOCLIP
------------------------------------------------

noclipBtn.MouseButton1Click:Connect(function()

noclip=not noclip

noclipBtn.Text=noclip and "Noclip ON" or "Noclip OFF"

if noclip then

noclipConn=RS.Stepped:Connect(function()

local char=player.Character

if char then

for _,v in pairs(char:GetDescendants()) do
if v:IsA("BasePart") then
v.CanCollide=false
end
end

end

end)

else

if noclipConn then noclipConn:Disconnect() end

end

end)

------------------------------------------------
-- IMMORTAL
------------------------------------------------

immortalBtn.MouseButton1Click:Connect(function()

if not unlocked then return end

immortal=not immortal

immortalBtn.Text=immortal and "Immortal ON" or "Immortal OFF"

if immortal then

immortalConn=RS.Heartbeat:Connect(function()

local char=player.Character

if char then

local hum=char:FindFirstChildOfClass("Humanoid")

if hum then

hum.Health=hum.MaxHealth

end

end

end)

else

if immortalConn then immortalConn:Disconnect() end

end

end)

------------------------------------------------
-- CHECKPOINT BEAM
------------------------------------------------

local function createBeam(pos)

if checkpointBeam then
checkpointBeam:Destroy()
end

local base=Instance.new("Part",workspace)

base.Anchored=true
base.Transparency=1
base.CanCollide=false

base.Position=pos

local a0=Instance.new("Attachment",base)

local top=Instance.new("Part",workspace)

top.Anchored=true
top.Transparency=1
top.CanCollide=false

top.Position=pos+Vector3.new(0,30,0)

local a1=Instance.new("Attachment",top)

local beam=Instance.new("Beam")

beam.Attachment0=a0
beam.Attachment1=a1

beam.Width0=2
beam.Width1=2

beam.FaceCamera=true

beam.Color=ColorSequence.new(Color3.fromRGB(0,255,120))

beam.Parent=base

checkpointBeam=base

end

------------------------------------------------
-- SET CP
------------------------------------------------

setCP.MouseButton1Click:Connect(function()

local char=player.Character
local hrp=char and char:FindFirstChild("HumanoidRootPart")

if not hrp then return end

checkpointPos=hrp.Position

createBeam(checkpointPos)

end)

------------------------------------------------
-- TP CP
------------------------------------------------

tpCP.MouseButton1Click:Connect(function()

if not checkpointPos then return end

local char=player.Character
local hrp=char and char:FindFirstChild("HumanoidRootPart")

if not hrp then return end

local old=hrp.Position

hrp.CFrame=CFrame.new(checkpointPos+Vector3.new(0,3,0))

checkpointPos=old

createBeam(old)

end)

------------------------------------------------
-- DESTROY GUI
------------------------------------------------

destroyBtn.MouseButton1Click:Connect(function()

if flyConn then flyConn:Disconnect() end
if noclipConn then noclipConn:Disconnect() end
if immortalConn then immortalConn:Disconnect() end

local msg=Instance.new("TextLabel",gui)

msg.Size=UDim2.new(.4,0,.1,0)
msg.Position=UDim2.new(.3,0,.45,0)

msg.Text="Gui got destroyed"

task.wait(2)

gui:Destroy()

end)
