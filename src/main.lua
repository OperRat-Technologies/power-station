
-- Configuration
local readingTickInterval = 20
local psLimitAlarm = 5
local frequencyAlarm = 1015

-- Module imports
local term = require("term")
local component = require("component")
local gpu = component.gpu

component.redstone.setWirelessFrequency(frequencyAlarm)

local GregTechMachine = { }
GregTechMachine.new = function (proxy, inStr, outStr)
    local self = {}

    self.proxy = proxy
    self.sensorInfo = proxy.getSensorInformation()
    self.inStr = inStr
    self.outStr = outStr

    function self.searchSensorInformation(searchStr)
        for _, v in ipairs(self.sensorInfo) do
            if string.find(v, searchStr) then
                return v
            end
        end
        return ""
    end

    function self.updateSensorInfo()
        self.sensorInfo = proxy.getSensorInformation()
    end

    ---Clears colored strings
    ---@param str string
    ---@return string
    function self.clearSensorInformationString(str)
        local result, _ = string.gsub(str, "§.", "")
        return result
    end

    function self.extractNumberFromInformationString(str)
        local result = string.gsub(str, ",", "")
        local _, _, number = string.find(result, "(%d+)")
        return tonumber(number)
    end

    function self.getEUStored()
        return self.proxy.getEUStored()
    end
    
    function self.getEUCapacity()
        return self.proxy.getEUCapacity()
    end
    
    function self.getEUAverageInput()
        return self.extractNumberFromInformationString(self.clearSensorInformationString(self.searchSensorInformation(self.inStr)))
    end

    function self.getEUAverageOutput()
        return self.extractNumberFromInformationString(self.clearSensorInformationString(self.searchSensorInformation(self.outStr)))
    end
    
    return self
end

local substationProxy, lapotronicProxy

-- loop through all components in the system
for address, name in component.list() do
    -- filter only gregtech machines, as we need the substation and the supercapacitor
    if (string.find(name, "gt_machine")) then
        local proxy = component.proxy(address)
        local machineName = proxy.getName()

        if (string.find(machineName, "substation")) then
            substationProxy = proxy
        end

        if (string.find(machineName, "supercapacitor")) then
            lapotronicProxy = proxy
        end
    end
end

local substation = GregTechMachine.new(substationProxy, "Average Input", "Average Output")
local lapotronic = GregTechMachine.new(lapotronicProxy, "Avg EU IN", "Avg EU OUT")

---Style setup
local function setupScreen()
    gpu.setForeground(0x000000)
    gpu.setBackground(0xffffff)
    gpu.setResolution(80, 23)
    gpu.setViewport(80, 23)
end

local function printBanner()
    print("███▓▓▓▒▒▒░░░ ratOS » Power Station Control                                      ")
end

---Transforms a number into a "Scientific-like" notation, in the sense that values can actually be greater than 1, the limit is 1000
---@param n number
---@return number
---@return string
local function numToAdaptedScientificNotation(n)
    local exponents = {" ", "K", "M", "G", "T", "P", "E", "Z", "Y", "R", "Q"}
    local expId = 1
    while (n >= 1000) do
        expId = expId + 1
        n = n / 1000
    end
    return n, exponents[expId]
end

---Prints the capacity graphic, starting from the bottom
---@param capacity number
---@param storage number
---@param layers number
---@param topX number
---@param topY number
local function printCapacityGraphic(capacity, storage, layers, topX, topY)
    local lsPercentage = storage / capacity * 100
    local percentagePerLayer = 100 / layers

    local fillingC = {"▓", "▒", "░"}
    local fillingP = {0.66 * percentagePerLayer, 0.33 * percentagePerLayer, 0}

    local filledLayers = math.floor(lsPercentage / percentagePerLayer)
    gpu.fill(topX, topY + (layers - filledLayers), 5, filledLayers, "█")
    
    if (filledLayers < layers) then
        local curPercentage = lsPercentage - (filledLayers * percentagePerLayer)
        local fillingChar = "?"

        for i, v in ipairs(fillingP) do
            if (curPercentage >= v) then
                fillingChar = fillingC[i]
                break
            end
        end

        gpu.fill(topX, topY + (layers - filledLayers - 1), 5, 1, fillingChar)
    end
end

---Specialization to print the Lapotronic Supercapacitor graphic
---@param lsCapacity number
---@param lsStorage number
local function printLapotronicGraphic(lsCapacity, lsStorage)
    printCapacityGraphic(lsCapacity, lsStorage, 18, 5, 3)
end

---Specialization to print the Power Substation graphic
---@param psCapacity number
---@param psStorage number
local function printSubstationGraphic(psCapacity, psStorage)
    printCapacityGraphic(psCapacity, psStorage, 10, 46, 3)
end

local function ticksToHHMMSS(ticks)
    local seconds = math.floor(ticks / 20)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds - (hours * 3600)) / 60)
    local seconds = seconds - (hours * 3600) - (minutes * 60)
    return hours, minutes, seconds
