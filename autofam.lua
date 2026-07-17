-- [[ COMPASS RINGS V36 PRO MAX - SMART FALLBACK + FIX LOOP ]] --

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
-- [DATABASE]
-- ==========================================
local SmartQuestDatabase = {}
local MonsterPositions = {}

local function LoadCloudData()
    local cacheBuster = "?t=" .. tostring(math.random(1, 100000))

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
                    IsBoss = item.IsBoss or false
                })
            end
            print("[HỆ THỐNG] Đã load xong Database Nhiệm Vụ!")
        end
    end

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
            print("[HỆ THỐNG] Đã load xong Database Tọa Độ Quái!")
        end
    end
end

LoadCloudData()

-- ==========================================
-- CORE LOGIC & TÌM NHIỆM VỤ THÔNG MINH
-- ==========================================
local function getPlayerLevel()
    if LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Level") then return LocalPlayer.Data.Level.Value end
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats and leaderstats:FindFirstChild("Level") then return leaderstats.Level.Value end
    return 1
end

getgenv().FallbackCounter = getgenv().FallbackCounter or 0
local IntentionalAbandon = false 

-- Tự động mò nhiệm vụ thường cao nhất nếu Boss vắng mặt
local function getFallbackQuest(myLevel)
    local bestFallback = nil
    for _, q in ipairs(SmartQuestDatabase) do
        if myLevel >= q.MinLevel and not q.IsBoss then
            if not bestFallback or q.MinLevel > bestFallback.MinLevel then
                bestFallback = q
            end
        end
    end
    return bestFallback or SmartQuestDatabase[1]
end

