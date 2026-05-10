if _G.__caydexx_ts_unload then pcall(_G.__caydexx_ts_unload) end
_G.__caydexx_ts_unloaded = false

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local plr = Players.LocalPlayer

local fovEnabled = false
local fovValue = 70

local espEnabled  = false
local espName     = true
local espBox      = true
local espHealth   = true
local espDistance = true
local espWeapon   = false

local aimbotEnabled    = false
local aimbotWallcheck  = false
local aimbotFovCircle  = true
local aimbotFov        = 200
local aimbotDistance   = 500
local aimbotSmoothness = 10

local hitboxExpEnabled = false
local hitboxExpSize    = 5

local teamCheckEnabled = false

local noGrassEnabled    = false
local noShadowEnabled   = false
local fullBrightEnabled = false

local applyNoGrass, applyNoShadow

local menuOpen = true

local _DrawingOK = false
pcall(function()
    if Drawing and type(Drawing.new) == "function" then
        local t = Drawing.new("Square")
        if t then
            pcall(function() t.Visible = false end)
            pcall(function() t:Remove() end)
            _DrawingOK = true
        end
    end
end)

local function safeDrawing(kind)
    if _DrawingOK then
        local ok, obj = pcall(Drawing.new, kind)
        if ok and obj then return obj end
    end
    local stub = {}
    setmetatable(stub, {
        __index = function(_, k)
            if k == "Remove" or k == "Destroy" then return function() end end
            return nil
        end,
        __newindex = function(t, k, v) rawset(t, k, v) end,
    })
    return stub
end

local C = {
    BgMain        = Color3.fromRGB(20, 20, 23),
    BgGroupbox    = Color3.fromRGB(13, 13, 16),
    BgTab         = Color3.fromRGB(20, 20, 23),
    BgTabActive   = Color3.fromRGB(28, 28, 33),
    BgInput       = Color3.fromRGB(15, 15, 18),
    Border        = Color3.fromRGB(45, 45, 50),
    Accent        = Color3.fromRGB(220, 60, 90),
    AccentDim     = Color3.fromRGB(150, 40, 60),
    Text          = Color3.fromRGB(235, 235, 240),
    TextDim       = Color3.fromRGB(155, 155, 165),
    TextMuted     = Color3.fromRGB(95, 95, 105),
    ToggleOff     = Color3.fromRGB(35, 35, 40),
    SliderTrack   = Color3.fromRGB(30, 30, 35),
    SliderFill    = Color3.fromRGB(220, 60, 90),
}

local function isMobile()
    return UIS.TouchEnabled and not UIS.KeyboardEnabled and not UIS.MouseEnabled
end

local sg = Instance.new("ScreenGui")
sg.Name = "caydexx_ts"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.DisplayOrder = 999990

local function parentGui(gui)
    if type(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then gui.Parent = hui; return end
    end
    if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end
    local ok = pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if not ok then gui.Parent = plr:WaitForChild("PlayerGui") end
end
parentGui(sg)

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 520, 0, 380)
main.Position = UDim2.new(0.5, -260, 0.5, -190)
main.BackgroundColor3 = C.BgMain
main.BorderSizePixel = 0
main.Active = true
main.Parent = sg

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = C.Border
mainStroke.Thickness = 1
mainStroke.Parent = main

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 24)
titleBar.BackgroundColor3 = C.BgMain
titleBar.BorderSizePixel = 0
titleBar.Parent = main

local titleDivider = Instance.new("Frame")
titleDivider.Size = UDim2.new(1, 0, 0, 1)
titleDivider.Position = UDim2.new(0, 0, 1, 0)
titleDivider.BackgroundColor3 = C.Border
titleDivider.BorderSizePixel = 0
titleDivider.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -60, 1, 0)
titleText.Position = UDim2.new(0, 8, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "caydexx | Red VS Blue Tycoon"
titleText.Font = Enum.Font.SourceSansBold
titleText.TextSize = 13
titleText.TextColor3 = C.Text
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 18, 0, 18)
closeBtn.Position = UDim2.new(1, -22, 0.5, -9)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "\u{00D7}"
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = C.TextDim
closeBtn.AutoButtonColor = false
closeBtn.Parent = titleBar
closeBtn.MouseEnter:Connect(function() closeBtn.TextColor3 = C.Text end)
closeBtn.MouseLeave:Connect(function() closeBtn.TextColor3 = C.TextDim end)
closeBtn.MouseButton1Click:Connect(function()
    menuOpen = false
    main.Visible = false
end)

