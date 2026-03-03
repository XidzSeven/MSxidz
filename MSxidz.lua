--[[
╔════════════════════════════════════════════════════════════╗
║   ULTIMATE TOOL - ALL IN ONE                              ║
║   Auto Cook | Click Delete | Distance Label               ║
║   Vehicle Teleport | Proximity Alert                      ║
╚════════════════════════════════════════════════════════════╝
]]

-- ================= SERVICES =================
local Players              = game:GetService("Players")
local TweenService         = game:GetService("TweenService")
local UserInputService     = game:GetService("UserInputService")
local RunService           = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player   = Players.LocalPlayer
local Camera   = workspace.CurrentCamera
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

-- ================= COLOR THEME =================
local C = {
    bg      = Color3.fromRGB(18, 18, 22),
    surface = Color3.fromRGB(28, 28, 34),
    primary = Color3.fromRGB(99, 102, 241),
    success = Color3.fromRGB(34, 197, 94),
    danger  = Color3.fromRGB(239, 68, 68),
    warning = Color3.fromRGB(255, 170, 0),
    text    = Color3.fromRGB(255, 255, 255),
    dim     = Color3.fromRGB(160, 160, 180),
}

-- ================= TWEEN =================
local tweenN = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local tweenF = TweenInfo.new(0.15, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out)

-- ================= MAIN GUI =================
local gui = Instance.new("ScreenGui")
gui.Name = "UltimateTool"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
    return c
end

local function glow(parent, color, layers)
    for i = 1, layers or 3 do
        local g = Instance.new("Frame")
        g.Size = UDim2.new(1, 8*i, 1, 8*i)
        g.Position = UDim2.new(0, -4*i, 0, -4*i)
        g.BackgroundColor3 = color
        g.BackgroundTransparency = 0.88
        g.BorderSizePixel = 0
        g.ZIndex = -i
        g.Parent = parent
        corner(g, 14 + (2*i))
    end
end

local function makeDrag(frame, handle)
    local dragging, dragStart, startPos = false, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and
           input.UserInputType ~= Enum.UserInputType.Touch then return end
        local d = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function makePanel(title, w, h, posX, posY, glowColor)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, w, 0, h)
    frame.Position = UDim2.new(0, posX, 0, posY)
    frame.BackgroundColor3 = C.bg
    frame.BackgroundTransparency = 0.05
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = gui
    corner(frame, 14)
    glow(frame, glowColor or C.primary)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 40)
    bar.BackgroundColor3 = C.surface
    bar.BackgroundTransparency = 0.2
    bar.BorderSizePixel = 0
    bar.Parent = frame
    corner(bar, 14)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -90, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = C.text
    titleLbl.TextSize = 13
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = bar

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 28, 0, 26)
    minBtn.Position = UDim2.new(1, -66, 0.5, -13)
    minBtn.BackgroundColor3 = Color3.fromRGB(180, 140, 20)
    minBtn.Text = "—"
    minBtn.TextColor3 = C.text
    minBtn.TextSize = 14
    minBtn.Font = Enum.Font.GothamBold
    minBtn.AutoButtonColor = false
    minBtn.Parent = bar
    corner(minBtn, 6)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 26)
    closeBtn.Position = UDim2.new(1, -34, 0.5, -13)
    closeBtn.BackgroundColor3 = C.danger
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = C.text
    closeBtn.TextSize = 13
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = bar
    corner(closeBtn, 6)

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -20, 1, -50)
    content.Position = UDim2.new(0, 10, 0, 45)
    content.BackgroundTransparency = 1
    content.Parent = frame

    -- Minimize logic
    local minimized = false
    local normalSize = UDim2.new(0, w, 0, h)
    local miniSize = UDim2.new(0, w, 0, 40)

    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        content.Visible = not minimized
        TweenService:Create(frame, tweenN, {Size = minimized and miniSize or normalSize}):Play()
        minBtn.Text = minimized and "▲" or "—"
    end)

    closeBtn.MouseButton1Click:Connect(function()
        frame.Visible = false
    end)

    makeDrag(frame, bar)

    return frame, content, bar
end

local function makeToggleBtn(parent, text, posY, colorOn, colorOff)
    colorOn = colorOn or C.success
    colorOff = colorOff or C.danger
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.Position = UDim2.new(0, 0, 0, posY)
    btn.BackgroundColor3 = colorOn
    btn.Text = text
    btn.TextColor3 = C.text
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = parent
    corner(btn, 8)
    return btn
end

local function makeSlider(parent, posY, minVal, maxVal, defaultVal, onChanged)
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 0, 8)
    bg.Position = UDim2.new(0, 0, 0, posY)
    bg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    bg.Parent = parent
    corner(bg, 10)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = C.primary
    fill.Parent = bg
    corner(fill, 10)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -8, 0.5, -8)
    knob.BackgroundColor3 = C.text
    knob.Parent = bg
    corner(knob, 10)

    local dragging = false
    local function update(input)
        local pct = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        local val = minVal + (maxVal - minVal) * pct
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -8, 0.5, -8)
        if onChanged then onChanged(val, pct) end
    end

    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then update(i) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    bg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then update(i) end
    end)

    return bg, fill, knob
end