end

local function choice(c, t, f)
    return c and t or f
end

local function shouldSoundAlarm(psCapacity, psStorage)
    local psPercentage = (psStorage/psCapacity) * 100
    if (psPercentage < psLimitAlarm) then
        component.redstone.setWirelessOutput(true)
    else
        component.redstone.setWirelessOutput(false)
    end
end

local function printScreen(lsCapacity, lsStorage, psCapacity, psStorage, tickLife, inEu, outEu)    

    local lsCapVal, lsCapMod = numToAdaptedScientificNotation(lsCapacity)
    local psCapVal, psCapMod = numToAdaptedScientificNotation(psCapacity)

    local lsStoVal, lsStoMod = numToAdaptedScientificNotation(lsStorage)
    local psStoVal, psStoMod = numToAdaptedScientificNotation(psStorage)

    local lifeH, lifeM, lifeS = ticksToHHMMSS(math.abs(tickLife))
    
    local euDiff = math.abs(inEu - outEu)
    local inEUVal, inEUMod = numToAdaptedScientificNotation(inEu)
    local outEUVal, outEUMod = numToAdaptedScientificNotation(outEu)
    local diffEUVal, diffEUMod = numToAdaptedScientificNotation(euDiff)

    local untilFullyString = choice(inEu > outEu, "charged   ", "discharged")

    print(string.format("  ┌───────┐                                ┌───────┐                            "))
    print(string.format("  │       │   Lapotronic Supercapacitor    │       │   Power Substation         "))
    print(string.format("  │       │                                │       │                            "))
    print(string.format("  │       │   ┌ Capacity ──────────────┐   │       │ ┌ Capacity ──────────────┐ "))
    print(string.format("  │       │   │ %18.2f %sEU │   │       │ │ %18.2f %sEU │ ", lsCapVal, lsCapMod, psCapVal, psCapMod))
    print(string.format("  │       │   └────────────────────────┘   │       │ └────────────────────────┘ "))
    print(string.format("  │       │                                │       │                            "))
    print(string.format("  │       │   ┌ Storage ───────────────┐   │       │ ┌ Storage ───────────────┐ "))
    print(string.format("  │       │   │ %18.2f %sEU │   │       │ │ %18.2f %sEU │ ", lsStoVal, lsStoMod, psStoVal, psStoMod))
    print(string.format("  │       │   └────────────────────────┘   │       │ └────────────────────────┘ "))
    print(string.format("  │       │ ╔═════════════════════════════»│       │      .---.                 "))
    print(string.format("  │       │ ║                              └───────┘ (\\./)     \\.......-        "))
    print(string.format("  │       │ ║                                        >' '<  (__.'\"\"\"\"BP         "))
    print(string.format("  │       │ ║ ┌ Stats ───────────────────────────────\"-`-\"-\"──────────────────┐ "))
    print(string.format("  │       │ ║ │                                                               │ "))
    print(string.format("  │       │ ║ │ Θ Battery Life:     %02d:%02d:%02d until fully %s           │ ", lifeH, lifeM, lifeS, untilFullyString))
    print(string.format("  │       │ ║ │ ↑ Charging:     %6.2f %sEU/t                                  │ ", inEUVal, inEUMod))
    print(string.format("  │       ╞»╝ │ Δ Difference:   %6.2f %sEU/t                                  │ ", diffEUVal, diffEUMod))
    print(string.format("  │       │   │ ↓ Discharging:  %6.2f %sEU/t                                  │ ", outEUVal, outEUMod))
    print(string.format(" ╔╧═══════╧╗  │                                                               │ "))
    print(string.format(" ╚════O════╝  └───────────────────────────────────────────────────────────────┘ "))

    printLapotronicGraphic(lsCapacity, lsStorage)
    printSubstationGraphic(psCapacity, psStorage)
end

setupScreen()

local substationCapacity = substation.getEUCapacity()
local lapotronicCapacity = lapotronic.getEUCapacity()
local totalEUCapacity = substationCapacity + lapotronicCapacity

while true do

    substation.updateSensorInfo()
    lapotronic.updateSensorInfo()
    local substationStored = substation.getEUStored()
    local lapotronicStored = lapotronic.getEUStored()

    local euSum = substationStored + lapotronicStored
    local euIn = lapotronic.getEUAverageInput()
    local euOut = substation.getEUAverageOutput()
    local euPerTickDiff = euIn - euOut
    local tickLife = -1
    if (euPerTickDiff < 0) then
        tickLife = euSum / math.abs(euPerTickDiff)
    else
        tickLife = (totalEUCapacity - euSum) / euPerTickDiff
    end
    shouldSoundAlarm(substationCapacity, substationStored)


    term.clear()

    printBanner()
    printScreen(lapotronicCapacity, lapotronicStored, substationCapacity, substationStored, tickLife, euIn, euOut)

---@diagnostic disable-next-line: undefined-field
    os.sleep(20 / readingTickInterval)

end

