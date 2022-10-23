
RV-Debugger-BL702.zip is downloaded from
https://electronix.ru/forum/index.php?app=forums&module=forums&controller=topic&id=166408&page=2#comment-1810016

bflb-mcu-tool-1.8.0.tar.gz is downloaded from
https://pypi.org/project/bflb-mcu-tool

cat /etc/udev/rules.d/99-sipeed.rules 
SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", MODE:="0666", RUN+="/sbin/rmmod ftdi_sio"