local function label(parent, text, posY, size, color, font, alignX)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, size or 18)
    l.Position = UDim2.new(0, 0, 0, posY)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or C.dim
    l.TextSize = size or 12
    l.Font = font or Enum.Font.Gotham
    l.TextXAlignment = alignX or Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

-- ============================================================
-- MAIN MENU BUTTON
-- ============================================================

local menuBtn = Instance.new("TextButton")
menuBtn.Size = UDim2.new(0, 50, 0, 50)
menuBtn.Position = UDim2.new(0, 10, 0.5, -25)
menuBtn.BackgroundColor3 = C.primary
menuBtn.Text = "☰"
menuBtn.TextColor3 = C.text
menuBtn.TextSize = 24
menuBtn.Font = Enum.Font.GothamBold
menuBtn.AutoButtonColor = false
menuBtn.ZIndex = 10
menuBtn.Parent = gui
corner(menuBtn, 14)
glow(menuBtn, C.primary, 2)

-- Menu dropdown
local menuDropdown = Instance.new("Frame")
menuDropdown.Size = UDim2.new(0, 180, 0, 0)
menuDropdown.Position = UDim2.new(0, 65, 0.5, -25)
menuDropdown.BackgroundColor3 = C.surface
menuDropdown.BackgroundTransparency = 0.05
menuDropdown.BorderSizePixel = 0
menuDropdown.ClipsDescendants = true
menuDropdown.ZIndex = 10
menuDropdown.Parent = gui
corner(menuDropdown, 12)

local menuLayout = Instance.new("UIListLayout")
menuLayout.Padding = UDim.new(0, 4)
menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
menuLayout.Parent = menuDropdown

local menuPadding = Instance.new("UIPadding")
menuPadding.PaddingTop = UDim.new(0, 6)
menuPadding.PaddingBottom = UDim.new(0, 6)
menuPadding.PaddingLeft = UDim.new(0, 6)
menuPadding.PaddingRight = UDim.new(0, 6)
menuPadding.Parent = menuDropdown

local menuOpen = false
local menuItems = {
    {"🍳 Auto Cook",       C.success},
    {"🗑️ Click Delete",    C.danger},
    {"📏 Distance Label",  Color3.fromRGB(99, 200, 241)},
    {"🚗 Vehicle Teleport",Color3.fromRGB(241, 180, 99)},
    {"👁️ Proximity Alert", C.primary},
}

local menuBtns = {}
local panels = {}

for i, item in ipairs(menuItems) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = C.bg
    btn.Text = item[1]
    btn.TextColor3 = C.text
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.LayoutOrder = i
    btn.ZIndex = 10
    btn.Parent = menuDropdown
    corner(btn, 8)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, tweenF, {BackgroundColor3 = item[2]}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, tweenF, {BackgroundColor3 = C.bg}):Play()
    end)

    menuBtns[i] = btn
end

-- Toggle menu
menuBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    local targetH = menuOpen and (#menuItems * 40 + 16) or 0
    TweenService:Create(menuDropdown, tweenN, {Size = UDim2.new(0, 180, 0, targetH)}):Play()
    TweenService:Create(menuBtn, tweenF, {
        BackgroundColor3 = menuOpen and Color3.fromRGB(130, 133, 255) or C.primary
    }):Play()
end)

-- ============================================================
-- PANEL 1: AUTO COOK
-- ============================================================

local cookPanel, cookContent = makePanel("🍳 AUTO COOK", 300, 260, 260, 80, C.success)

local cookBtnToggle = makeToggleBtn(cookContent, "AUTO COOK : OFF", 0, C.success, C.danger)
cookBtnToggle.BackgroundColor3 = C.danger

local cookStatusCard = Instance.new("Frame")
cookStatusCard.Size = UDim2.new(1, 0, 0, 45)
cookStatusCard.Position = UDim2.new(0, 0, 0, 40)
cookStatusCard.BackgroundColor3 = C.surface
cookStatusCard.BackgroundTransparency = 0.3
cookStatusCard.Parent = cookContent
corner(cookStatusCard, 10)

local cookStatusLbl = label(cookStatusCard, "Status: Idle", 0, 14, C.text, Enum.Font.GothamBold)
cookStatusLbl.Size = UDim2.new(1, -10, 1, 0)
cookStatusLbl.Position = UDim2.new(0, 10, 0, 0)

local cookInvCard = Instance.new("Frame")
cookInvCard.Size = UDim2.new(1, 0, 0, 130)
cookInvCard.Position = UDim2.new(0, 0, 0, 95)
cookInvCard.BackgroundColor3 = C.surface
cookInvCard.BackgroundTransparency = 0.3
cookInvCard.Parent = cookContent
corner(cookInvCard, 10)

local invTitle = label(cookInvCard, "📦 INVENTORY", 8, 13, C.primary, Enum.Font.GothamBold)
invTitle.Position = UDim2.new(0, 10, 0, 8)

