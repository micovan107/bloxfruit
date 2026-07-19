local Players = game:GetService("Players") 
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local function playSound(soundId)
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://"..soundId
        sound.Parent = SoundService
        sound:Play()
        sound.Ended:Connect(function() sound:Destroy() end)
    end)
end

if not getgenv().HubLoadedV32 then
    getgenv().HubLoadedV32 = true
    task.spawn(function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/vinh129150/hack/refs/heads/main/Bloxfruits.lua"))()
            task.wait(2) 
            if LocalPlayer.Character then
                local Combat = LocalPlayer.Character:FindFirstChild("Combat") or LocalPlayer.Backpack:FindFirstChild("Combat")
                if Combat then
                    Combat.Parent = nil
                    task.wait(0.5)
                    Combat.Parent = LocalPlayer.Character
                end
            end
        end)
    end)
end

task.spawn(function()
    RunService.Heartbeat:Connect(function()
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            end
        end)
    end)
end)

-- ==========================================
-- [PATCHED DATABASE] - TẢI DATA TỪ GITHUB (ANTI-CACHE)
-- ==========================================
local SmartQuestDatabase = {}
local MonsterPositions = {}

local function LoadCloudData()
    local cacheBuster = "?t=" .. tostring(math.random(1, 100000))

    -- 1. Tải Nhiệm vụ
    local success1, rawQuest = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/micovan107/bloxfruit/refs/heads/main/nhiemvusea1.json" .. cacheBuster)
    end)
    
    if success1 and rawQuest then
        local ok, data = pcall(function() return HttpService:JSONDecode(rawQuest) end)
        if ok then
            table.clear(SmartQuestDatabase)
            for _, item in ipairs(data) do
                table.insert(SmartQuestDatabase, {
                    Index = item.Index,
                    MinLevel = item.MinLevel,
                    MaxLevel = item.MaxLevel,
                    NPCName = item.NPCName,
                    NPCPosition = Vector3.new(item.NPCPos.X, item.NPCPos.Y, item.NPCPos.Z),
                    MonsterLv = item.MonsterLv,
                    QuestName = item.QuestName,
                    QuestIndex = item.QuestIndex,
                    MonsterRawName = item.MonsterRawName,
                    RealName = item.RealName,
                    IsBoss = item.IsBoss or false,
                    FallbackIndex = item.FallbackIndex
                })
            end
            print("[HỆ THỐNG] Đã load xong Database Nhiệm Vụ mới nhất!")
        else
            warn("[HỆ THỐNG] Lỗi phân tích cú pháp JSON Nhiệm vụ!")
        end
    else
        warn("[HỆ THỐNG] Không thể tải Database Nhiệm vụ từ GitHub!")
    end

    -- 2. Tải Vị trí bãi quái
    local success2, rawPos = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/micovan107/bloxfruit/refs/heads/main/vitrikhuquaisea1.json" .. cacheBuster)
    end)
    
    if success2 and rawPos then
        local ok, data = pcall(function() return HttpService:JSONDecode(rawPos) end)
        if ok then
            table.clear(MonsterPositions)
            for name, pos in pairs(data) do
                MonsterPositions[name] = Vector3.new(pos.X, pos.Y, pos.Z)
            end
            print("[HỆ THỐNG] Đã load xong Database Tọa Độ Quái mới nhất!")
        else
            warn("[HỆ THỐNG] Lỗi phân tích cú pháp JSON Tọa độ quái!")
        end
    else
        warn("[HỆ THỐNG] Không thể tải Database Tọa độ quái từ GitHub!")
    end
end

LoadCloudData()

-- ==========================================
-- LOGIC CỐT LÕI (CORE FUNCTIONS)
-- ==========================================

local function getPlayerLevel()
    if LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Level") then return LocalPlayer.Data.Level.Value end
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats and leaderstats:FindFirstChild("Level") then return leaderstats.Level.Value end
    return 1
end

