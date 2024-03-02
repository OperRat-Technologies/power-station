local component = require("component")
local utils = require("utils")
local gpu = component.gpu

local function setupScreen()
    gpu.setForeground(0x000000)
    gpu.setBackground(0xffffff)
    gpu.setResolution(80, 23)
    gpu.setViewport(80, 23)
end

local function printBanner()
    print("███▓▓▓▒▒▒░░░ ratOS » Power Station Control                                      ")
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

    local fillingC = { "▓", "▒", "░" }
    local fillingP = { 0.66 * percentagePerLayer, 0.33 * percentagePerLayer, 0 }

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

local function printScreen(lsCapacity, lsStorage, psCapacity, psStorage, tickLife, inEu, outEu)
    local lsCapVal, lsCapMod = utils.numToAdaptedScientificNotation(lsCapacity)
    local psCapVal, psCapMod = utils.numToAdaptedScientificNotation(psCapacity)

    local lsStoVal, lsStoMod = utils.numToAdaptedScientificNotation(lsStorage)
    local psStoVal, psStoMod = utils.numToAdaptedScientificNotation(psStorage)

    local lifeH, lifeM, lifeS = utils.ticksToHHMMSS(math.abs(tickLife))

    local euDiff = math.abs(inEu - outEu)
    local inEUVal, inEUMod = utils.numToAdaptedScientificNotation(inEu)
    local outEUVal, outEUMod = utils.numToAdaptedScientificNotation(outEu)
    local diffEUVal, diffEUMod = utils.numToAdaptedScientificNotation(euDiff)
    local diffMathOperator = utils.numMathOperator(diffEUVal)

    local untilFullyString = utils.choice(inEu > outEu, "charged   ", "discharged")

    print(string.format("  ┌───────┐                                ┌───────┐                            "))
    print(string.format("  │       │   Lapotronic Supercapacitor    │       │   Power Substation         "))
    print(string.format("  │       │                                │       │                            "))
    print(string.format("  │       │   ┌ Capacity ──────────────┐   │       │ ┌ Capacity ──────────────┐ "))
    print(string.format("  │       │   │ %18.2f %sEU │   │       │ │ %18.2f %sEU │ ", lsCapVal, lsCapMod, psCapVal,
        psCapMod))
    print(string.format("  │       │   └────────────────────────┘   │       │ └────────────────────────┘ "))
    print(string.format("  │       │                                │       │                            "))
    print(string.format("  │       │   ┌ Storage ───────────────┐   │       │ ┌ Storage ───────────────┐ "))
    print(string.format("  │       │   │ %18.2f %sEU │   │       │ │ %18.2f %sEU │ ", lsStoVal, lsStoMod, psStoVal,
        psStoMod))
    print(string.format("  │       │   └────────────────────────┘   │       │ └────────────────────────┘ "))
    print(string.format("  │       │ ╔═════════════════════════════»│       │      .---.                 "))
    print(string.format("  │       │ ║                              └───────┘ (\\./)     \\.......-        "))
    print(string.format("  │       │ ║                                        >' '<  (__.'\"\"\"\"BP         "))
    print(string.format("  │       │ ║ ┌ Stats ───────────────────────────────\"-`-\"-\"──────────────────┐ "))
    print(string.format("  │       │ ║ │                                                               │ "))
    print(string.format("  │       │ ║ │ Θ Battery Life:     %02d:%02d:%02d until fully %s           │ ", lifeH, lifeM,
        lifeS, untilFullyString))
    print(string.format("  │       │ ║ │ ↑ Charging:     %6.2f %sEU/t                                  │ ", inEUVal,
        inEUMod))
    print(string.format("  │       ╞»╝ │ Δ Difference:   %s%6.2f %sEU/t                                  │ ", diffMathOperator,
    diffEUVal, diffEUMod))
    print(string.format("  │       │   │ ↓ Discharging:  %6.2f %sEU/t                                  │ ", outEUVal,
        outEUMod))
    print(string.format(" ╔╧═══════╧╗  │                                                               │ "))
    print(string.format(" ╚════O════╝  └───────────────────────────────────────────────────────────────┘ "))

    printLapotronicGraphic(lsCapacity, lsStorage)
    printSubstationGraphic(psCapacity, psStorage)
end

return {
    setupScreen = setupScreen,
    printBanner = printBanner,
    printCapacityGraphic = printCapacityGraphic,
    printLapotronicGraphic = printLapotronicGraphic,
    printSubstationGraphic = printSubstationGraphic,
    printScreen = printScreen
}