local cookInvLbl = Instance.new("TextLabel")
cookInvLbl.Size = UDim2.new(1, -20, 0, 90)
cookInvLbl.Position = UDim2.new(0, 10, 0, 30)
cookInvLbl.BackgroundTransparency = 1
cookInvLbl.Text = "Loading..."
cookInvLbl.TextColor3 = C.dim
cookInvLbl.TextSize = 13
cookInvLbl.Font = Enum.Font.Gotham
cookInvLbl.TextXAlignment = Enum.TextXAlignment.Left
cookInvLbl.TextYAlignment = Enum.TextYAlignment.Top
cookInvLbl.Parent = cookInvCard

-- Wait time sliders
-- Waktu masak (bisa desimal, edit di sini)
local waterTime   = 19.3   -- detik tunggu setelah Water
local gelatinTime = 43.3   -- detik tunggu setelah Gelatin

-- Cook Logic
local cookRunning = false
local currentPrompt = nil

ProximityPromptService.PromptShown:Connect(function(p) currentPrompt = p end)
ProximityPromptService.PromptHidden:Connect(function(p) if currentPrompt == p then currentPrompt = nil end end)

local function triggerPrompt()
    if currentPrompt then
        fireproximityprompt(currentPrompt, currentPrompt.HoldDuration)
        task.wait(0.5)
    end
end

local function countItem(name)
    local count = 0
    for _, item in pairs(player.Backpack:GetChildren()) do if item.Name == name then count += 1 end end
    if player.Character then
        for _, item in pairs(player.Character:GetChildren()) do if item.Name == name then count += 1 end end
    end
    return count
end

local function updateCookInv()
    cookInvLbl.Text = string.format("💧 Water: %d\n🍚 Sugar: %d\n🧪 Gelatin: %d\n👜 Empty Bag: %d",
        countItem("Water"), countItem("Sugar Block Bag"), countItem("Gelatin"), countItem("Empty Bag"))
end

local function setCookStatus(t) cookStatusLbl.Text = "Status: " .. t end

local function equipTool(name)
    if not player.Character then return false end
    local tool = player.Backpack:FindFirstChild(name) or player.Character:FindFirstChild(name)
    if tool and player.Character:FindFirstChild("Humanoid") then
        pcall(function() player.Character.Humanoid:EquipTool(tool) end)
        task.wait(0.5)
        return true
    end
    return false
end

local function waitCancel(secs)
    local elapsed = 0
    while elapsed < secs do
        if not cookRunning then return false end
        elapsed += 0.1
        setCookStatus(string.format("⏳ %.1f/%.1fs", elapsed, secs))
        task.wait(0.1)
    end
    return true
end

local function cookLoop()
    while cookRunning do
        if not equipTool("Water") then setCookStatus("❌ Water!"); break end
        triggerPrompt()
        if not waitCancel(waterTime) then break end
        if not equipTool("Sugar Block Bag") then setCookStatus("❌ Sugar!"); break end
        triggerPrompt()
        if not equipTool("Gelatin") then setCookStatus("❌ Gelatin!"); break end
        triggerPrompt()
        if not waitCancel(gelatinTime) then break end
        if not equipTool("Empty Bag") then setCookStatus("❌ Empty Bag!"); break end
        triggerPrompt()
        setCookStatus("🔄 Ulang...")
        task.wait(1)
    end
    setCookStatus("Idle")
    cookRunning = false
    cookBtnToggle.Text = "AUTO COOK : OFF"
    cookBtnToggle.BackgroundColor3 = C.danger
end

cookBtnToggle.MouseButton1Click:Connect(function()
    cookRunning = not cookRunning
    if cookRunning then
        cookBtnToggle.Text = "AUTO COOK : ON"
        cookBtnToggle.BackgroundColor3 = C.success
        setCookStatus("🚀 Mulai...")
        task.spawn(cookLoop)
    else
        cookBtnToggle.Text = "AUTO COOK : OFF"
        cookBtnToggle.BackgroundColor3 = C.danger
        setCookStatus("Idle")
    end
end)

player.Backpack.ChildAdded:Connect(updateCookInv)
player.Backpack.ChildRemoved:Connect(updateCookInv)
player.CharacterAdded:Connect(function() task.wait(1) updateCookInv() end)
task.spawn(function() while gui and gui.Parent do task.wait(5) updateCookInv() end end)
updateCookInv()
panels[1] = cookPanel

-- ============================================================
-- PANEL 2: CLICK DELETE
-- ============================================================

local delPanel, delContent = makePanel("🗑️ CLICK DELETE", 200, 100, 260, 80, C.danger)

local delEnabled = true
local lastClick = 0
local delToggle = makeToggleBtn(delContent, "✅ Delete: ON", 0, C.success, C.danger)

local delTooltip = label(delContent, IS_MOBILE and "📱 Tahan lalu tap objek" or "⌨️ ALT + Klik untuk hapus", 40, 11, C.dim)

delToggle.MouseButton1Click:Connect(function()
    delEnabled = not delEnabled
    delToggle.Text = delEnabled and "✅ Delete: ON" or "❌ Delete: OFF"
    delToggle.BackgroundColor3 = delEnabled and C.success or C.danger
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local valid = IS_MOBILE and input.UserInputType == Enum.UserInputType.Touch
        or (not IS_MOBILE and input.UserInputType == Enum.UserInputType.MouseButton1)
    if not valid or not delEnabled then return end
    if not (UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)) then return end
    if tick() - lastClick < 0.2 then return end
    lastClick = tick()
    local mp = UserInputService:GetMouseLocation()
    local ray = Camera:ViewportPointToRay(mp.X, mp.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {player.Character}
    local result = workspace:Raycast(ray.Origin, ray.Direction * 500, params)
    if result and result.Instance then pcall(function() result.Instance:Destroy() end) end
end)

