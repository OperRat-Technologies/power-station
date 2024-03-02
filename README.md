
# Power Station Integration

> This was made for our playthrough of **GregTech: New Horizons**, we don't guarantee support for any other modpacks.

Software for our Power Station display integration, integrating a Power Substation, a Lapotronic Supercapacitor and a redstone signal to Project Red wires to make a power indicator outside the power station.

![](/img/interface.png)

# Usage

You need to have an OpenComputers PC with 2 adapters connected to the interfaces of a Power Substation and a Lapotronic Supercapacitor. The code can auto-detect the interfaces, no major configuration is **required**.

To start, download the script inside the computer:
```
wget https://raw.githubusercontent.com/OperRat-Technologies/power-station/main/src/main.lua interface.lua
```

## Optional: Configuration
You can edit the reading interval on the top of the file `main.lua`:
```lua
-- Configuration
local readingTickInterval = 20
```

## Running
Just run the script inside the computer with
```
./interface.lua
```