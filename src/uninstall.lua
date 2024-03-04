local shell = require("shell")
local scripts = {
    "alarm.lua",
    "config.lua",
    "gtPowerStorage.lua",
    "gui.lua",
    "setup.lua",
    "main.lua",
    "utils.lua",
    "commonInterface.lua",
    "uninstall.lua",
}

for i = 1, #scripts do
    shell.execute(string.format('rm %s', scripts[i]))
    print(string.format('Removed %s', scripts[i]))
end