panels[2] = delPanel

-- ============================================================
-- PANEL 3: DISTANCE LABEL
-- ============================================================

local distPanel, distContent = makePanel("📏 DISTANCE LABEL", 220, 170, 260, 80, Color3.fromRGB(99, 200, 241))

local distLabels = {}
local distEnabled = true
local DIST_MAX = 1000

local function getDistColor(d)
    if d < 20 then return C.danger
    elseif d < 50 then return C.warning
    else return C.success end
end

local function createDistLabel(p)
    if p == player or distLabels[p] then return end
    local char = p.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "DistLabel"
    bb.Size = UDim2.new(0, 120, 0, 40)
    bb.StudsOffset = Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = DIST_MAX
    bb.ResetOnSpawn = false
    bb.Enabled = distEnabled
    bb.Parent = head

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
    bg.BackgroundTransparency = 0.4
    bg.BorderSizePixel = 0
    bg.Parent = bb
    corner(bg, 8)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -8, 0, 18)
    nameLbl.Position = UDim2.new(0, 4, 0, 2)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = p.Name
    nameLbl.TextColor3 = C.text
    nameLbl.TextSize = 11
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    nameLbl.Parent = bg

    local dLbl = Instance.new("TextLabel")
    dLbl.Name = "DistText"
    dLbl.Size = UDim2.new(1, -8, 0, 16)
    dLbl.Position = UDim2.new(0, 4, 0, 20)
    dLbl.BackgroundTransparency = 1
    dLbl.Text = "📏 ..."
    dLbl.TextColor3 = C.success
    dLbl.TextSize = 11
    dLbl.Font = Enum.Font.GothamBold
    dLbl.TextTruncate = Enum.TextTruncate.AtEnd
    dLbl.Parent = bg

    distLabels[p] = {bb = bb, dLbl = dLbl}
end

local function removeDistLabel(p)
    if distLabels[p] then
        pcall(function() distLabels[p].bb:Destroy() end)
        distLabels[p] = nil
    end
end

local function setupDistPlayer(p)
    if p == player then return end
    if p.Character then createDistLabel(p) end
    p.CharacterAdded:Connect(function() task.wait(0.5) removeDistLabel(p) createDistLabel(p) end)
    p.CharacterRemoving:Connect(function() removeDistLabel(p) end)
end

for _, p in ipairs(Players:GetPlayers()) do setupDistPlayer(p) end
Players.PlayerAdded:Connect(setupDistPlayer)
Players.PlayerRemoving:Connect(removeDistLabel)

local distToggle = makeToggleBtn(distContent, "✅ Label: ON", 0, C.success, C.danger)

label(distContent, "Keterangan warna:", 42, 11, C.dim)
local legends = {{"🟢 Hijau → > 50m"}, {"🟡 Kuning → 20-50m"}, {"🔴 Merah → < 20m"}}
for i, l in ipairs(legends) do
    label(distContent, l[1], 42 + i * 16, 11, Color3.fromRGB(200, 200, 200))
end

distToggle.MouseButton1Click:Connect(function()
    distEnabled = not distEnabled
    distToggle.Text = distEnabled and "✅ Label: ON" or "❌ Label: OFF"
    distToggle.BackgroundColor3 = distEnabled and C.success or C.danger
    for _, data in pairs(distLabels) do
        if data and data.bb then data.bb.Enabled = distEnabled end
    end
end)

panels[3] = distPanel

-- ============================================================
-- PANEL 4: VEHICLE TELEPORT (DENGAN FITUR KE DIRI SENDIRI)
-- ============================================================

local vtPanel, vtContent = makePanel("🚗 VEHICLE TELEPORT", 320, 360, 260, 80, Color3.fromRGB(241, 180, 99))

local vtLocations = {
    { name = "TITIK 1 - GARASI APART",    pos = Vector3.new(1222.27, 4.35, -324.41) },
    { name = "TITIK 2 - PENJUAL MS",  pos = Vector3.new(510.92, 3.56, 582.41) },
    { name = "TITIK 3 - GunStore", pos = Vector3.new(-469.24, 3.86, 361.89) },
}
local vtOffset = Vector3.new(0, 2, 5)

-- Template nama kendaraan
local vtTemplates = {
    "XidzzWeLah's Car",
    "RiIIGood's Car",
    "Afz_Ganes28's Car",
}

label(vtContent, "📋 Template Kendaraan:", 0, 12, C.dim)

local vtTemplateBtns = {}
local templateColors = {
    Color3.fromRGB(80, 60, 180),
    Color3.fromRGB(60, 130, 80),
    Color3.fromRGB(160, 80, 40),
}
for i, tmpl in ipairs(vtTemplates) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.Position = UDim2.new(0, 0, 0, 14 + (i-1) * 30)
    btn.BackgroundColor3 = templateColors[i]
    btn.Text = "👤 " .. tmpl
    btn.TextColor3 = C.text
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.TextTruncate = Enum.TextTruncate.AtEnd
    btn.Parent = vtContent
    corner(btn, 6)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, tweenF, {BackgroundColor3 = templateColors[i]:lerp(Color3.new(1,1,1), 0.15)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, tweenF, {BackgroundColor3 = templateColors[i]}):Play()
    end)

    vtTemplateBtns[i] = btn
