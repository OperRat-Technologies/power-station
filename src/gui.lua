local component = require("component")
local utils = require("utils")
local gpu = component.gpu
local ci = require("commonInterface")

local screen = ci.Screen(
    23,
    80,
    0xffffff,
    0x000000,
    [[███▓▓▓▒▒▒░░░ ratOS » Power Station Control                                      ]],
    [[  ┌───────┐                                ┌───────┐                            ]],
    [[  │       │   Lapotronic Supercapacitor    │       │   Power Substation         ]],
    [[  │       │                                │       │                            ]],
    [[  │       │   ┌ Capacity ──────────────┐   │       │ ┌ Capacity ──────────────┐ ]],
    [[  │       │   │ %18.2f %s           EU │   │       │ │ %18.2f %s           EU │ ]],
    [[  │       │   └────────────────────────┘   │       │ └────────────────────────┘ ]],
    [[  │       │                                │       │                            ]],
    [[  │       │   ┌ Storage ───────────────┐   │       │ ┌ Storage ───────────────┐ ]],
    [[  │       │   │ %18.2f %s           EU │   │       │ │ %18.2f %s           EU │ ]],
    [[  │       │   └────────────────────────┘   │       │ └────────────────────────┘ ]],
    [[  │       │ ╔═════════════════════════════»│       │      .---.                 ]],
    [[  │       │ ║                             ╔╧═══════╧╗(\./)     \.......-        ]],
    [[  │       │ ║                             ╚═%s     ═╝>' '<  (__.'""""BP         ]],
    [[  │       │ ║ ┌ Stats ───────────────────────────────"-`-"-"──────────────────┐ ]],
    [[  │       │ ║ │                                                               │ ]],
    [[  │       │ ║ │ Θ Battery Life:  XXd XX:XX:XX until fully discharged          │ ]],
    [[  │       │ ║ │ ↑ Charging:      XXX.XX ?EU/t                                 │ ]],
    [[  │       ╞»╝ │ Δ Difference:   +XXX.XX ?EU/t (Avg)    +XXX.XX ?EU/t (Real)   │ ]],
    [[  │       │   │ ↓ Discharging:   XXX.XX ?EU/t                                 │ ]],
    [[ ╔╧═══════╧╗  │                                                               │ ]],
    [[ ╚═%s     ═╝  └───────────────────────────────────────────────────────────────┘ ]],
    [[                                                                                ]]
)

local pLapotronicCapacity = screen.registerParam(ci.Param(6, 17, 20, "%18.2f %s"))
local pLapotronicStorage = screen.registerParam(ci.Param(10, 17, 20, "%18.2f %s"))

local pSubstationCapacity = screen.registerParam(ci.Param(6, 56, 20, "%18.2f %s"))
local pSubstationStorage = screen.registerParam(ci.Param(10, 56, 20, "%18.2f %s"))

local pBatteryLife = screen.registerParam(ci.Param(17, 34, 35, "%2dd %02d:%02d:%02d until fully %s"))
local pCharging = screen.registerParam(ci.Param(18, 34, 8, "%6.2f %s"))
local pDifferenceAvg = screen.registerParam(ci.Param(19, 33, 9, "%7.2f %s"))
local pDifferenceReal = screen.registerParam(ci.Param(19, 56, 9, "%7.2f %s"))
local pDischarging = screen.registerParam(ci.Param(20, 34, 8, "%6.2f %s"))

local pLapotronicPercentage = screen.registerParam(ci.Param(22, 4, 7, "%s"))
local pSubstationPercentage = screen.registerParam(ci.Param(14, 45, 7, "%s"))

---Prints the capacity graphic, starting from the bottom
---@param capacity number
---@param storage number
---@param layers number
---@param topX number
---@param topY number
local function printCapacityGraphic(capacity, storage, layers, topX, topY)
    local lsPercentage = storage / capacity * 100
    local percentagePerLayer = 100 / layers

    local fillingColors = {0x00FF00, 0xFF9200, 0xFF0000}
    local fillingIndex = math.max(1, math.ceil((3 * (100 - lsPercentage)) / 100))
    local fillingC = { "▓", "▒", "░" }
    local fillingP = { 0.66 * percentagePerLayer, 0.33 * percentagePerLayer, 0 }

    local filledLayers = (lsPercentage >= 99.95) and layers or math.floor(lsPercentage / percentagePerLayer)
    local emptyLayers = layers - filledLayers - 1
    gpu.setForeground(fillingColors[fillingIndex])
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

    if (emptyLayers > 0) then
        gpu.fill(topX, topY, 5, emptyLayers, " ")
    end
    gpu.setForeground(0x000000)
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

local function setupScreen()
    screen.assertScreenSize()
    screen.printBackground()
    screen.clearAllParams()
end

local function printScreen(lsCapacity, lsStorage, psCapacity, psStorage, tickLife, inEu, outEu, diffAvg)
    local lsCapVal, lsCapMod = utils.numToAdaptedScientificNotation(lsCapacity)
    local psCapVal, psCapMod = utils.numToAdaptedScientificNotation(psCapacity)

    local lsStoVal, lsStoMod = utils.numToAdaptedScientificNotation(lsStorage)
    local psStoVal, psStoMod = utils.numToAdaptedScientificNotation(psStorage)

    local lifeD, lifeH, lifeM, lifeS = utils.ticksToHHMMSS(math.abs(tickLife))

    local euDiff = inEu - outEu
    local inEUVal, inEUMod = utils.numToAdaptedScientificNotation(inEu)
    local outEUVal, outEUMod = utils.numToAdaptedScientificNotation(outEu)
    local diffEUAvgVal, diffEUAvgMod = utils.numToAdaptedScientificNotation(diffAvg)
    local diffEUVal, diffEUMod = utils.numToAdaptedScientificNotation(euDiff)

    local untilFullyString = utils.choice(inEu > outEu, "charged      ", "discharged   ")

    local percentageLapotronic = (lsStorage/lsCapacity) * 100
    local percentageSubstation = (psStorage/psCapacity) * 100

    pLapotronicCapacity.print(lsCapVal, lsCapMod)
    pSubstationCapacity.print(psCapVal, psCapMod)
    pLapotronicStorage.print(lsStoVal, lsStoMod)
    pSubstationStorage.print(psStoVal, psStoMod)
    pBatteryLife.print(lifeD, lifeH, lifeM, lifeS, untilFullyString)
    pCharging.print(inEUVal, inEUMod)
    pDifferenceAvg.print(diffEUAvgVal, diffEUAvgMod)
    pDifferenceReal.print(diffEUVal, diffEUMod)
    pDischarging.print(outEUVal, outEUMod)
    pLapotronicPercentage.print(utils.centeredString(string.format("%5.2f%%", percentageLapotronic), 7, "═"))
    pSubstationPercentage.print(utils.centeredString(string.format("%5.2f%%", percentageSubstation), 7, "═"))

    printLapotronicGraphic(lsCapacity, lsStorage)
    printSubstationGraphic(psCapacity, psStorage)
end

return {
    setupScreen = setupScreen,
    printCapacityGraphic = printCapacityGraphic,
    printLapotronicGraphic = printLapotronicGraphic,
    printSubstationGraphic = printSubstationGraphic,
    printScreen = printScreen
}