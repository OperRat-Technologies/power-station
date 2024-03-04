-- Module imports
local term = require("term")
local component = require("component")

local config = require("config")
local alarm = require("alarm")
local gtPS = require("gtPowerStorage")
local gui = require("gui")

local substationProxy, lapotronicProxy
local substation, lapotronic
local psAlarm

local substationCapacity, lapotronicCapacity, totalEUCapacity

local function getComponents()
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
end

local function setup()
    getComponents()

    substation = gtPS.GTPowerStorage.new(substationProxy, "Average Input", "Average Output")
    lapotronic = gtPS.GTPowerStorage.new(lapotronicProxy, "Avg EU IN", "Avg EU OUT")

    psAlarm = alarm.Alarm.new(config.alarmWirelessFrequency, substation)
    psAlarm.enabled = config.enableAlarm

    gui.setupScreen()

    substationCapacity = substation.getEUCapacity()
    lapotronicCapacity = lapotronic.getEUCapacity()
    totalEUCapacity = substationCapacity + lapotronicCapacity
end

local function loop()
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

    psAlarm.updateAlarm()

    term.clear()
    gui.printScreen(lapotronicCapacity, lapotronicStored, substationCapacity, substationStored, tickLife, euIn, euOut)

    ---@diagnostic disable-next-line: undefined-field
    os.sleep(20 / config.readingTickInterval)
end

-- Main
setup()
while true do
    loop()
end
