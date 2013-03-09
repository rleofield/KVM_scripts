#!/usr/bin/env bash                                                                                                                            


# Copyright 2012 by Richard Albrecht
# richard.albrecht@rleofield.de
# www.rleofield.de

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.

# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


SYSTEM=precise1
EXT=ovl

cd /home/qemu/$SYSTEM


TODAY=`date +%Y%m%d-%H%M`

echo "start $SYSTEM.$EXT $TODAY"
cp -v $SYSTEM.$EXT $SYSTEM.$EXT.$TODAY


# specify which NIC, VGA, RAM to use - see qemu.org for others
model=virtio

#model=rtl8139


RAM=4096

VGA=vmware
VGA=cirrus
#VGA=std

SMP="-smp 2"

# wenn leer, dann kein VNC Display
USEVNC="yes"
#USEVNC="no"

# windows time
#RTC="-rtc base=localtime"

#linux time
RTC=

# USB Unterstuetzung an
USB=-usb

VMCONFIG='../config.txt'

. ../startall.sh


