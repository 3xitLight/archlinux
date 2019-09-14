#!/bin/sh

sleep 17
conky -c ~/.conky/conkyrc0 &
conky -c ~/.conky/conkyrc1 &
conky -c ~/.conky/conkyrc2 &

exit
