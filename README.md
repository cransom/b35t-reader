Owon/Lilliput provies a mobile app to read their B35T device but have released
no other information.

This script extends the information found at
https://hackaday.io/project/12922-bluetooth-data-owon-b35t-multimeter and prints
out every update sent by the meter.


# How to use

## Setup
Get the MAC address of the meter by running `sudo hcitool lescan` before turning
on the meter and holding the bluetooth button. You should get line with `<MAC
ADDRESS> BDM`. Add this address to the script at the top.

There's no pairing required.

## Running

Turn on the meter, flip bluetooth on, run the script.

The meter will not sleep while BT is enabled.

If the script is spitting errors about unknown modes, moving the dial around
resolved the issue for me.

In case the script stops outputting data, ^c it, turn off the meter and restart
it.


The shebang is currently set to use nix-shell (part of Nix package manager.). If
you aren't using it, you can just `ruby b35t-reader.rb` and ensure gatttool is
in your path.
