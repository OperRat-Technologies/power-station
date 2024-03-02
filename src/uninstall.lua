local shell = require("shell")
local scripts = {
    "alarm.lua",
    "config.lua",
    "gtPowerStorage.lua",
    "gui.lua",
    "install.lua",
    "main.lua",
    "utils.lua",
    "uninstall.lua",
}

for i = 1, #scripts do
    shell.execute(string.format('rm %s', scripts[i]))
    print(string.format('Removed %s', scripts[i]))
end