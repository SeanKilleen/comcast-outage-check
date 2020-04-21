# Comcast Outage Check

Xfinity goes down so much at my house that I wrote a Powershell script to parse my router's logs &amp; capture the info.

## Background

* My Archer A20 router has logs for LEDs that turn on/off
* When the internet goes out, there's an LED change event in the logs.

## How to Use

* Export the router log
* Place in the "input" folder in the top level
* Run the script
* Check the "output" folder
