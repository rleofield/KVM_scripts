#!/bin/bash

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


cd /home/qemu

LOGFILE=nohup.out
SYSTEM=$1

if [[ ${#VMCONFIG} == 0 ]]
then
	VMCONFIG=./config.txt
fi

echo "lookup of '$SYSTEM'" 

# lookup MAC in '$VMCONFIG'
MAC=$(grep -w $SYSTEM $VMCONFIG | awk '{ print $3 }')
if [[ ${#MAC} == 0 ]]
then
	# MAC not found, is '$SYSTEM' listed in '../config.txt'?
	echo "'$SYSTEM' not found in './config.txt' "
       
	exit
fi

cd /home/qemu/$SYSTEM
pwd
./vstart.sh &
cd

echo "ok" 