local function isMonsterSpawned(rawName)
    if not rawName then return false end
    local enemiesFolder = Workspace:FindFirstChild("Enemies") or Workspace
    for _, obj in ipairs(enemiesFolder:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
            if string.find(string.lower(obj.Name), string.lower(rawName)) then 
                return true 
            end
        end
    end
    return false
end

local function getQuestByPlayerLevel()
    if #SmartQuestDatabase == 0 then return nil, false, nil end
    local myLevel = getPlayerLevel()
    local targetQuest = nil

    -- Tìm quest phù hợp với level
    for _, quest in ipairs(SmartQuestDatabase) do
        if myLevel >= quest.MinLevel and myLevel <= quest.MaxLevel then
            targetQuest = quest
            break
        end
    end

    if not targetQuest then 
        return SmartQuestDatabase[#SmartQuestDatabase], false, nil 
    end

    -- Xử lý an toàn cho Boss (Tìm theo Index thay vì vị trí mảng để tránh lỗi JSON)
    if targetQuest.IsBoss and not isMonsterSpawned(targetQuest.MonsterRawName) then
        if targetQuest.FallbackIndex then
            for _, fallbackQ in ipairs(SmartQuestDatabase) do
                if fallbackQ.Index == targetQuest.FallbackIndex then
                    return fallbackQ, true, targetQuest
                end
            end
        end
    end

    return targetQuest, false, nil
end

local function cleanMonsterName(name)
    if not name then return "" end
    local cleaned = string.gsub(name, "%s*%[Lv%.%s*%d+%s*%]", "")
    cleaned = string.gsub(cleaned, "%s*%[Boss%]", "")
    return (string.match(cleaned, "^%s*(.-)%s*$") or cleaned)
end

local function getBestTarget(targetLv, rawName)
    local enemiesFolder = Workspace:FindFirstChild("Enemies") or Workspace
    local targetPattern = "%[Lv%.%s*" .. tostring(targetLv) .. "%]"
    
    for _, obj in ipairs(enemiesFolder:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
            if string.find(obj.Name, targetPattern) or string.find(obj.Humanoid.DisplayName or "", targetPattern) or (rawName and string.find(string.lower(obj.Name), string.lower(rawName))) then
                return obj
            end
        end
    end
    return nil
end

-- ==========================================
-- GIAO DIỆN NGƯỜI DÙNG (GUI)
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Lil0darkie6RingsGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 260)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", MainFrame).Thickness = 2.5
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(0, 255, 170)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Text = "COMPASS RINGS V33 (PRO PATCH)"
Title.TextColor3 = Color3.fromRGB(0, 255, 170)
Title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Title.BackgroundTransparency = 0.5
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.85, 0, 0, 40)
ToggleButton.Position = UDim2.new(0.075, 0, 0.22, 0)
ToggleButton.Text = "AUTO QUEST: OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.Parent = MainFrame
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 8)

local DecreaseRadius = Instance.new("TextButton")
DecreaseRadius.Size = UDim2.new(0.2, 0, 0, 35)
DecreaseRadius.Position = UDim2.new(0.075, 0, 0.42, 0)
DecreaseRadius.Text = "<"
DecreaseRadius.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
DecreaseRadius.TextColor3 = Color3.fromRGB(0, 255, 170)
DecreaseRadius.Font = Enum.Font.GothamBlack
DecreaseRadius.TextSize = 20
DecreaseRadius.Parent = MainFrame
Instance.new("UICorner", DecreaseRadius).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", DecreaseRadius).Color = Color3.fromRGB(0, 255, 170)

local RadiusDisplay = Instance.new("TextLabel")
RadiusDisplay.Size = UDim2.new(0.41, 0, 0, 35)
RadiusDisplay.Position = UDim2.new(0.295, 0, 0.42, 0)
RadiusDisplay.Text = "Radius: 50"
RadiusDisplay.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
RadiusDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
RadiusDisplay.Font = Enum.Font.GothamBold
RadiusDisplay.TextSize = 13
RadiusDisplay.Parent = MainFrame
Instance.new("UICorner", RadiusDisplay).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", RadiusDisplay).Color = Color3.fromRGB(0, 255, 170)

local IncreaseRadius = Instance.new("TextButton")
IncreaseRadius.Size = UDim2.new(0.2, 0, 0, 35)
IncreaseRadius.Position = UDim2.new(0.725, 0, 0.42, 0)
IncreaseRadius.Text = ">"
IncreaseRadius.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
IncreaseRadius.TextColor3 = Color3.fromRGB(0, 255, 170)
IncreaseRadius.Font = Enum.Font.GothamBlack
IncreaseRadius.TextSize = 20
IncreaseRadius.Parent = MainFrame
Instance.new("UICorner", IncreaseRadius).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", IncreaseRadius).Color = Color3.fromRGB(0, 255, 170)

local LogLabel = Instance.new("TextLabel")
LogLabel.Size = UDim2.new(0.85, 0, 0, 50)
LogLabel.Position = UDim2.new(0.075, 0, 0.60, 0)
LogLabel.Text = "[HỆ THỐNG]\nSẵn sàng hoạt động."
LogLabel.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
LogLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
LogLabel.Font = Enum.Font.Code
LogLabel.TextSize = 11
LogLabel.TextWrapped = true
LogLabel.Parent = MainFrame
Instance.new("UICorner", LogLabel).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", LogLabel).Color = Color3.fromRGB(50, 50, 60)