end

label(vtContent, "Atau ketik manual:", 106, 12, C.dim)

local vtBox = Instance.new("TextBox")
vtBox.Size = UDim2.new(1, 0, 0, 32)
vtBox.Position = UDim2.new(0, 0, 0, 122)
vtBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
vtBox.PlaceholderText = "Contoh: 'Lambo' atau 'Ferrari'"
vtBox.Text = ""
vtBox.TextColor3 = C.text
vtBox.PlaceholderColor3 = C.dim
vtBox.Font = Enum.Font.Gotham
vtBox.TextSize = 13
vtBox.ClearTextOnFocus = false
vtBox.Parent = vtContent
corner(vtBox, 6)

local vtResultLbl = label(vtContent, "Ketik nama kendaraan...", 158, 11, C.dim)

-- ================= TOMBOL TELEPORT KE 3 TITIK =================
local btnColors = {
    {Color3.fromRGB(50,100,200), Color3.fromRGB(70,130,255)},
    {Color3.fromRGB(100,150,50), Color3.fromRGB(130,190,60)},
    {Color3.fromRGB(200,100,50), Color3.fromRGB(255,130,60)},
}

local vtBtns = {}
for i = 1, 3 do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.3, -4, 0, 38)
    btn.Position = UDim2.new((i-1) * 0.35, 0, 0, 176)
    btn.BackgroundColor3 = btnColors[i][1]
    btn.Text = "📍 TITIK " .. i
    btn.TextColor3 = C.text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.Parent = vtContent
    corner(btn, 8)
    btn.MouseEnter:Connect(function() TweenService:Create(btn, tweenF, {BackgroundColor3 = btnColors[i][2]}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, tweenF, {BackgroundColor3 = btnColors[i][1]}):Play() end)
    vtBtns[i] = btn
end

-- ================= TOMBOL TELEPORT KE DIRI SENDIRI (BARU!) =================
local selfBtn = Instance.new("TextButton")
selfBtn.Size = UDim2.new(1, 0, 0, 38)
selfBtn.Position = UDim2.new(0, 0, 0, 222)
selfBtn.BackgroundColor3 = Color3.fromRGB(140, 80, 200)
selfBtn.Text = "📍 KE DIRI SENDIRI"
selfBtn.TextColor3 = C.text
selfBtn.Font = Enum.Font.GothamBold
selfBtn.TextSize = 12
selfBtn.AutoButtonColor = false
selfBtn.Parent = vtContent
corner(selfBtn, 8)
selfBtn.MouseEnter:Connect(function() TweenService:Create(selfBtn, tweenF, {BackgroundColor3 = Color3.fromRGB(170, 110, 230)}):Play() end)
selfBtn.MouseLeave:Connect(function() TweenService:Create(selfBtn, tweenF, {BackgroundColor3 = Color3.fromRGB(140, 80, 200)}):Play() end)

local vtStatusLbl = label(vtContent, "✅ Siap", 270, 12, C.success, Enum.Font.GothamBold)

-- Template click → isi textbox otomatis
for i, btn in ipairs(vtTemplateBtns) do
    btn.MouseButton1Click:Connect(function()
        vtBox.Text = vtTemplates[i]
        -- Highlight tombol yang dipilih
        for j, b in ipairs(vtTemplateBtns) do
            TweenService:Create(b, tweenF, {
                BackgroundColor3 = j == i and templateColors[j]:lerp(Color3.new(1,1,1), 0.3) or templateColors[j]
            }):Play()
        end
    end)
end

