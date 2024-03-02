
local config = {
    -- Tick interval between measurements. 20 ticks measure to 1 second
    readingTickInterval = 20,

    -- Enable power output to a WR-CBE channel if the power level falls below a certain threshold
    enableAlarm = true,
    -- Power percentage threshold to activate the alarm
    alarmPowerPercentageThreshold = 5,
    -- Frequency to send the alarm redstone signal
    alarmWirelessFrequency = 1015
}

return { config = config }