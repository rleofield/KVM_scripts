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


LOGFILE=nohup.out

if [[ ${#VMCONFIG} == 0 ]]
then
	VMCONFIG=../config.txt
fi

echo "start of '$SYSTEM'" | tee -a $LOGFILE
echo "check, if '$SYSTEM' is already running" | tee -a $LOGFILE
# search in process list for line with 'kvm' and '$SYSTEM'
WC=$(ps aux | grep kvm | grep $SYSTEM.$EXT | wc -l)
echo "WC: $WC"
if [[ $WC > 0 ]]
then
	# one line found, VM is running
	echo "'$SYSTEM' is running, finishing" | tee -a $LOGFILE
	exit
fi
echo "'$SYSTEM' is not running, starting" | tee -a $LOGFILE

# lookup MAC in '$VMCONFIG'


MAC0=$(grep -w $SYSTEM $VMCONFIG | awk '{ print $3 }')
if [[ ${#MAC0} == 0 ]]
then
	# MAC0 not found, is '$SYSTEM' listed in '../config.txt'?
	echo "MAC0 address of '$SYSTEM' not found in '../config.txt' " | tee -a $LOGFILE
	exit
fi

MAC1=$(grep -w $SYSTEM $VMCONFIG | awk '{ print $4 }')
if [[ $MAC1 == "-" ]]
then
	# MAC1 not found, is '$SYSTEM' listed in '../config.txt'?
	echo "MAC1 address of '$SYSTEM' not found in '../config.txt' " | tee -a $LOGFILE
	# kein exit 
	#exit
fi

# lookup VNC display number in '../config.txt'
VNCOPTIONS=
if [[ ${#USEVNC} > 0 ]]
then
	if [[ "$USEVNC" != "no" ]]
	then
		# lookup number of VNC display
		VNC=$(grep -w $SYSTEM $VMCONFIG | awk '{ print $5 }')
		if [[ ${#VNC} = 0 ]]
		then
			# VNC not found, is '$SYSTEM' listed in '../config.txt'?
			echo "Keine VNC Nummer in '$VMCONFIG' gefunden." | tee -a $LOGFILE
		exit
		fi
	VNCOPTIONS=" -vnc :$VNC  "
	fi
fi
# lookup SDL option
SDLOPTIONS=
if [[ ${#USESDL} > 0 ]]
then
	if [[ "$USESDL" != "no" ]]
	then
		SDLOPTIONS=" -sdl "
	fi
fi


# start KVM 
#echo "start KVM "
USERID=`whoami`

# 'tunctl -b -u' returns the name of the tun device 
ifname0=
ifname1=
if [[ $(id -u) == 0 ]]
then
	echo "we are root, get TUN device direct"
	echo "ifname=`/usr/sbin/tunctl -b -u $USERID`"
	ifname0=`/usr/sbin/tunctl -b -u $USERID`
	if [[ $MAC0 != "-" ]]
	then
		ifname1=`/usr/sbin/tunctl -b -u $USERID`
	fi
else
	echo "we are an user, get TUN device via 'sudoers'"
	echo "ifname=sudo /usr/sbin/tunctl -b -u $USERID"
	ifname0=`sudo /usr/sbin/tunctl -b -u $USERID`
	if [[ $MAC1 != "-" ]]
	then
		ifname1=`sudo /usr/sbin/tunctl -b -u $USERID`
	fi
fi

echo "start '$SYSTEM' with these parameters:" | tee -a $LOGFILE
echo "RAM   : $RAM" | tee -a $LOGFILE
echo "NIC   : $model" | tee -a $LOGFILE
echo "MAC0  : $MAC0" | tee -a $LOGFILE
echo "MAC1  : $MAC1" | tee -a $LOGFILE
echo "Tun0  : $ifname0" | tee -a $LOGFILE
echo "Tun1  : $ifname1" | tee -a $LOGFILE
echo "VGA   : $VGA" | tee -a $LOGFILE
echo "SMP   : $SMP" | tee -a $LOGFILE
echo "RTC   : $RTC" | tee -a $LOGFILE
echo "VNC   : $VNCOPTIONS" | tee -a $LOGFILE
echo "SDL   : $SDLOPTIONS" | tee -a $LOGFILE

if [[ ${#VGA} > 0 ]]
then
	VGA=" -vga $VGA" 
fi


DAYSTART=`date +%d.%m.%Y%t%H:%M`
STARTTIME="start virtual machine '$SYSTEM' at: $DAYSTART"
echo "$STARTTIME" | tee -a $LOGFILE

UPSCRIPTBR0="script=/etc/network/qemu-ifupbr0,downscript=/etc/network/qemu-ifdownbr0"
UPSCRIPTBR1="script=/etc/network/qemu-ifupbr1,downscript=/etc/network/qemu-ifdownbr1"

NETNIC0="-net nic,vlan=0,macaddr=$MAC0,model=$model" 
if [[ $MAC1 == "-" ]]
then
	NETNIC1= 
else
	NETNIC1="-net nic,vlan=1,macaddr=$MAC1,model=$model" 
fi
	
NETTAP0="-net tap,vlan=0,ifname=$ifname0,$UPSCRIPTBR0"
if [[ $MAC1 == "-" ]]
then
	NETTAP1=
else
	NETTAP1="-net tap,vlan=1,ifname=$ifname1,$UPSCRIPTBR1"
fi

echo "NETNIC0: $NETNIC0" | tee -a $LOGFILE
echo "NETNIC1: $NETNIC1" | tee -a $LOGFILE
echo "NETTAP0: $NETTAP0" | tee -a $LOGFILE
echo "NETTAP1: $NETTAP1" | tee -a $LOGFILE

HDA="-hda $SYSTEM.$EXT"


# start kvm


if [[ $MAC1 == "-" ]]
then
	KVM_COMMAND="kvm -enable-kvm $VGA $RTC $SMP $USB $NETNIC0 $NETTAP0 -usbdevice tablet -m $RAM $HDA $VNCOPTIONS $SDLOPTIONS $@"
else
	KVM_COMMAND="kvm -enable-kvm $VGA $RTC $SMP $USB $NETNIC0 $NETTAP0 $NETNIC1 $NETTAP1 -usbdevice tablet -m $RAM $HDA $VNCOPTIONS $SDLOPTIONS $@"
fi

echo "KVM_COMMAND: $KVM_COMMAND" | tee -a $LOGFILE



# start KVM
# all output goes to 'nohup.out',  
# KVM can run as background process
nohup $KVM_COMMAND

# kvm has finished, remove tap device 
echo "$SYSTEM has finished, remove tap device" | tee -a $LOGFILE



if [[ $MAC1 == "-" ]]
then
	echo "tunctl -d $ifname0 &> /dev/null" | tee -a $LOGFILE
	if [[  $(id -u) == 0 ]] 
	then
		/usr/sbin/tunctl -d $ifname0 &> /dev/null
	else
		sudo /usr/sbin/tunctl -d $ifname0 &> /dev/null
	fi
else
	echo "tunctl -d $ifname0 &> /dev/null" | tee -a $LOGFILE
	echo "tunctl -d $ifname1 &> /dev/null" | tee -a $LOGFILE
	if [[  $(id -u) == 0 ]] 
	then
		/usr/sbin/tunctl -d $ifname0 &> /dev/null
		/usr/sbin/tunctl -d $ifname1 &> /dev/null
	else
		sudo /usr/sbin/tunctl -d $ifname0 &> /dev/null
		sudo /usr/sbin/tunctl -d $ifname1 &> /dev/null
	fi
fi

sync

#echo "save $SYSTEM.$EXT $TODAY"
#cp -v $SYSTEM.$EXT $SYSTEM.$EXT.save_$TODAY


DAYEND=$(date +%d.%m.%Y%t%H:%M)
ENDTIME="'$SYSTEM' has finished at: $DAYEND"
echo "$ENDTIME" | tee -a $LOGFILE

