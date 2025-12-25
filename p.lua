-- Fish It! Winter Cavern Hub v6.0 | WindUI (MAX BLATANT ~700-900 fish/jam)
-- Delay super minimal, blatant ultra fast

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "FishIt Beta Version",
    Folder = "FishIt",
    IconSize = 44,
    HideSearchBar = false,
    OpenButton = { Enabled = true }
})

Window:Open()

Window:Tag({
    Title = "Beta Version",
    Icon = "zap",
    Color = Color3.fromHex("#30FF6A")
})

-- Services & Remotes (confirmed work Christmas Part 2 2025)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local netFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index")["sleitnick_net@0.2.0"].net
local ChargeRod = netFolder:WaitForChild("RF/ChargeFishingRod")
local RequestMinigame = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
local BaitSpawned = netFolder:WaitForChild("RE/BaitSpawned")
local FishingCompleted = netFolder:WaitForChild("RE/FishingCompleted")
local CancelInputs = netFolder:WaitForChild("RF/CancelFishingInputs")

-- Config
local EVENT_POS = Vector3.new(0, 0, 0)  -- Save deket Winter Cavern entrance
local ACTIVE_HOURS = {1,3,5,7,9,11,13,15,17,19,21,23}
local autoTP = false
local autoReturn = false
local autoFish = false
local humanize = false  -- Default OFF biar max speed
local tpDelay = 5
local baseFishDelay = 1.5  -- Default, blatant override ke lebih cepat
local savedPositions = {}
local selectedReturn = nil

local function tpTo(pos)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = CFrame.new(pos) end
end

local function isEventActive()
    local st = Workspace:GetServerTimeNow()
    local t = os.date("*t", st)
    return table.find(ACTIVE_HOURS, t.hour) and t.min < 30
end

local function notify(message, icon)
    WindUI:Notify({Title = "VyrenHub", Content = message, Icon = icon or "info", Duration = 5})
end

-- Auto Fishing MAX SPEED LOOP
task.spawn(function()
    while true do
        if autoFish and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                local currentDelay = baseFishDelay
                if blatantMode then currentDelay = math.random(6,8)/10 end  -- ~0.6-0.8 detik/cast = max stable

                ChargeRod:InvokeServer({os.clock()})
                task.wait(0)  -- Ultra minimal

                RequestMinigame:InvokeServer(1, 0, os.clock() + 0.01)
                task.wait(0.6)

                FishingCompleted:FireServer()
                if humanize then task.wait(math.random(1,5)/10) else task.wait(0.02) end

                CancelInputs:InvokeServer()
                task.wait(0)
                
                ChargeRod:InvokeServer({os.clock()})
                task.wait(0)  -- Ultra minimal

                RequestMinigame:InvokeServer(1, 0, os.clock() + 0.01)
                task.wait(0.6)

                FishingCompleted:FireServer()
                if humanize then task.wait(math.random(5,7)/10) else task.wait(0.02) end

                CancelInputs:InvokeServer()
                task.wait(0)
            end)
            task.wait(currentDelay)
        else
            task.wait(0)
        end
    end
end)

-- Event Loop (sama)
task.spawn(function()
    local wasActive = false
    while true do
        local active = isEventActive()
        
        if autoTP and active then tpTo(EVENT_POS) end
        
        if active ~= wasActive then
            if active then
                notify("🟢 WINTER CAVE PORTAL OPEN! Masuk cave & nyalain Auto Fish", "zap")
            else
                notify("🔴 Portal TUTUP.", "x")
                if autoReturn and selectedReturn and savedPositions[selectedReturn] then
                    tpTo(savedPositions[selectedReturn])
                    notify("Auto Return ke "..selectedReturn, "rocket")
                end
            end
        end
        
        wasActive = active
        task.wait(tpDelay)
    end
end)

-- UI (sama, tambah note)
local Tab = Window:Tab({Title = "VyrenHub", Icon = "snowflake"})

-- ... (Section Auto Fishing, Event, Position, Manual sama seperti v5.3)

local FishSec = Tab:Section({Title = "Auto Fishing 🎣"})
FishSec:Toggle({Title = "Auto Fish Instant", Value = false, Callback = function(v) autoFish = v notify(v and "🟢 ON" or "🔴 OFF", "fish") end})
FishSec:Toggle({Title = "Humanize Minimal", Value = false, Callback = function(v) humanize = v end})
FishSec:Slider({Title = "Base Delay (detik)", Value = {Min = 1, Max = 5, Default = 1.5}, Callback = function(v) baseFishDelay = v end})