local dragging, dragStart, startPos = false, nil, nil
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 22)
tabBar.Position = UDim2.new(0, 0, 0, 24)
tabBar.BackgroundColor3 = C.BgMain
tabBar.BorderSizePixel = 0
tabBar.Parent = main

local tabDivider = Instance.new("Frame")
tabDivider.Size = UDim2.new(1, 0, 0, 1)
tabDivider.Position = UDim2.new(0, 0, 1, 0)
tabDivider.BackgroundColor3 = C.Border
tabDivider.BorderSizePixel = 0
tabDivider.Parent = tabBar

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -8, 1, 0)
tabContainer.Position = UDim2.new(0, 4, 0, 0)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = tabBar

local tabs = {}

local function selectTab(name)
    for n, t in pairs(tabs) do
        local active = (n == name)
        t.content.Visible = active
        t.btn.BackgroundColor3 = active and C.BgTabActive or C.BgTab
        t.btn.TextColor3 = active and C.Text or C.TextDim
        t.bottomLine.Visible = active
    end
end

local tabNames = {"Combat", "Visuals", "Other", "World"}
local tabBtnW = 72
for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, tabBtnW, 1, 1)
    btn.Position = UDim2.new(0, (i - 1) * tabBtnW, 0, 0)
    btn.BackgroundColor3 = C.BgTab
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.TextColor3 = C.TextDim
    btn.AutoButtonColor = false
    btn.Parent = tabContainer

    local sideL = Instance.new("Frame")
    sideL.Size = UDim2.new(0, 1, 1, 0)
    sideL.Position = UDim2.new(0, 0, 0, 0)
    sideL.BackgroundColor3 = C.Border
    sideL.BorderSizePixel = 0
    sideL.Parent = btn

    local sideR = Instance.new("Frame")
    sideR.Size = UDim2.new(0, 1, 1, 0)
    sideR.Position = UDim2.new(1, -1, 0, 0)
    sideR.BackgroundColor3 = C.Border
    sideR.BorderSizePixel = 0
    sideR.Parent = btn

    local bottomLine = Instance.new("Frame")
    bottomLine.Size = UDim2.new(1, 0, 0, 1)
    bottomLine.Position = UDim2.new(0, 0, 1, 0)
    bottomLine.BackgroundColor3 = C.BgTabActive
    bottomLine.BorderSizePixel = 0
    bottomLine.Visible = false
    bottomLine.Parent = btn

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -16, 1, -54)
    content.Position = UDim2.new(0, 8, 0, 50)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Parent = main

    tabs[name] = { btn = btn, content = content, bottomLine = bottomLine }
    btn.MouseButton1Click:Connect(function() selectTab(name) end)
    btn.MouseEnter:Connect(function()
        if not bottomLine.Visible then btn.BackgroundColor3 = C.BgTabActive end
    end)
    btn.MouseLeave:Connect(function()
        if not bottomLine.Visible then btn.BackgroundColor3 = C.BgTab end
    end)
end

