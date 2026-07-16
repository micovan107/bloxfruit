-- [[ LÕI HỆ THỐNG: CHẠY NGẦM AUTO FARM LEVEL (KHÔNG GUI) ]]
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Đảm bảo không nạp chồng mã độc hoặc nạp trùng lặp bypass
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

-- Tối ưu hóa SimulationRadius để hút quái mượt hơn
task.spawn(function()
    RunService.Heartbeat:Connect(function()
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            end
        end)
    end)
end)

-- Cơ sở dữ liệu nhiệm vụ thông minh
local SmartQuestDatabase = {
    [1] = { MinLevel = 1,   MaxLevel = 9,   NPCName = "Bandit Recruiter", NPCPosition = Vector3.new(1059, 16, 1549),  MonsterLv = 5,   QuestName = "BanditQuest1",         QuestIndex = 1, MonsterRawName = "Bandit",          RealName = "Cướp" },
    [2] = { MinLevel = 10,  MaxLevel = 14,  NPCName = "Monkey Business",  NPCPosition = Vector3.new(-1598, 37, 153),   MonsterLv = 14,  QuestName = "JungleQuest",           QuestIndex = 1, MonsterRawName = "Monkey",          RealName = "Khỉ" },
    [3] = { MinLevel = 15,  MaxLevel = 29,  NPCName = "Monkey Business",  NPCPosition = Vector3.new(-1598, 37, 153),   MonsterLv = 20,  QuestName = "JungleQuest",           QuestIndex = 2, MonsterRawName = "Gorilla",         RealName = "Khỉ Đột" },
    [4] = { MinLevel = 30,  MaxLevel = 39,  NPCName = "Pirate Adventurer",NPCPosition = Vector3.new(-1146, 22, 3811),  MonsterLv = 35,  QuestName = "BuggyQuest1",           QuestIndex = 1, MonsterRawName = "Pirate",          RealName = "Hải Tặc" },
    [5] = { MinLevel = 40,  MaxLevel = 49,  NPCName = "Pirate Adventurer",NPCPosition = Vector3.new(-1146, 22, 3811),  MonsterLv = 45,  QuestName = "BuggyQuest1",           QuestIndex = 2, MonsterRawName = "Brute",           RealName = "Brute (Lính Cát)" },
    [6] = { MinLevel = 50,  MaxLevel = 59,  NPCName = "Pirate Adventurer",NPCPosition = Vector3.new(-1146, 22, 3811),  MonsterLv = 55,  QuestName = "BuggyQuest1",           QuestIndex = 3, MonsterRawName = "Chef",            RealName = "Đầu Bếp (Boss Chef)", IsBoss = true, FallbackIndex = 5 },
    [7] = { MinLevel = 60,  MaxLevel = 74,  NPCName = "Desert Adventurer",NPCPosition = Vector3.new(1094, 6, 4195),    MonsterLv = 60,  QuestName = "DesertQuest",           QuestIndex = 1, MonsterRawName = "Desert Bandit",   RealName = "Cướp Sa Mạc" },
    [8] = { MinLevel = 75,  MaxLevel = 89,  NPCName = "Desert Adventurer",NPCPosition = Vector3.new(1094, 6, 4195),    MonsterLv = 75,  QuestName = "DesertQuest",           QuestIndex = 2, MonsterRawName = "Desert Officer",  RealName = "Sĩ Quan Sa Mạc" },
    [9] = { MinLevel = 90,  MaxLevel = 119, NPCName = "Snow Adventurer",  NPCPosition = Vector3.new(1386, 87, -1298),  MonsterLv = 90,  QuestName = "SnowQuest",             QuestIndex = 1, MonsterRawName = "Snow Bandit",     RealName = "Cướp Tuyết" },
    [10] = { MinLevel = 120, MaxLevel = 149, NPCName = "Snow Adventurer",  NPCPosition = Vector3.new(1386, 87, -1298),  MonsterLv = 100, QuestName = "SnowQuest",             QuestIndex = 2, MonsterRawName = "Snowman",         RealName = "Người Tuyết" },
    [11] = { MinLevel = 150, MaxLevel = 189, NPCName = "Marine Commando",  NPCPosition = Vector3.new(-5036, 23, 4313),  MonsterLv = 150, QuestName = "MarineQuest",           QuestIndex = 1, MonsterRawName = "Scout",           RealName = "Trinh Sát Hải Quân" },
    [12] = { MinLevel = 190, MaxLevel = 249, NPCName = "Marine Commando",  NPCPosition = Vector3.new(-5036, 23, 4313),  MonsterLv = 175, QuestName = "MarineQuest",           QuestIndex = 2, MonsterRawName = "Chief Petty Officer", RealName = "Hạ Sĩ Quan" }
}

