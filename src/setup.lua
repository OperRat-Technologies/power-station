local shell = require("shell")
local computer = require("computer")
local args = {...}
local repo = "https://raw.githubusercontent.com/OperRat-Technologies/power-station"
local branch
local scripts = {
    "alarm.lua",
    "averageValue.lua",
    "commonInterface.lua",
    "config.lua",
    "debug.lua",
    "gtPowerStorage.lua",
    "gui.lua",
    "main.lua",
    "setup.lua",
    "turbine.lua",
    "uninstall.lua",
    "utils.lua",
}

if #args >= 1 then
    branch = args[1]
else
    branch = "main"
end

for i = 1, #scripts do
    shell.execute(string.format("wget -f %s/%s/src/%s", repo, branch, scripts[i]))
end

computer.shutdown(true)