-- Fungsi cari kendaraan
local function vtFindVehicle(txt)
    if txt == "" then return nil end
    local char = player.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local lower = txt:lower()
    local results = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local n = obj.Name:lower()
            if n:find(lower, 1, true) then
                local vr = obj:FindFirstChild("VehicleSeat") or obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                if vr then
                    table.insert(results, {obj = obj, name = obj.Name, dist = (root.Position - vr.Position).Magnitude, score = #n - #lower})
                end
            end
        end
    end
    table.sort(results, function(a, b) return a.score == b.score and a.dist < b.dist or a.score < b.score end)
    return results
end

-- Update hasil pencarian
vtBox:GetPropertyChangedSignal("Text"):Connect(function()
    local txt = vtBox.Text
    if txt == "" then vtResultLbl.Text = "Ketik nama kendaraan..."; vtResultLbl.TextColor3 = C.dim; return end
    local r = vtFindVehicle(txt)
    if r and #r > 0 then
        local msg = "Ditemukan: "
        for i = 1, math.min(3, #r) do if i > 1 then msg = msg .. ", " end msg = msg .. r[i].name end
        if #r > 3 then msg = msg .. " (+" .. (#r-3) .. ")" end
        vtResultLbl.Text = msg; vtResultLbl.TextColor3 = C.success
    else
        vtResultLbl.Text = "❌ Tidak ditemukan: '" .. txt .. "'"; vtResultLbl.TextColor3 = C.danger
    end
end)

-- Fungsi teleport (dengan parameter target posisi)
local vtDebounce = false
local function vtTeleportTo(targetPos, targetName)
    if vtDebounce then return end
    vtDebounce = true
    
    local r = vtFindVehicle(vtBox.Text)
    if not r or #r == 0 then
        vtStatusLbl.Text = "❌ Kendaraan tidak ditemukan!"
        vtStatusLbl.TextColor3 = C.danger
        vtDebounce = false
        return
    end
    
    local v = r[1].obj
    local finalPos = targetPos + vtOffset
    local ok = pcall(function()
        if v.PrimaryPart then
            v:SetPrimaryPartCFrame(CFrame.new(finalPos))
        else
            for _, p in ipairs(v:GetChildren()) do
                if p:IsA("BasePart") then
                    p.CFrame = CFrame.new(finalPos)
                    break
                end
            end
        end
    end)
    
    vtStatusLbl.Text = ok and ("✅ " .. v.Name .. " → " .. targetName) or "❌ Gagal teleport!"
    vtStatusLbl.TextColor3 = ok and C.success or C.danger
    task.wait(1)
    vtDebounce = false
end

-- Event handler tombol 3 titik
for i = 1, 3 do
    vtBtns[i].MouseButton1Click:Connect(function()
        vtTeleportTo(vtLocations[i].pos, vtLocations[i].name)
    end)
end

-- Event handler tombol "Ke Diri Sendiri" (BARU!)
selfBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    if not char then
        vtStatusLbl.Text = "❌ Karakter tidak ditemukan!"
        vtStatusLbl.TextColor3 = C.danger
        return
    end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then
        vtStatusLbl.Text = "❌ Root part tidak ditemukan!"
        vtStatusLbl.TextColor3 = C.danger
        return
    end
    
    vtTeleportTo(root.Position, "POSISI LO")
end)

panels[4] = vtPanel

-- ============================================================
-- PANEL 5: PROXIMITY ALERT
-- ============================================================

local proxPanel, proxContent = makePanel("👁️ PROXIMITY ALERT", 250, 310, 260, 80, C.primary)

local PROX = {DetectRadius = 23, AlertCooldown = 3, MaxNotifs = 4, MaxRadius = 500}

-- Sound
local proxSound = Instance.new("Sound")
proxSound.SoundId = "rbxassetid://6042053626"
proxSound.Volume = 10
proxSound.Parent = workspace
task.spawn(function() if not proxSound.IsLoaded then proxSound.Loaded:Wait() end end)

local function playProxSound()
    pcall(function()
        if proxSound.IsLoaded then proxSound:Play()
        else
            local s = Instance.new("Sound"); s.SoundId = proxSound.SoundId; s.Volume = 0.5; s.Parent = workspace; s:Play()
            game:GetService("Debris"):AddItem(s, 3)
        end
    end)
end

-- World circle
local circleFolder = Instance.new("Folder")
circleFolder.Name = "ProximityCircle"
circleFolder.Parent = workspace

local circleParts = {}
local circleColor = C.primary

local function buildCircle()
    for _, p in ipairs(circleParts) do if p and p.Parent then p:Destroy() end end
    table.clear(circleParts)
    local segs = 300
    local angle = (2 * math.pi) / segs
    local len = 2 * PROX.DetectRadius * math.sin(angle / 2)
    for i = 1, segs do
        local part = Instance.new("Part")
        part.Size = Vector3.new(len, 0.2, 0.3)
        part.Anchored = true; part.CanCollide = false; part.CanQuery = false; part.CastShadow = false
        part.Material = Enum.Material.Neon; part.Color = circleColor; part.Transparency = 0.3
        part.Parent = circleFolder
        table.insert(circleParts, part)
    end
end

local function updateCircle()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local segs = #circleParts
    local angle = (2 * math.pi) / segs
    for i, part in ipairs(circleParts) do
        if not part or not part.Parent then continue end
        local a = angle * (i-1) + angle/2
        part.CFrame = CFrame.new(root.Position + Vector3.new(math.cos(a)*PROX.DetectRadius, -2.5, math.sin(a)*PROX.DetectRadius)) * CFrame.Angles(0, a + math.pi/2, 0)
    end
end

local function setCircleColor(col)
    circleColor = col
    for _, p in ipairs(circleParts) do if p and p.Parent then p.Color = col end end
end

local function setCircleVisible(v)
    for _, p in ipairs(circleParts) do if p and p.Parent then p.Transparency = v and 0.3 or 1 end end
end

buildCircle()

-- Notif container
local proxNotifContainer = Instance.new("Frame")
proxNotifContainer.Size = UDim2.new(0, 250, 1, -20)
proxNotifContainer.Position = UDim2.new(1, -260, 0, 10)
proxNotifContainer.BackgroundTransparency = 1
proxNotifContainer.Parent = gui
local proxNotifLayout = Instance.new("UIListLayout")
proxNotifLayout.Padding = UDim.new(0, 6)
proxNotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
proxNotifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
proxNotifLayout.Parent = proxNotifContainer

local function createProxNotif(name, dist)
    local existing = {}
    for _, c in ipairs(proxNotifContainer:GetChildren()) do if c:IsA("Frame") then table.insert(existing, c) end end
    if #existing >= PROX.MaxNotifs then existing[1]:Destroy() end

    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 52)
    notif.BackgroundColor3 = C.bg; notif.BackgroundTransparency = 0.1; notif.BorderSizePixel = 0
    notif.Position = UDim2.new(1.2, 0, 0, 0); notif.Parent = proxNotifContainer
    corner(notif, 10)

    local accent = Instance.new("Frame"); accent.Size = UDim2.new(0, 4, 1, -10); accent.Position = UDim2.new(0, 0, 0, 5)
    accent.BackgroundColor3 = C.danger; accent.BorderSizePixel = 0; accent.Parent = notif; corner(accent, 5)

    local icon = Instance.new("TextLabel"); icon.Size = UDim2.new(0, 35, 1, 0); icon.Position = UDim2.new(0, 8, 0, 0)
    icon.BackgroundTransparency = 1; icon.Text = "⚠️"; icon.TextSize = 20; icon.Font = Enum.Font.GothamBold; icon.Parent = notif

    local nl = Instance.new("TextLabel"); nl.Size = UDim2.new(1, -90, 0, 22); nl.Position = UDim2.new(0, 46, 0, 6)
    nl.BackgroundTransparency = 1; nl.Text = name .. " mendekat!"; nl.TextColor3 = C.text; nl.TextSize = 13
    nl.Font = Enum.Font.GothamBold; nl.TextXAlignment = Enum.TextXAlignment.Left; nl.TextTruncate = Enum.TextTruncate.AtEnd; nl.Parent = notif

    local dl = Instance.new("TextLabel"); dl.Size = UDim2.new(1, -90, 0, 18); dl.Position = UDim2.new(0, 46, 0, 28)
    dl.BackgroundTransparency = 1; dl.Text = string.format("📏 %.1f studs", dist); dl.TextColor3 = C.dim
    dl.TextSize = 11; dl.Font = Enum.Font.Gotham; dl.TextXAlignment = Enum.TextXAlignment.Left; dl.Parent = notif

    local tbg = Instance.new("Frame"); tbg.Size = UDim2.new(1, -10, 0, 3); tbg.Position = UDim2.new(0, 5, 1, -5)
    tbg.BackgroundColor3 = Color3.fromRGB(40,40,50); tbg.BorderSizePixel = 0; tbg.Parent = notif; corner(tbg, 5)
    local tfill = Instance.new("Frame"); tfill.Size = UDim2.new(1,0,1,0); tfill.BackgroundColor3 = C.danger
    tfill.BorderSizePixel = 0; tfill.Parent = tbg; corner(tfill, 5)

    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0,0)}):Play()
    TweenService:Create(tfill, TweenInfo.new(4, Enum.EasingStyle.Linear), {Size = UDim2.new(0,0,1,0)}):Play()
    task.delay(4, function()
        if not notif or not notif.Parent then return end
        local out = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1.2,0,0,0)})
        out:Play(); out.Completed:Connect(function() notif:Destroy() end)
    end)