local function getPlayerLevel()
    if LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Level") then return LocalPlayer.Data.Level.Value end
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats and leaderstats:FindFirstChild("Level") then return leaderstats.Level.Value end
    return 1
end

local function isMonsterSpawned(targetLv, rawName)
    local targetPattern = "%[Lv%.%s*" .. tostring(targetLv) .. "%]"
    local enemiesFolder = Workspace:FindFirstChild("Enemies") or Workspace
    for _, obj in ipairs(enemiesFolder:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
            local modelName, dName = obj.Name, obj.Humanoid.DisplayName or ""
            if string.find(modelName, targetPattern) or string.find(dName, targetPattern) or (rawName and string.find(modelName, rawName)) then return true end
        end
    end
    return false
end

local function getQuestByPlayerLevel()
    local myLevel = getPlayerLevel()
    for index, quest in ipairs(SmartQuestDatabase) do
        if myLevel >= quest.MinLevel and myLevel <= quest.MaxLevel then
            if quest.IsBoss and not isMonsterSpawned(quest.MonsterLv, quest.MonsterRawName) then
                if quest.FallbackIndex and SmartQuestDatabase[quest.FallbackIndex] then
                    return SmartQuestDatabase[quest.FallbackIndex], true, quest
                end
            end
            return quest, false, nil
        end
    end
    return SmartQuestDatabase[#SmartQuestDatabase], false, nil
end

local function cleanMonsterName(name)
    if not name then return "" end
    local cleaned = string.gsub(name, "%s*%[Lv%.%s*%d+%s*%]", "")
    cleaned = string.gsub(cleaned, "%s*%[Boss%]", "")
    return (string.match(cleaned, "^%s*(.-)%s*$") or cleaned)
end

local function getBestTarget(targetLv, rawName)
    local enemiesFolder, targetPattern = Workspace:FindFirstChild("Enemies") or Workspace, "%[Lv%.%s*" .. tostring(targetLv) .. "%]"
    for _, obj in ipairs(enemiesFolder:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
            if string.find(obj.Name, targetPattern) or string.find(obj.Humanoid.DisplayName or "", targetPattern) or (rawName and string.find(obj.Name, rawName)) then
                return obj
            end
        end
    end
    return nil
end

-- Biến cấu hình chuyển động xoay
local radius = 50
local height = 100
local rotationSpeed = 0.5
local attractionStrength = 1000
local ringPartsEnabled = false
getgenv().CurrentTargetName = nil

-- Vòng lặp hút quái (Chỉ chạy khi getgenv().AutoFarmLevel hoạt động)
RunService.Heartbeat:Connect(function()
    if not getgenv().AutoFarmLevel or not ringPartsEnabled or not getgenv().CurrentTargetName then return end
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
        if getgenv().AutoFarmLevel and ringPartsEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
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
        local speed = 320 
        local tween = TweenService:Create(hrp, TweenInfo.new(dist / speed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
        tween:Play()
        while tween.PlaybackState == Enum.PlaybackState.Playing do
            if not getgenv().AutoFarmLevel then tween:Cancel() stopNoClip() return false end
            task.wait(0.1)
        end
    end
    stopNoClip()
    if char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0) end
    task.wait(0.5)
    return true
end

-- Vòng lặp điều khiển nhiệm vụ chính
task.spawn(function()
    while getgenv().AutoFarmLevel do
        local quest, isFallback, originalBossQuest = getQuestByPlayerLevel()
        if quest then
            getgenv().CurrentTargetName = quest.MonsterRawName
            
            if isQuestActive() then
                local bestMonsterModel = getBestTarget(quest.MonsterLv, quest.MonsterRawName)
                if bestMonsterModel then
                    local monsterPos = bestMonsterModel.HumanoidRootPart.Position
                    if tweenTo(monsterPos) and getgenv().AutoFarmLevel then
                        ringPartsEnabled = true
                        startHover()
                    end
                else
                    ringPartsEnabled = false
                    stopHover()
                    tweenTo(quest.NPCPosition)
                end
            else
                ringPartsEnabled = false
                stopHover()
                local targetNpcPos = quest.NPCPosition
                if tweenTo(targetNpcPos + Vector3.new(0, 2, 0)) and getgenv().AutoFarmLevel then
                    pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest") end)
                    task.wait(0.5)
                    pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", quest.QuestName, quest.QuestIndex) end)
                    task.wait(1.5)
                end
            end
        else
            ringPartsEnabled = false
            stopHover()
        end
        task.wait(2)
    end
    -- Dọn dẹp các tiến trình khi trạng thái AutoFarmLevel = false
    stopNoClip()
    stopHover()
    ringPartsEnabled = false
end)
