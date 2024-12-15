-- This file is only intended to be used for debug purposes and is not an essential
-- part of the power control program.
-- The idea is that you can use the objects from the main code freely
-- Set the DEBUG variable on the main file as true before importing it in a lua console

main = require("main")
config = require("config")
gtPS = require("gtPowerStorage")

substationProxy, lapotronicProxy = main.getComponents()

substation = gtPS.GTPowerStorage.new(
   substationProxy,
   config.sensor_strings.substationAvgInput,
   config.sensor_strings.substationAvgOutput,
   config.sensor_strings.substationCapacity
)
lapotronic = gtPS.GTPowerStorage.new(
   lapotronicProxy,
   config.sensor_strings.lapotronicAvgInput,
   config.sensor_strings.lapotronicAvgOutput,
   config.sensor_strings.lapotronicCapacity
)
