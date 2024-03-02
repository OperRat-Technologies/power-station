local shell = require("shell")
local args = {...}
local repo = "https://raw.githubusercontent.com/OperRat-Technologies/power-station"
local branch
local scripts = {
    "alarm.lua",
    "config.lua",
    "gt_power_storage.lua",
    "gui.lua",
    "utils.lua",
    "main.lua",
}

if #args >= 1 then
    branch = args[1]
else
    branch = "main"
end

for i = 1, #scripts do
    shell.execute(string.format("wget -f %s/%s/src/%s", repo, branch, scripts[i]))
end