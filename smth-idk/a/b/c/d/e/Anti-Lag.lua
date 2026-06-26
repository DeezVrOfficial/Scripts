local debris = game:GetService("Debris")
local lighting = game:GetService("Lighting")
local players = game:GetService("Players")
local runService = game:GetService("RunService")

local maxDebrisTime = 5
local partLimitPerPlayer = 500
local maxParts = 5000
local physicsThrottle = Enum.PhysicsSimulationRate.Fixed240Hz

local function isPartOfPlayerCharacter(part)
    if part:IsDescendantOf(players) then
        return true
    end
    for _, player in pairs(players:GetPlayers()) do
        if player.Character and part:IsDescendantOf(player.Character) then
            return true
        end
    end
    return false
end

local function cleanUpUnanchoredParts()
    while true do
        wait(2)
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part.Anchored and not isPartOfPlayerCharacter(part) then
                debris:AddItem(part, maxDebrisTime)
            end
        end
    end
end

local function limitPartCountForPlayers()
    while true do
        wait(5)
        for _, player in pairs(players:GetPlayers()) do
            local totalParts = 0
            if player.Character and player.Character.Parent then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        totalParts = totalParts + 1
                    end
                end
            end
            if totalParts > partLimitPerPlayer then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and not isPartOfPlayerCharacter(part) then
                        debris:AddItem(part, maxDebrisTime)
                    end
                end
            end
        end
    end
end

local function limitGlobalPartCount()
    while true do
        wait(10)
        local totalParts = 0
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and not isPartOfPlayerCharacter(part) then
                totalParts = totalParts + 1
            end
        end

        if totalParts > maxParts then
            for _, part in pairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and not part.Anchored and not isPartOfPlayerCharacter(part) then
                    debris:AddItem(part, maxDebrisTime)
                end
            end
        end
    end
end

local function optimizeLighting()
    lighting.GlobalShadows = false
    lighting.ClockTime = 12
end

local function optimizePhysics()
    settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Default
    settings().Physics.AllowSleep = true
    runService.Stepped:Connect(function()
        settings().Physics.PhysicsSimulationRate = physicsThrottle
    end)
end

local function optimizeMemory()
    game:GetService("GarbageCollectorService"):RequestGarbageCollection()
end

local function startOptimization()
    spawn(cleanUpUnanchoredParts)   
    spawn(limitPartCountForPlayers)    
    spawn(limitGlobalPartCount)       
    optimizeLighting()       
    optimizePhysics() 
    optimizeMemory()
end

startOptimization()