local function getQuestByPlayerLevel()
    if #SmartQuestDatabase == 0 then return nil, false, nil end
    local myLevel = getPlayerLevel()
    local targetQuest = nil

    -- Nếu đang trong chế độ cày bù quái thường (FallbackCounter > 0)
    if getgenv().FallbackCounter > 0 then
        local fallback = getFallbackQuest(myLevel)
        return fallback, true, nil
    end

    -- Tìm nhiệm vụ đúng cấp độ
    for _, quest in ipairs(SmartQuestDatabase) do
        if myLevel >= quest.MinLevel and myLevel <= quest.MaxLevel then
            targetQuest = quest
            break
        end
    end

    if not targetQuest then return SmartQuestDatabase[#SmartQuestDatabase], false, nil end

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
-- GUI (Giao diện)
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
Title.Text = "RINGS V36 (SMART FALLBACK)"
Title.TextColor3 = Color3.fromRGB(0, 255, 170)
Title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Title.BackgroundTransparency = 0.5
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 14
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
LogLabel.Text = "[HỆ THỐNG]\nSẵn sàng."
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
Watermark.Text = "Fixed V36 by AI"
Watermark.TextColor3 = Color3.fromRGB(150, 150, 150)
Watermark.BackgroundTransparency = 1
Watermark.Font = Enum.Font.GothamMedium
Watermark.TextSize = 11
Watermark.Parent = MainFrame

-- ==========================================
-- HỆ THỐNG HÚT QUÁI
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

-- Dịch chuyển tức thời
local function tweenTo(targetPos)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local hrp = char.HumanoidRootPart
    
    startNoClip()
    hrp.CFrame = CFrame.new(targetPos)
    task.wait(0.08)
    stopNoClip()
    
    if char:FindFirstChild("HumanoidRootPart") then hrp.Velocity = Vector3.new(0, 0, 0) end
    return true
end

-- ==========================================
-- VÒNG LẶP CHÍNH (ĐÃ SỬA CHẶT CHẼ)
-- ==========================================
local function startQuestLoop()
    task.spawn(function()
        local lastQuestState = false
        
        while AutoQuestEnabled do
            local quest, isFallback, originalBossQuest = getQuestByPlayerLevel()
            
            if quest then
                getgenv().CurrentTargetName = quest.MonsterRawName
                local activeNow = isQuestActive()
                
                -- Khấu trừ bộ đếm khi hoàn thành nhiệm vụ thường
                if lastQuestState == true and activeNow == false then
                    if IntentionalAbandon then
                        IntentionalAbandon = false -- Reset cờ, bỏ qua đợt hủy này
                    else
                        if getgenv().FallbackCounter > 0 then
                            getgenv().FallbackCounter = getgenv().FallbackCounter - 1
                            LogLabel.Text = "[HỆ THỐNG]\nXong 1 Q thường. Còn lại: " .. getgenv().FallbackCounter
                        end
                    end
                end
                lastQuestState = activeNow
                
                if activeNow then
                    -- KIỂM TRA CHỐT CHẶN: Đang cầm nhiệm vụ gì trên màn hình?
                    local currentQuestName = ""
                    pcall(function() currentQuestName = LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Text end)
                    local targetClean = cleanMonsterName(quest.RealName)
                    
                    if currentQuestName ~= "" and not string.find(string.lower(currentQuestName), string.lower(targetClean)) then
                        LogLabel.Text = "[SAI QUEST]\nLệch nhiệm vụ! Đang hủy để nhận lại đúng..."
                        IntentionalAbandon = true
                        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest") end)
                        task.wait(1)
                        continue
                    end

                    local bestMonsterModel = getBestTarget(quest.MonsterLv, quest.MonsterRawName)
                    
                    if bestMonsterModel then
                        LogLabel.Text = "[FARM]\nĐập quái: " .. cleanMonsterName(bestMonsterModel.Name)
                        local monsterPos = bestMonsterModel.HumanoidRootPart.Position
                        if tweenTo(monsterPos) and AutoQuestEnabled then
                            ringPartsEnabled = true
                            startHover()
                        end
                    else
                        -- Không tìm thấy quái trong bãi
                        ringPartsEnabled = false
                        stopHover()
                        
                        -- Nếu là nhiệm vụ Boss
                        if quest.IsBoss then
                            local campPos = MonsterPositions[quest.MonsterRawName]
                            if campPos then
                                LogLabel.Text = "[CHECK BOSS]\nRa tận ổ quét Boss..."
                                tweenTo(campPos + Vector3.new(0, 20, 0))
                                task.wait(1) -- Tăng thời gian chờ load tí cho chắc chắn
                                
                                -- Kiểm tra lại xem Boss thực sự có mặt không
                                if not getBestTarget(quest.MonsterLv, quest.MonsterRawName) then
                                    LogLabel.Text = "[BOSS VẮNG]\nKhông thấy Boss! Chuyển cày 5 Q thường..."
                                    getgenv().FallbackCounter = 5 
                                    IntentionalAbandon = true
                                    
                                    -- HỦY NHIỆM VỤ BOSS NGAY LẬP TỨC
                                    pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest") end)
                                    task.wait(1)
                                    
                                    -- ÉP LẤY LẠI DATA NHIỆM VỤ THƯỜNG TRƯỚC KHI VÀO VÒNG LẶP TIẾP THEO
                                    quest = getFallbackQuest(getPlayerLevel())
                                    getgenv().CurrentTargetName = quest.MonsterRawName
                                end
                            end
                        else
                            -- Quái thường thì đứng chờ spawn
                            local campPos = MonsterPositions[quest.MonsterRawName]
                            if campPos then
                                tweenTo(campPos + Vector3.new(0, 15, 0))
                            end
                            task.wait(0.5)
                        end
                    end
                else
                    -- Đi nhận Quest
                    ringPartsEnabled = false
                    stopHover()
                    
                    local statusText = "[MOVE] Đi nhận nhiệm vụ..."
                    if getgenv().FallbackCounter > 0 then
                        statusText = "[FARM THƯỜNG]\nĐang cày chuỗi Q thường (Còn " .. getgenv().FallbackCounter .. ")"
                    end
                    LogLabel.Text = statusText
                    
                    if tweenTo(quest.NPCPosition) and AutoQuestEnabled then
                        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", quest.QuestName, quest.QuestIndex) end)
                        task.wait(0.8) -- Delay an toàn để máy chủ nhận dữ liệu nhiệm vụ
                    end
                end
            else
                LogLabel.Text = "[LỖI]\nData lỗi hoặc trống!"
                ringPartsEnabled = false
                stopHover()
            end
            task.wait(0.2)
        end
        stopNoClip()
        stopHover()
        ringPartsEnabled = false
    end)
end

-- ==========================================
-- SỰ KIỆN NÚT
-- ==========================================
ToggleButton.MouseButton1Click:Connect(function()
    AutoQuestEnabled = not AutoQuestEnabled
    pcall(function() playSound("12221967") end)
    
    if AutoQuestEnabled then
        if #SmartQuestDatabase == 0 then
            LoadCloudData()
        end
        ToggleButton.Text = "AUTO QUEST: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        LogLabel.Text = "[HỆ THỐNG]\nKhởi động V36 Pro Max."
        startQuestLoop()
    else
        ToggleButton.Text = "AUTO QUEST: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        LogLabel.Text = "[HỆ THỐNG]\nĐã tắt."
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