local Watermark = Instance.new("TextLabel")
Watermark.Size = UDim2.new(1, 0, 0, 20)
Watermark.Position = UDim2.new(0, 0, 1, -25)
Watermark.Text = "By: Nguyen Tien Nam"
Watermark.TextColor3 = Color3.fromRGB(150, 150, 150)
Watermark.BackgroundTransparency = 1
Watermark.Font = Enum.Font.GothamMedium
Watermark.TextSize = 11
Watermark.Parent = MainFrame

-- ==========================================
-- LOGIC HÚT QUÁI (MAGNET & HOVER)
-- ==========================================

local radius = 50
local height = 100
local rotationSpeed = 0.5
local attractionStrength = 1000
local ringPartsEnabled = false
getgenv().CurrentTargetName = nil

RunService.Heartbeat:Connect(function()
    if not ringPartsEnabled or not getgenv().CurrentTargetName then return end
    local char = LocalPlayer.Character
    local humanoidRootPart = char and char:FindFirstChild("HumanoidRootPart")
    
    if humanoidRootPart then
        local center = humanoidRootPart.Position
        local targetName = getgenv().CurrentTargetName
        local enemiesFolder = Workspace:FindFirstChild("Enemies") or Workspace

        for _, obj in ipairs(enemiesFolder:GetChildren()) do
            if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                local modelName = obj.Name
                local cleanedName = cleanMonsterName(modelName)
                if string.lower(cleanedName) == string.lower(targetName) or string.find(string.lower(modelName), string.lower(targetName)) then
                    local monsterHRP = obj.HumanoidRootPart
                    monsterHRP.CanCollide = false
                    local pos = monsterHRP.Position
                    local dist = (Vector3.new(pos.X, center.Y, pos.Z) - center).Magnitude
                    if dist < 600 then
                        local angle = math.atan2(pos.Z - center.Z, pos.X - center.X)
                        local newAngle = angle + math.rad(rotationSpeed)
                        local targetPos = Vector3.new(
                            center.X + math.cos(newAngle) * math.min(radius, dist),
                            center.Y + (height * math.abs(math.sin((pos.Y - center.Y)/height))),
                            center.Z + math.sin(newAngle) * math.min(radius, dist)
                        )
                        monsterHRP.Velocity = (targetPos - monsterHRP.Position).Unit * attractionStrength
                    end
                end
            end
        end
    end
end)

local AutoQuestEnabled = false
local NoClipConnection = nil
local ForcePositionConnection = nil
local HoverConnection = nil 

local function isQuestActive()
    local mainGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Main")
    return (mainGui and mainGui:FindFirstChild("Quest") and mainGui.Quest.Visible) or false
end