local function makeGroupbox(parent, side, title)
    local f = Instance.new("Frame")
    if side == "left" then
        f.Size = UDim2.new(0.5, -4, 1, 0)
        f.Position = UDim2.new(0, 0, 0, 0)
    else
        f.Size = UDim2.new(0.5, -4, 1, 0)
        f.Position = UDim2.new(0.5, 4, 0, 0)
    end
    f.BackgroundColor3 = C.BgGroupbox
    f.BorderSizePixel = 0
    f.Parent = parent

    local stroke = Instance.new("UIStroke")
    stroke.Color = C.Border
    stroke.Thickness = 1
    stroke.Parent = f

    if title and title ~= "" then
        local hdr = Instance.new("TextLabel")
        hdr.Size = UDim2.new(1, -8, 0, 14)
        hdr.Position = UDim2.new(0, 6, 0, 4)
        hdr.BackgroundTransparency = 1
        hdr.Text = title
        hdr.Font = Enum.Font.SourceSansBold
        hdr.TextSize = 12
        hdr.TextColor3 = C.Accent
        hdr.TextXAlignment = Enum.TextXAlignment.Left
        hdr.Parent = f

        local hdrLine = Instance.new("Frame")
        hdrLine.Size = UDim2.new(1, -8, 0, 1)
        hdrLine.Position = UDim2.new(0, 4, 0, 20)
        hdrLine.BackgroundColor3 = C.Border
        hdrLine.BorderSizePixel = 0
        hdrLine.Parent = f
    end

    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, -10, 1, title and -28 or -10)
    list.Position = UDim2.new(0, 5, 0, title and 24 or 5)
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 2
    list.ScrollBarImageColor3 = C.Border
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.ScrollingDirection = Enum.ScrollingDirection.Y
    list.Parent = f

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = list

    return list
end

local function makeToggle(parent, label, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -4, 0, 18)
    f.BackgroundTransparency = 1
    f.Parent = parent

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 12, 0, 12)
    box.Position = UDim2.new(0, 0, 0.5, -6)
    box.BackgroundColor3 = default and C.Accent or C.ToggleOff
    box.BorderSizePixel = 0
    box.Parent = f

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = default and C.Accent or C.Border
    boxStroke.Thickness = 1
    boxStroke.Parent = box

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 18, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 13
    lbl.TextColor3 = C.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = f

    local state = default
    local function set(v, fire)
        state = v
        box.BackgroundColor3 = v and C.Accent or C.ToggleOff
        boxStroke.Color = v and C.Accent or C.Border
        if fire ~= false then callback(v) end
    end
    btn.MouseButton1Click:Connect(function() set(not state) end)
    return { set = set, get = function() return state end }
end

local function makeSlider(parent, label, mn, mx, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -4, 0, 28)
    f.BackgroundTransparency = 1
    f.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 0, 14)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 13
    lbl.TextColor3 = C.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 50, 0, 14)
    valLbl.Position = UDim2.new(1, -50, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(default) .. "/" .. tostring(mx)
    valLbl.Font = Enum.Font.SourceSans
    valLbl.TextSize = 12
    valLbl.TextColor3 = C.TextDim
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = f

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 10)
    bar.Position = UDim2.new(0, 0, 0, 16)
    bar.BackgroundColor3 = C.SliderTrack
    bar.BorderSizePixel = 0
    bar.Parent = f

    local barStroke = Instance.new("UIStroke")
    barStroke.Color = C.Border
    barStroke.Thickness = 1
    barStroke.Parent = bar

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - mn) / (mx - mn), 0, 1, 0)
    fill.BackgroundColor3 = C.SliderFill
    fill.BorderSizePixel = 0
    fill.Parent = bar

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 4)
    btn.Position = UDim2.new(0, 0, 0, -2)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = bar

    local sliding = false
    local current = default
    local function applyValue(v, fire)
        current = v
        local frac = (v - mn) / (mx - mn)
        fill.Size = UDim2.new(frac, 0, 1, 0)
        valLbl.Text = tostring(v) .. "/" .. tostring(mx)
        if fire ~= false then callback(v) end
    end
    local function update(x, fire)
        local barAbs = bar.AbsolutePosition.X
        local barW = bar.AbsoluteSize.X
        if barW <= 0 then return end
        local frac = math.clamp((x - barAbs) / barW, 0, 1)
        local val = math.floor(mn + (mx - mn) * frac + 0.5)
        applyValue(val, fire)
    end

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            update(input.Position.X)
        end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input.Position.X)
        end
    end)

    return { set = function(v, fire) applyValue(math.clamp(v, mn, mx), fire) end, get = function() return current end }
end

selectTab("Combat")

local toggles = {}
local sliders = {}

