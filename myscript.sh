#!/bin/bash

echo "Press CTRL+C to exit"

#This gives enough time for connection to be re-established
sleep 10

while :
do
#Below reconnects to the Bluetooth Module each time it drops the connection with the MAC
    screen /dev/tty.HC-05-DevB 9600 >> data.txt
done