local function startNoClip()
    if NoClipConnection then NoClipConnection:Disconnect() end
    NoClipConnection = RunService.Stepped:Connect(function()
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end

local function stopNoClip()
    if NoClipConnection then NoClipConnection:Disconnect() NoClipConnection = nil end
    if ForcePositionConnection then ForcePositionConnection:Disconnect() ForcePositionConnection = nil end
end

local function startHover()
    if HoverConnection then HoverConnection:Disconnect() end
    HoverConnection = RunService.RenderStepped:Connect(function()
        if ringPartsEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            hrp.Velocity = Vector3.new(hrp.Velocity.X, 25, hrp.Velocity.Z) 
        end
    end)
end

local function stopHover()
    if HoverConnection then HoverConnection:Disconnect() HoverConnection = nil end
end

local function tweenTo(targetPos)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local hrp = char.HumanoidRootPart
    local dist = (hrp.Position - targetPos).Magnitude
    
    if dist > 3 then
        startNoClip()
        local speed = 520 
        local tween = TweenService:Create(hrp, TweenInfo.new(dist / speed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
        tween:Play()
        while tween.PlaybackState == Enum.PlaybackState.Playing do
            if not AutoQuestEnabled then tween:Cancel() stopNoClip() return false end
            task.wait(0.1)
        end
    end
    stopNoClip()
    if char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0) end
    task.wait(0.5)
    return true
end

-- ==========================================
-- HỆ THỐNG ĐỔI QUEST THÔNG MINH (PATCHED)
-- ==========================================
local function startQuestLoop()
    task.spawn(function()
        while AutoQuestEnabled do
            local quest, isFallback, originalBossQuest = getQuestByPlayerLevel()
            if quest then
                getgenv().CurrentTargetName = quest.MonsterRawName
                
                -- KIỂM TRA ĐỔI QUEST
                if isQuestActive() then
                    local currentQuestName = ""
                    pcall(function()
                        currentQuestName = LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Text
                    end)
                    
                    if isFallback and not string.find(string.lower(currentQuestName), "commando") then
                        LogLabel.Text = "[HỆ THỐNG]\nHủy quest Boss chưa hồi sinh để cày quái thường..."
                        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest") end)
                        task.wait(0.5)
                    end
                end

                if isFallback and originalBossQuest then
                    LogLabel.Text = "[RADAR]\nBoss " .. originalBossQuest.RealName .. " chưa hồi sinh! Đổi target: " .. quest.RealName
                else
                    LogLabel.Text = "[RADAR]\nĐang khóa vùng quái: " .. quest.RealName
                end
                
                if isQuestActive() then
                    local bestMonsterModel = getBestTarget(quest.MonsterLv, quest.MonsterRawName)
                    if bestMonsterModel then
                        LogLabel.Text = "[RADAR]\nPhát hiện " .. cleanMonsterName(bestMonsterModel.Name) .. "! Tấn công..."
                        local monsterPos = bestMonsterModel.HumanoidRootPart.Position
                        if tweenTo(monsterPos) and AutoQuestEnabled then
                            ringPartsEnabled = true
                            startHover()
                            LogLabel.Text = "[RADAR]\nĐang hút và tiêu diệt mục tiêu!"
                        end
                    else
                        ringPartsEnabled = false
                        stopHover()
                        
                        local campPos = MonsterPositions[quest.MonsterRawName]
                        if campPos then
                            LogLabel.Text = "[RADAR]\nQuái chưa hồi sinh, ra bãi (".. quest.RealName ..") cắm cọc chờ..."
                            tweenTo(campPos + Vector3.new(0, 15, 0))
                        else
                            LogLabel.Text = "[RADAR]\nKhông có tọa độ bãi, bay về NPC đợi..."
                            tweenTo(quest.NPCPosition)
                        end
                    end
                else
                    ringPartsEnabled = false
                    stopHover()
                    LogLabel.Text = "[LA BÀN]\nDi chuyển tới NPC " .. quest.NPCName .. "..."
                    local targetNpcPos = quest.NPCPosition
                    if tweenTo(targetNpcPos + Vector3.new(0, 2, 0)) and AutoQuestEnabled then
                        LogLabel.Text = "[LA BÀN]\nNhận nhiệm vụ: " .. quest.RealName
                        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest") end)
                        task.wait(0.5)
                        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", quest.QuestName, quest.QuestIndex) end)
                        task.wait(1.5)
                    end
                end
            else
                LogLabel.Text = "[LỖI]\nData rỗng hoặc không tìm thấy đảo thích hợp!"
                ringPartsEnabled = false
                stopHover()
            end
            task.wait(2)
        end
        stopNoClip()
        stopHover()
        ringPartsEnabled = false
    end)
end

-- ==========================================
-- KẾT NỐI SỰ KIỆN NÚT BẤM (BUTTON EVENTS)
-- ==========================================

ToggleButton.MouseButton1Click:Connect(function()
    AutoQuestEnabled = not AutoQuestEnabled
    pcall(function() playSound("12221967") end)
    
    if AutoQuestEnabled then
        if #SmartQuestDatabase == 0 then
            LogLabel.Text = "[LỖI]\nChưa tải được Database! Kích hoạt lại Force Load..."
            LoadCloudData()
        end
        
        ToggleButton.Text = "AUTO QUEST: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        LogLabel.Text = "[HỆ THỐNG]\nRadar V33 Pro đã khởi động."
        startQuestLoop()
    else
        ToggleButton.Text = "AUTO QUEST: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        LogLabel.Text = "[HỆ THỐNG]\nĐã ngắt hệ thống chiến đấu."
        ringPartsEnabled = false
        stopNoClip()
        stopHover()
    end
end)

DecreaseRadius.MouseButton1Click:Connect(function()
    radius = math.max(0, radius - 5)
    RadiusDisplay.Text = "Radius: " .. radius
    pcall(function() playSound("12221967") end)
end)

IncreaseRadius.MouseButton1Click:Connect(function()
    radius = math.min(10000, radius + 5)
    RadiusDisplay.Text = "Radius: " .. radius
    pcall(function() playSound("12221967") end)
end)
