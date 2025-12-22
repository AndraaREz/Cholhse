-- Fish It! Winter Cavern TP Hub | WindUI v2.0 (Notifikasi Status!)
-- Print status diganti jadi WindUI Notify (popup toast)
-- Auto notify saat event aktif/tutup + saat return

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "Fish It Cavern TP ❄️",
    Folder = "FishItCavernTP",
    IconSize = 30,
    HideSearchBar = false,
    OpenButton = {
        Enabled = true
    }
})

Window:Open()

Window:Tag({
    Title = "Beta Testing",
    Icon = "zap",
    Color = Color3.fromHex("#30FF6A")
})

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- Config
local EVENT_POS = Vector3.new(577, -581, 8932)  -- Ganti kalau coord Winter Cavern beda
local ACTIVE_HOURS = {1,3,5,7,9,11,13,15,17,19,21,23}
local autoTP = false
local autoReturn = false
local tpDelay = 5
local savedPositions = {}
local selectedReturn = nil
local lastStatusNotified = nil  -- Biar gak spam notify tiap detik

-- TP Func
local function tpTo(pos)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(pos)
        return true
    end
    return false
end

-- Event Active?
local function isEventActive()
    local st = Workspace:GetServerTimeNow()
    local t = os.date("*t", st)
    return table.find(ACTIVE_HOURS, t.hour) and t.min < 30
end

-- Notify Status
local function notifyStatus(message, icon)
    WindUI:Notify({
        Title = "Christmast Cave Status",
        Content = message,
        Icon = icon or "info",
        Duration = 5
    })
end

-- Main Loop
task.spawn(function()
    local wasActive = false
    while true do
        local active = isEventActive()
        
        if autoTP and active then
            tpTo(EVENT_POS)
        end
        
        -- Detect change status & notify sekali aja
        if active ~= wasActive then
            if active then
                notifyStatus("🟢 Event Open!\nMasuk Cave Otomatis.", "zap")
            else
                notifyStatus("🔴 Event Closed\nSisa waktu habis.", "x")
                if autoReturn and selectedReturn and savedPositions[selectedReturn] then
                    tpTo(savedPositions[selectedReturn])
                    WindUI:Notify({
                        Title = "Auto Return",
                        Content = "Kembali ke '" .. selectedReturn .. "'",
                        Icon = "rocket",
                        Duration = 5
                    })
                end
            end
        end
        
        wasActive = active
        task.wait(tpDelay)
    end
end)

-- Tab
local Tab = Window:Tab({
    Title = "Christmast Cave",
    Icon = "snowflake"
})

-- Status & Auto Sec
local StatusSec = Tab:Section({
    Title = "Status & Auto TP"
})

StatusSec:Paragraph({
    Title = "Information:",
    Desc = "I have no information😹"
})

StatusSec:Toggle({
    Title = "Auto TP ke Cave",
    Desc = "Spam TP Saat Open",
    Value = false,
    Callback = function(v)
        autoTP = v
    end
})

StatusSec:Slider({
    Title = "Interval (Second/Detik)",
    Value = {Min = 3, Max = 30, Default = 5},
    Callback = function(v)
        tpDelay = v
    end
})

StatusSec:Button({
    Title = "TP ke Cavern",
    Callback = function()
        tpTo(EVENT_POS)
    end
})

StatusSec:Button({
    Title = "Click For Status Cave",
    Callback = function()
        local currentlyActive = isEventActive()
        
        if currentlyActive then
            notifyStatus("🟢 Event Open\nBisa Masuk Winter Cavern.", "zap")
        else
            notifyStatus("🔴 Event Closed\nTunggu 2Jam Berikutnya", "x")
        end
    end
})

-- Save & Return Sec
local SaveSec = Tab:Section({
    Title = "Save & Return Position"
})

SaveSec:Input({
    Title = "Save Position",
    Placeholder = "Your Position",
    Callback = function(name)
        if name ~= "" then
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                savedPositions[name] = hrp.Position
                WindUI:Notify({
                    Title = "Position Saved",
                    Content = "'" .. name .. "' disimpan!",
                    Icon = "check",
                    Duration = 5
                })
            end
        end
    end
})

local dropdown = SaveSec:Dropdown({
    Title = "Pilih Return Position",
    Values = {},
    Callback = function(choice)
        selectedReturn = choice
    end
})

task.spawn(function()
    while true do
        local items = {}
        for name in pairs(savedPositions) do
            table.insert(items, name)
        end
        dropdown:Refresh(items)
        task.wait(1)
    end
end)

SaveSec:Toggle({
    Title = "Auto Return Saat Event Tutup",
    Desc = "ON + Pilih Posisi = Kembali Ke Posisi Sebelumnya",
    Value = false,
    Callback = function(v)
        autoReturn = v
    end
})
