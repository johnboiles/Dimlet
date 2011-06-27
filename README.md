# Dimlet

A portable, network-controlled light dimmer that can be controlled from an
iOS application. Dimlet consists of:

*   an iOS application
*   an embedded linux server (for [OpenWRT](https://openwrt.org/))
*   microcontroller firmware (for [ATTiny88](http://www.atmel.com/dyn/products/product_card.asp?part_id=4351))
*   electronics design ([Eagle](http://www.cadsoft.de/) schematic)

Check out [the video](http://www.youtube.com/watch?v=4GmYcn8vb1U)

Also check out the [full writeup](http://johnboiles.com/dimlet)

## Theory of Operation

The iOS app determines the desired intensities from the user based on
accelerometer readings, sliders, or pre set patterns. It then sends commands
over UDP to the linux server.

The Linux server receives UDP packets from the iOS app, and sends the data
out the serial port to the microcontroller. The server code was made to run on
OpenWRT devices.

The microcontroller gets the data over the UART and controls triacs in
order to control the intensities of the lights. [This page](http://home.howstuffworks.com/dimmer-switch2.htm) has some nice-looking
graphs about dimming AC lights.

## Protocol

UDP packets are formed using a 5 byte protocol. Each packet must contain a start byte of 0, then 4 bytes containing brightness from 0 to 255 for each circuit. This is loosely based on the [DMX-512 protocol](http://en.wikipedia.org/wiki/DMX512).

[start byte (0)] [circuit 1 (0-255)] [circuit 2 (0-255)] [circuit 3 (0-255)] [circuit 4 (0-255)]

## Testing the Hardware

You can test the dimming hardware over the network using netcat.

Ubuntu

    # Turn Dimlet on
    echo -n -e "\x00\xff\xff\xff\xff" | nc -uvv -q 0 [Dimlet IP Address] 4950
    # Turn Dimlet off
    echo -n -e "\x00\x00\x00\x00\x00" | nc -uvv -q 0 [Dimlet IP Address] 4950

Mac

    # Turn Dimlet on
    echo -n -e "\x00\xff\xff\xff\xff" | nc -uvv -w 0 [Dimlet IP Address] 4950
    # Turn Dimlet off
    echo -n -e "\x00\x00\x00\x00\x00" | nc -uvv -w 0 [Dimlet IP Address] 4950