end

-- Prox panel content
local proxAlertToggle = makeToggleBtn(proxContent, "✅ Deteksi: ON", 0, C.success, C.danger)
local proxCircleToggle = makeToggleBtn(proxContent, "⭕ Lingkaran: ON", 38, C.primary, Color3.fromRGB(60,60,80))
proxCircleToggle.BackgroundColor3 = C.primary
local proxSoundToggle = makeToggleBtn(proxContent, "🔊 Suara: ON", 76, C.surface, Color3.fromRGB(50,28,28))
proxSoundToggle.BackgroundColor3 = C.surface

label(proxContent, "📏 Radius Deteksi:", 118, 12, C.dim)
local proxRadiusVal = label(proxContent, PROX.DetectRadius .. " st", 118, 12, C.text, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
makeSlider(proxContent, 136, 0, PROX.MaxRadius, PROX.DetectRadius, function(val)
    PROX.DetectRadius = math.floor(val)
    proxRadiusVal.Text = PROX.DetectRadius .. " st"
    buildCircle()
end)

local proxNearbyLbl = label(proxContent, "👥 Pemain terdekat: 0", 154, 11, C.dim)
proxNearbyLbl.BackgroundColor3 = C.surface; proxNearbyLbl.BackgroundTransparency = 0.3
local _ = Instance.new("UICorner"); _.CornerRadius = UDim.new(0, 6); _.Parent = proxNearbyLbl

label(proxContent, "📏 Player terdekat:", 184, 11, C.dim)
local proxDistVal = label(proxContent, "— st", 184, 11, C.text, Enum.Font.GothamBold, Enum.TextXAlignment.Right)

local proxDistBg = Instance.new("Frame"); proxDistBg.Size = UDim2.new(1,0,0,12); proxDistBg.Position = UDim2.new(0,0,0,202)
proxDistBg.BackgroundColor3 = Color3.fromRGB(40,40,50); proxDistBg.Parent = proxContent; corner(proxDistBg, 10)
local proxDistFill = Instance.new("Frame"); proxDistFill.Size = UDim2.new(0,0,1,0)
proxDistFill.BackgroundColor3 = C.success; proxDistFill.Parent = proxDistBg; corner(proxDistFill, 10)

-- Prox toggles
local proxAlertOn = true
local proxCircleOn = true
local proxSoundOn  = true
local proxLastAlerted = {}

proxAlertToggle.MouseButton1Click:Connect(function()
    proxAlertOn = not proxAlertOn
    proxAlertToggle.Text = proxAlertOn and "✅ Deteksi: ON" or "❌ Deteksi: OFF"
    proxAlertToggle.BackgroundColor3 = proxAlertOn and C.success or C.danger
    setCircleVisible(proxAlertOn and proxCircleOn)
end)

proxCircleToggle.MouseButton1Click:Connect(function()
    proxCircleOn = not proxCircleOn
    proxCircleToggle.Text = proxCircleOn and "⭕ Lingkaran: ON" or "⭕ Lingkaran: OFF"
    proxCircleToggle.BackgroundColor3 = proxCircleOn and C.primary or Color3.fromRGB(60,60,80)
    setCircleVisible(proxCircleOn and proxAlertOn)
end)

proxSoundToggle.MouseButton1Click:Connect(function()
    proxSoundOn = not proxSoundOn
    proxSoundToggle.Text = proxSoundOn and "🔊 Suara: ON" or "🔇 Suara: OFF"
    proxSoundToggle.BackgroundColor3 = proxSoundOn and C.surface or Color3.fromRGB(50,28,28)
end)

panels[5] = proxPanel

-- ============================================================
-- MENU BUTTON CONNECTIONS
-- ============================================================

for i, btn in ipairs(menuBtns) do
    btn.MouseButton1Click:Connect(function()
        panels[i].Visible = not panels[i].Visible
        -- Tutup menu setelah pilih
        menuOpen = false
        TweenService:Create(menuDropdown, tweenN, {Size = UDim2.new(0, 180, 0, 0)}):Play()
        TweenService:Create(menuBtn, tweenF, {BackgroundColor3 = C.primary}):Play()
    end)
end

-- ============================================================
-- MAIN LOOP
-- ============================================================

local lastDistUpdate = 0

RunService.Heartbeat:Connect(function()
    -- Circle update
    if proxCircleOn and proxAlertOn then updateCircle() end

    -- Distance label update
    if tick() - lastDistUpdate > 0.1 then
        lastDistUpdate = tick()
        local myChar = player.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myRoot then
            -- Distance labels
            for p, data in pairs(distLabels) do
                if not data or not data.bb or not data.bb.Parent then distLabels[p] = nil; continue end
                local oc = p.Character
                if not oc then continue end
                local or2 = oc:FindFirstChild("HumanoidRootPart")
                if not or2 then continue end
                local d = (myRoot.Position - or2.Position).Magnitude
                data.dLbl.Text = "📏 " .. math.floor(d) .. " m"
                data.dLbl.TextColor3 = getDistColor(d)
            end

            -- Proximity detection
            if proxAlertOn then
                local nearbyCount = 0
                local closestDist = math.huge
                for _, p in ipairs(Players:GetPlayers()) do
                    if p == player then continue end
                    local oc = p.Character
                    if not oc then continue end
                    local or2 = oc:FindFirstChild("HumanoidRootPart")
                    if not or2 then continue end
                    local d = (myRoot.Position - or2.Position).Magnitude
                    if d < closestDist then closestDist = d end
                    if d <= PROX.DetectRadius then
                        nearbyCount += 1
                        local last = proxLastAlerted[p.Name]
                        if not last or (tick() - last) >= PROX.AlertCooldown then
                            proxLastAlerted[p.Name] = tick()
                            createProxNotif(p.Name, d)
                            if proxSoundOn then playProxSound() end
                        end
                    else
                        proxLastAlerted[p.Name] = nil
                    end
                end

                proxNearbyLbl.Text = "👥 Pemain terdekat: " .. nearbyCount
                setCircleColor(nearbyCount > 0 and C.danger or C.primary)

                if closestDist == math.huge then
                    proxDistVal.Text = "— st"
                    proxDistFill.Size = UDim2.new(0, 0, 1, 0)
                else
                    proxDistVal.Text = math.floor(closestDist) .. " st"
                    local pct = math.clamp(1 - (closestDist / PROX.MaxRadius), 0, 1)
                    TweenService:Create(proxDistFill, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {Size = UDim2.new(pct, 0, 1, 0)}):Play()
                    proxDistFill.BackgroundColor3 = closestDist > 100 and C.success or closestDist > 50 and C.warning or closestDist > 20 and Color3.fromRGB(239,130,68) or C.danger
                end
            end
        end
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    buildCircle()
    for _, p in ipairs(Players:GetPlayers()) do
        removeDistLabel(p)
        setupDistPlayer(p)
    end
end)

print("\n" .. ("="):rep(55))
print("🔥 ULTIMATE TOOL - ALL IN ONE LOADED!")
print(("="):rep(55))
print("☰  Klik tombol ☰ di kiri untuk buka menu")
print("🍳 Auto Cook     | 🗑️ Click Delete")
print("📏 Distance Label | 🚗 Vehicle Teleport")
print("👁️ Proximity Alert")
print(("="):rep(55))
