
-- Configuration
local readingMeanValues = 5


local term = require("term")
local component = require("component")
local gpu = component.gpu
-- 
-- Useful methods for the substation
-- getEUStored
-- getEUCapacity
-- getEUOutputAverage / getEUInputAverage
local substation, lapotronic_supercapacitor

-- loop through all components in the system
for address, name in component.list() do
    -- filter only gregtech machines, as we need the substation and the supercapacitor
    if (string.find(name, "gt_machine")) then
        local proxy = component.proxy(address)
        local machineName = proxy.getName()

        if (string.find(machineName, "substation")) then
            substation = proxy
        end

        if (string.find(machineName, "supercapacitor")) then
            lapotronic_supercapacitor = proxy
        end
    end
end

---Style setup
local function setupScreen()
    gpu.setForeground(0x000000)
    gpu.setBackground(0xffffff)
    gpu.setResolution(80, 25)
    gpu.setViewport(80, 25)
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
    printCapacityGraphic(lsCapacity, lsStorage, 20, 5, 3)
end

---Specialization to print the Power Substation graphic
---@param psCapacity number
---@param psStorage number
local function printSubstationGraphic(psCapacity, psStorage)
    printCapacityGraphic(psCapacity, psStorage, 10, 47, 3)
end

local function printScreen(lsCapacity, lsStorage, lsInEU, lsOutEU, psCapacity, psStorage)

    local lsPercentage = lsStorage / lsCapacity * 100

    -- number of layers on the graphic below (the │ ░░░░░ │ lines)
    local gLayers = 20
    local percentagePerLayer = 100 / gLayers

    local status = lsInEU > lsOutEU and "   CHARGING" or "DISCHARGING"

    local lsCapVal, lsCapMod = numToAdaptedScientificNotation(lsCapacity)
    local psCapVal, psCapMod = numToAdaptedScientificNotation(psCapacity)

    local lsStoVal, lsStoMod = numToAdaptedScientificNotation(lsStorage)
    local psStoVal, psStoMod = numToAdaptedScientificNotation(psStorage)


    print(string.format("  ┌───────┐                                 ┌───────┐                           "))
    print(string.format("  │       │   Lapotronic Supercapacitor     │       │   Power Substation        "))
    print(string.format("  │       │                                 │       │                           "))
    print(string.format("  │       │   ┌ Capacity ──────────────┐    │       │ ┌ Capacity ─────────────┐ "))
    print(string.format("  │       │   │ %18.2f %sEU │    │       │ │ %17.2f %sEU │ ", lsCapVal, lsCapMod, psCapVal, psCapMod))
    print(string.format("  │       │   └────────────────────────┘    │       │ └───────────────────────┘ "))
    print(string.format("  │       │                                 │       │                           "))
    print(string.format("  │       │   ┌ Storage ───────────────┐    │       │ ┌ Storage ──────────────┐ "))
    print(string.format("  │       │   │ %18.2f %sEU │    │       │ │ %17.2f %sEU │ ", lsStoVal, lsStoMod, psStoVal, psStoMod))
    print(string.format("  │       │   └────────────────────────┘    │       │ └───────────────────────┘ "))
    print(string.format("  │       │                                 │       │                           "))
    print(string.format("  │       │   ┌ Stats ─────────────────┐    └───────┘                           "))
    print(string.format("  │       │   │                        │                                        "))
    print(string.format("  │       │   │ Status:    %s │                                        ", status))
    print(string.format("  │       │   │ Percentage:   %6.2f %s |                                        ", lsPercentage, "%"))
    print(string.format("  │       │   │ In:  %11.2f %sEU/t │                                        ", numToAdaptedScientificNotation(lsInEU)))
    print(string.format("  │       │   │ Out: %11.2f %sEU/t │                                        ", numToAdaptedScientificNotation(lsOutEU)))
    print(string.format("  │       │   └────────────────────────┘                                        "))
    print(string.format("  │       │                                                                     "))
    print(string.format("  │       │                                                                     "))
    print(string.format("  │       │                                                                     "))
    print(string.format(" ╔╧═══════╧╗                                                                    "))
    print(string.format(" ╚════O════╝                                                                    "))

    printLapotronicGraphic(lsCapacity, lsStorage)
    printSubstationGraphic(psCapacity, psStorage)
end

---Calculate the mean of a list of values
---@param values table
local function meanWithout0(values)
    local sum = 0
    local dividend = 1
    for _,v in pairs(values) do
        sum = sum + v
        if (v > 0) then
            dividend = dividend + 1
        end
    end
    return sum / dividend
end

local cap_last_5_input, cap_last_5_output = {}, {}

setupScreen()

while true do

    local sub_stored = substation.getEUStored()
    local sub_capacity = substation.getEUCapacity()
    -- substation returns 0 for both input and output

    local cap_stored = lapotronic_supercapacitor.getEUStored()
    local cap_capacity = lapotronic_supercapacitor.getEUCapacity()
    local cap_input = lapotronic_supercapacitor.getEUInputAverage()
    local cap_output = lapotronic_supercapacitor.getEUOutputAverage()
    local cap_einput = lapotronic_supercapacitor.getAverageElectricInput()
    local cap_eoutput = lapotronic_supercapacitor.getAverageElectricOutput()

    local cap_actual_input = cap_input ~= 0 and cap_input or cap_einput
    local cap_actual_output = cap_output ~= 0 and cap_output or cap_eoutput

    table.insert(cap_last_5_input, cap_actual_input)
    table.insert(cap_last_5_output, cap_actual_output)

    if (#cap_last_5_input > readingMeanValues) then
        table.remove(cap_last_5_input, 1)
    end
    if (#cap_last_5_output > readingMeanValues) then
        table.remove(cap_last_5_output, 1)
    end

    local ls_input = meanWithout0(cap_last_5_input)
    local ls_output = meanWithout0(cap_last_5_output)

    term.clear()

    printBanner()
    printScreen(cap_capacity, cap_stored, ls_input, ls_output, sub_capacity, sub_stored)

end

