local shell = require("shell")
local computer = require("computer")
local args = {...}
local repo = "https://raw.githubusercontent.com/OperRat-Technologies/power-station"
local branch
local scripts = {
    "alarm.lua",
    "config.lua",
    "gtPowerStorage.lua",
    "gui.lua",
    "utils.lua",
    "main.lua",
    "uninstall.lua",
    "commonInterface.lua",
    "averageValue.lua",
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
