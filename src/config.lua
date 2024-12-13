
local config = {
    -- Tick interval between measurements. 20 ticks measure to 1 second
    readingTickInterval = 20,
    -- Number of entries to use when calculating the eu difference average
    avgEntryCount = 60,

    -- Enable power output to a WR-CBE channel if the power level falls below a certain threshold
    enableAlarm = true,
    -- Power percentage threshold to activate the alarm
    alarmPowerPercentageThreshold = 5,
    -- Frequency to send the alarm redstone signal
    alarmWirelessFrequency = 1016,
    -- Enable control over turbine via WR-CBE channel
    enableTurbineControl = true,
    -- Power percentage threshold to deactivate the turbine
    maxPowerPercentageThreshold = 80,
    -- Power percentage threshold to activate the turbine
    minPowerPercentageThreshold = 20,

    -- String values that can be used to extract some data from the sensor info table
    sensor_strings = {
         substationAvgInput = "Average Input",
         substationAvgOutput = "Average Output",
         substationCapacity = "Capacity:",
         lapotronicAvgInput = "Avg EU IN",
         lapotronicAvgOutput = "Avg EU OUT",
         lapotronicCapacity = "Total Capacity:",
    }
}

return config