local cbAim = makeGroupbox(tabs.Combat.content, "left", "aimbot")
toggles.aimbotEnabled    = makeToggle(cbAim, "enabled",    false, function(v) aimbotEnabled = v end)
toggles.aimbotWallcheck  = makeToggle(cbAim, "wall check", false, function(v) aimbotWallcheck = v end)
toggles.teamCheckEnabled = makeToggle(cbAim, "team check", false, function(v) teamCheckEnabled = v end)
toggles.aimbotFovCircle  = makeToggle(cbAim, "fov circle", true,  function(v) aimbotFovCircle = v end)
sliders.aimbotFov        = makeSlider(cbAim, "fov",         50,  500,  200, function(v) aimbotFov = v end)
sliders.aimbotDistance   = makeSlider(cbAim, "distance",    50, 1000,  500, function(v) aimbotDistance = v end)
sliders.aimbotSmoothness = makeSlider(cbAim, "smoothness",   1,  100,   10, function(v) aimbotSmoothness = v end)

local cbHit = makeGroupbox(tabs.Combat.content, "right", "hitbox expander")
toggles.hitboxExpEnabled = makeToggle(cbHit, "enabled", false, function(v) hitboxExpEnabled = v end)
sliders.hitboxExpSize    = makeSlider(cbHit, "size",    1, 30, 5, function(v) hitboxExpSize = v end)

local visEsp = makeGroupbox(tabs.Visuals.content, "left", "esp — players")
toggles.espEnabled  = makeToggle(visEsp, "enabled",  false, function(v) espEnabled = v end)
toggles.espName     = makeToggle(visEsp, "name",     true,  function(v) espName = v end)
toggles.espBox      = makeToggle(visEsp, "box",      true,  function(v) espBox = v end)
toggles.espHealth   = makeToggle(visEsp, "health",   true,  function(v) espHealth = v end)
toggles.espDistance = makeToggle(visEsp, "distance", true,  function(v) espDistance = v end)
toggles.espWeapon   = makeToggle(visEsp, "weapon",   false, function(v) espWeapon = v end)

local othCam = makeGroupbox(tabs.Other.content, "left", "camera")
toggles.fovEnabled = makeToggle(othCam, "fov override", false, function(v) fovEnabled = v end)
sliders.fovValue = makeSlider(othCam, "fov", 1, 120, 70, function(v) fovValue = v end)

local wldLight = makeGroupbox(tabs.World.content, "left", "lighting")
toggles.fullBrightEnabled = makeToggle(wldLight, "fullbright",  false, function(v) fullBrightEnabled = v end)
toggles.noShadowEnabled   = makeToggle(wldLight, "no shadow",   false, function(v) noShadowEnabled = v;   if applyNoShadow then applyNoShadow(v) end end)

local wldTerrain = makeGroupbox(tabs.World.content, "right", "terrain")
toggles.noGrassEnabled    = makeToggle(wldTerrain, "no grass",  false, function(v) noGrassEnabled = v;    if applyNoGrass  then applyNoGrass(v)  end end)

local mobileBtn = Instance.new("TextButton")
mobileBtn.Name = "MobileToggle"
mobileBtn.Size = UDim2.new(0, 44, 0, 44)
mobileBtn.Position = UDim2.new(0, 14, 0.5, -22)
mobileBtn.BackgroundColor3 = C.BgMain
mobileBtn.BorderSizePixel = 0
mobileBtn.Text = "C"
mobileBtn.TextColor3 = C.Accent
mobileBtn.Font = Enum.Font.SourceSansBold
mobileBtn.TextSize = 20
mobileBtn.AutoButtonColor = false
mobileBtn.Visible = isMobile()
mobileBtn.Parent = sg
local mbStroke = Instance.new("UIStroke") mbStroke.Color = C.Accent mbStroke.Thickness = 1 mbStroke.Parent = mobileBtn

local mbDragging, mbStart, mbStartPos, mbMoveDist = false, nil, nil, 0
mobileBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        mbDragging = true
        mbStart = input.Position
        mbStartPos = mobileBtn.Position
        mbMoveDist = 0
    end
