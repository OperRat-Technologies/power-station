
# Power Station Integration

> This was made for our playthrough of **GregTech: New Horizons**, we don't guarantee support for any other modpacks.

Software for our Power Station display integration, integrating a Power Substation, a Lapotronic Supercapacitor and a redstone signal to Project Red wires to make a power indicator outside the power station.

![](/img/interface.png)

# Required Setup

- Display with at least `80 x 23` characters of resolution (We're using a `5 x 3` multiblock Tier 2 display);
- An `Adapter` connected to the `Power Substation Controller`;
- An `Adapter` connected to the `Lapotronic Supercapacitor Controller`;
- (For the Alarm) A `Redstone Card` with at least Tier 2;

# Installing
Run the following command to download all required files:
```
wget https://raw.githubusercontent.com/OperRat-Technologies/power-station/main/src/main.lua install.lua && install
```

You can edit all the configuration inside the file `config.lua`.

**The computer will restart after all files are downloaded.**


# Running
Just run the main script with:
```
main
```

# Updating
To update the system, just reinstall it:
```
install
```
> **Beware**: This will overwrite your `config.lua` file

# Uninstalling
To remove all files from the computer:
```
uninstall
```