end)
UIS.InputChanged:Connect(function(input)
    if mbDragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - mbStart
        mbMoveDist = delta.Magnitude
        mobileBtn.Position = UDim2.new(mbStartPos.X.Scale, mbStartPos.X.Offset + delta.X, mbStartPos.Y.Scale, mbStartPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if mbDragging and input.UserInputType == Enum.UserInputType.Touch then
        mbDragging = false
        if mbMoveDist < 6 then
            menuOpen = not menuOpen
            main.Visible = menuOpen
        end
    end
end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        menuOpen = not menuOpen
        main.Visible = menuOpen
    end
end)

main.Visible = menuOpen

local function getHead(char)
    if not char then return nil end
    return char:FindFirstChild("Head") or char:FindFirstChild("Top")
end

local function getHrp(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("Torso")
        or char:FindFirstChild("UpperTorso")
        or char:FindFirstChild("Middle")
end

local function getFoot(char)
    if not char then return nil end
    return char:FindFirstChild("LeftFoot") or char:FindFirstChild("RightFoot")
        or char:FindFirstChild("LeftLowerLeg") or char:FindFirstChild("RightLowerLeg")
        or char:FindFirstChild("Bottom")
end

local function iteratePlayers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr and p.Character then list[#list+1] = p end
    end
    return list
end

local function isTeammate(p)
    if not teamCheckEnabled then return false end
    if not p or p == plr then return false end
    if not plr.Team or not p.Team then return false end
    return p.Team == plr.Team
end

local function isSameTeam(p)
    if not p or p == plr then return false end
    if not plr.Team or not p.Team then return false end
    return p.Team == plr.Team
end

local CLR_WHITE  = Color3.fromRGB(255, 255, 255)
local CLR_YELLOW = Color3.fromRGB(255, 220, 100)
local CLR_BLACK  = Color3.fromRGB(0, 0, 0)
local CLR_HP_BG  = Color3.fromRGB(40, 40, 40)

local playerEspCache = {}

local function clearPlayerEspEntry(p)
    local e = playerEspCache[p]
    if not e then return end
    for _, k in ipairs({"name", "dist", "weapon", "boxT", "boxR", "boxB", "boxL", "hpBar", "hpBg"}) do
        if e[k] then pcall(function() e[k]:Remove() end) end
    end
    playerEspCache[p] = nil
end

local function clearAllPlayerEsp()
    for p in pairs(playerEspCache) do clearPlayerEspEntry(p) end
end

local function updatePlayerEsp()
    if not espEnabled then
        if next(playerEspCache) then clearAllPlayerEsp() end
        return
    end
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local lhrp = getHrp(plr.Character)
    local seen = {}
    for _, p in ipairs(iteratePlayers()) do
        if isTeammate(p) then clearPlayerEspEntry(p); continue end
        seen[p] = true
        local char = p.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health <= 0 then clearPlayerEspEntry(p); continue end
        local hrp = getHrp(char)
        local head = getHead(char) or hrp
        local foot = getFoot(char)
        if not hrp or not head then continue end

        local e = playerEspCache[p]
        if not e then e = {}; playerEspCache[p] = e end

        if not e.name   then e.name   = safeDrawing("Text"); e.name.Center = true; e.name.Outline = true; e.name.Size = 13; e.name.Font = 2; e.name.Color = CLR_WHITE end
        if not e.dist   then e.dist   = safeDrawing("Text"); e.dist.Center = true; e.dist.Outline = true; e.dist.Size = 12; e.dist.Font = 2; e.dist.Color = CLR_WHITE end
        if not e.weapon then e.weapon = safeDrawing("Text"); e.weapon.Center = true; e.weapon.Outline = true; e.weapon.Size = 12; e.weapon.Font = 2; e.weapon.Color = CLR_YELLOW end
        if not e.boxT   then e.boxT = safeDrawing("Line"); e.boxT.Color = CLR_WHITE; e.boxT.Thickness = 1 end
        if not e.boxR   then e.boxR = safeDrawing("Line"); e.boxR.Color = CLR_WHITE; e.boxR.Thickness = 1 end
        if not e.boxB   then e.boxB = safeDrawing("Line"); e.boxB.Color = CLR_WHITE; e.boxB.Thickness = 1 end
        if not e.boxL   then e.boxL = safeDrawing("Line"); e.boxL.Color = CLR_WHITE; e.boxL.Thickness = 1 end
        if not e.hpBar  then e.hpBar = safeDrawing("Line"); e.hpBar.Thickness = 3 end
        if not e.hpBg   then e.hpBg = safeDrawing("Line"); e.hpBg.Color = CLR_HP_BG; e.hpBg.Thickness = 3 end

        local headSp, onScreen = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.6, 0))
        local hrpSp = cam:WorldToViewportPoint(hrp.Position)
        local footPos = (foot and foot.Position) or (hrp.Position - Vector3.new(0, 3, 0))
        local footSp = cam:WorldToViewportPoint(footPos)

        if onScreen then
            local boxH = math.abs(footSp.Y - headSp.Y)
            local boxW = boxH * 0.55
            local cx = hrpSp.X
            local topY = headSp.Y
            local botY = footSp.Y
            local leftX = cx - boxW / 2
            local rightX = cx + boxW / 2

            if espBox then
                e.boxT.From = Vector2.new(leftX, topY); e.boxT.To = Vector2.new(rightX, topY); e.boxT.Visible = true
                e.boxR.From = Vector2.new(rightX, topY); e.boxR.To = Vector2.new(rightX, botY); e.boxR.Visible = true
                e.boxB.From = Vector2.new(leftX, botY); e.boxB.To = Vector2.new(rightX, botY); e.boxB.Visible = true
                e.boxL.From = Vector2.new(leftX, topY); e.boxL.To = Vector2.new(leftX, botY); e.boxL.Visible = true
            else
                e.boxT.Visible = false; e.boxR.Visible = false; e.boxB.Visible = false; e.boxL.Visible = false
            end

            if espHealth and hum then
                local hpPct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                e.hpBg.From = Vector2.new(leftX - 6, topY); e.hpBg.To = Vector2.new(leftX - 6, botY); e.hpBg.Visible = true
                e.hpBar.From = Vector2.new(leftX - 6, botY); e.hpBar.To = Vector2.new(leftX - 6, botY - boxH * hpPct)
                e.hpBar.Color = Color3.fromRGB(math.floor(255 * (1 - hpPct)), math.floor(255 * hpPct), 60)
                e.hpBar.Visible = true
            else
                e.hpBar.Visible = false; e.hpBg.Visible = false
            end

            if espName then
                e.name.Text = p.Name
                e.name.Position = Vector2.new(cx, topY - 18)
                e.name.Visible = true
            else e.name.Visible = false end

            if espDistance then
                local dd = lhrp and math.floor((lhrp.Position - hrp.Position).Magnitude) or 0
                e.dist.Text = dd .. "m"
                e.dist.Position = Vector2.new(cx, botY + 4)
                e.dist.Visible = true
            else e.dist.Visible = false end

            if espWeapon then
                local tool = char:FindFirstChildOfClass("Tool")
                e.weapon.Text = tool and tool.Name or ""
                e.weapon.Position = Vector2.new(cx, botY + 18)
                e.weapon.Visible = tool ~= nil
            else e.weapon.Visible = false end
        else
            e.name.Visible = false; e.dist.Visible = false; e.weapon.Visible = false
            e.boxT.Visible = false; e.boxR.Visible = false; e.boxB.Visible = false; e.boxL.Visible = false
            e.hpBar.Visible = false; e.hpBg.Visible = false
        end
    end
    for p in pairs(playerEspCache) do
        if not seen[p] then clearPlayerEspEntry(p) end
    end
end

local function isVisible(targetPart)
    local cam = Workspace.CurrentCamera
    if not cam or not targetPart then return false end
    local origin = cam.CFrame.Position
    local dir = (targetPart.Position - origin)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local exclude = {}
    if plr.Character then exclude[#exclude+1] = plr.Character end
    local cam_d = Workspace:FindFirstChild("Const")
    if cam_d then
        local ig = cam_d:FindFirstChild("Ignore")
        if ig then
            local fa = ig:FindFirstChild("FPSArms"); if fa then exclude[#exclude+1] = fa end
            local lc = ig:FindFirstChild("LocalCharacter"); if lc then exclude[#exclude+1] = lc end
        end
    end
    params.FilterDescendantsInstances = exclude
    local result = Workspace:Raycast(origin, dir, params)
    if not result then return true end
    return result.Instance and result.Instance:IsDescendantOf(targetPart.Parent)
end

local function findAimbotTarget()
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local lhrp = getHrp(plr.Character)
    if not lhrp then return nil end
    local screenCenter = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local bestTarget, bestScore = nil, math.huge
    for _, p in ipairs(iteratePlayers()) do
        if isTeammate(p) then continue end
        local char = p.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health > 0 then
                local head = getHead(char)
                if head then
                    local dist = (head.Position - lhrp.Position).Magnitude
                    if dist <= aimbotDistance then
                        local sp, onScreen = cam:WorldToViewportPoint(head.Position)
                        if onScreen and sp.Z > 0 then
                            local d2 = (Vector2.new(sp.X, sp.Y) - screenCenter).Magnitude
                            if d2 <= aimbotFov and d2 < bestScore then
                                if not aimbotWallcheck or isVisible(head) then
                                    bestScore = d2
                                    bestTarget = head
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

local function updateAimbot()
    if not aimbotEnabled then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local target = findAimbotTarget()
    if not target then return end
    local desired = CFrame.new(cam.CFrame.Position, target.Position)
    local alpha = math.clamp(1 / math.max(aimbotSmoothness, 1), 0, 1)
    cam.CFrame = cam.CFrame:Lerp(desired, alpha)
end

local fovCircle = nil
local function updateFovCircle()
    if not fovCircle then
        fovCircle = safeDrawing("Circle")
        fovCircle.NumSides = 64
        fovCircle.Filled = false
        fovCircle.Color = CLR_WHITE
        fovCircle.Thickness = 1
        fovCircle.Transparency = 1
    end
    if aimbotEnabled and aimbotFovCircle then
        local cam = Workspace.CurrentCamera
        if cam then
            fovCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
            fovCircle.Radius = aimbotFov
            fovCircle.Visible = true
        end
    else
        fovCircle.Visible = false
    end
end

local hitboxOriginals = {}

local function restoreHitboxFor(part)
    local orig = hitboxOriginals[part]
    if not orig then return end
    pcall(function()
        if part.Parent then
            part.Size         = orig.size
            part.Transparency = orig.transp
            part.CanCollide   = orig.cancol
            part.Massless     = orig.massless
        end
    end)
    hitboxOriginals[part] = nil
end

local function restoreAllHitboxes()
    for part in pairs(hitboxOriginals) do
        restoreHitboxFor(part)
    end
end

local function expandHitboxFor(part)
    if not part or not part:IsA("BasePart") or not part.Parent then return end
    if not hitboxOriginals[part] then
        hitboxOriginals[part] = {
            size     = part.Size,
            transp   = part.Transparency,
            cancol   = part.CanCollide,
            massless = part.Massless,
        }
    end
    local s = hitboxExpSize
    pcall(function()
        part.Size = Vector3.new(s, s, s)
        part.Transparency = 0.7
        part.CanCollide = false
        part.Massless = true
    end)
end

local function updateHitboxes()
    if not hitboxExpEnabled then
        if next(hitboxOriginals) then restoreAllHitboxes() end
        return
    end
    local touched = {}
    for _, p in ipairs(iteratePlayers()) do
        if not isSameTeam(p) then
            local char = p.Character
            local hrp = char and getHrp(char)
            if hrp then
                expandHitboxFor(hrp)
                touched[hrp] = true
            end
        end
    end
    for part in pairs(hitboxOriginals) do
        if not touched[part] then restoreHitboxFor(part) end
    end
end

local _defaultGrass = nil
do
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain and gethiddenproperty then
        local ok, val = pcall(gethiddenproperty, terrain, "Decoration")
        if ok then _defaultGrass = val else _defaultGrass = false end
    end
end

applyNoGrass = function(enable)
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if not terrain or not sethiddenproperty then return end
    if enable then
        pcall(sethiddenproperty, terrain, "Decoration", false)
    else
        pcall(sethiddenproperty, terrain, "Decoration", _defaultGrass and true or false)
    end
end

local _noShadowConn = nil
applyNoShadow = function(enable)
    if enable then
        if not _noShadowConn then
            _noShadowConn = RS.RenderStepped:Connect(function()
                if Lighting.GlobalShadows then
                    pcall(function() Lighting.GlobalShadows = false end)
                end
            end)
        end
    else
        if _noShadowConn then
            _noShadowConn:Disconnect()
            _noShadowConn = nil
        end
        pcall(function() Lighting.GlobalShadows = true end)
    end
end

local _fbOriginal = nil
local _fbAtmoOriginal = nil

local function applyFullBright()
    if not _fbOriginal then
        _fbOriginal = {
            Brightness            = Lighting.Brightness,
            Ambient               = Lighting.Ambient,
            OutdoorAmbient        = Lighting.OutdoorAmbient,
            GlobalShadows         = Lighting.GlobalShadows,
            FogEnd                = Lighting.FogEnd,
            FogStart              = Lighting.FogStart,
            FogColor              = Lighting.FogColor,
            ColorShift_Bottom     = Lighting.ColorShift_Bottom,
            ColorShift_Top        = Lighting.ColorShift_Top,
            ClockTime             = Lighting.ClockTime,
        }
    end
    pcall(function()
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        Lighting.ColorShift_Bottom = Color3.fromRGB(255, 255, 255)
        Lighting.ColorShift_Top = Color3.fromRGB(255, 255, 255)
        Lighting.ClockTime = 14
    end)
    local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
    if atmo and not _fbAtmoOriginal then
        _fbAtmoOriginal = {
            Density = atmo.Density,
            Offset  = atmo.Offset,
            Color   = atmo.Color,
            Decay   = atmo.Decay,
            Glare   = atmo.Glare,
            Haze    = atmo.Haze,
        }
    end
    if atmo then
        pcall(function()
            atmo.Density = 0
            atmo.Haze = 0
            atmo.Glare = 0
        end)
    end
end

local function restoreFullBright()
    if _fbOriginal then
        pcall(function()
            Lighting.Brightness = _fbOriginal.Brightness
            Lighting.Ambient = _fbOriginal.Ambient
            Lighting.OutdoorAmbient = _fbOriginal.OutdoorAmbient
            Lighting.GlobalShadows = _fbOriginal.GlobalShadows
            Lighting.FogEnd = _fbOriginal.FogEnd
            Lighting.FogStart = _fbOriginal.FogStart
            Lighting.FogColor = _fbOriginal.FogColor
            Lighting.ColorShift_Bottom = _fbOriginal.ColorShift_Bottom
            Lighting.ColorShift_Top = _fbOriginal.ColorShift_Top
            Lighting.ClockTime = _fbOriginal.ClockTime
        end)
        _fbOriginal = nil
    end
    local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
    if atmo and _fbAtmoOriginal then
        pcall(function()
            for k, v in pairs(_fbAtmoOriginal) do atmo[k] = v end
        end)
        _fbAtmoOriginal = nil
    end
end

RS.Heartbeat:Connect(function()
    if _G.__caydexx_ts_unloaded then return end
    if fullBrightEnabled then
        applyFullBright()
    elseif _fbOriginal or _fbAtmoOriginal then
        restoreFullBright()
    end
end)

RS.RenderStepped:Connect(function()
    if _G.__caydexx_ts_unloaded then return end
    pcall(updatePlayerEsp)
    pcall(updateAimbot)
    pcall(updateFovCircle)
    if fovEnabled then
        local cam = Workspace.CurrentCamera
        if cam then pcall(function() cam.FieldOfView = fovValue end) end
    end
end)

RS.Heartbeat:Connect(function()
    if _G.__caydexx_ts_unloaded then return end
    pcall(updateHitboxes)
end)

_G.__caydexx_ts_unload = function()
    if _G.__caydexx_ts_unloaded then return end
    _G.__caydexx_ts_unloaded = true

    fovEnabled = false
    espEnabled = false
    aimbotEnabled = false
    hitboxExpEnabled = false
    noGrassEnabled = false
    noShadowEnabled = false
    fullBrightEnabled = false

    clearAllPlayerEsp()
    restoreAllHitboxes()
    if fovCircle then pcall(function() fovCircle:Remove() end) end
    pcall(function() applyNoGrass(false) end)
    pcall(function() applyNoShadow(false) end)
    pcall(restoreFullBright)

    pcall(function() sg:Destroy() end)
end
