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

IFS=' '


winlist=$(ls -l --time-style="+%Y-%m-%d %H:%M" . | grep '^d' | grep win | awk '{print $8}' )

function extractParameter()
{

	IFS=' '
       	_line=$1
       	_image=$2

       	PID=`echo "$_line" | awk '{ print $2 }'`
	CPU=`echo "$_line" | awk '{ print $3 }'`


	IPADR=`grep -w $_image ./config.txt | awk '{ print $2 }'`
	VNC=`grep -w $_image ./config.txt | awk '{ print $5 }'`

	NR=$(echo $IPADR | sed s/'\.'/' '/g  | awk '{ print $4}')       
	DNSURL=`grep -w $_image ./config.txt | awk '{ print $6 }'`
	LOGINNAME=`grep -w $_image ./config.txt | awk '{ print $7 }'`


	UPTIME=$(echo "$DNSURL - no SSH ")
	if [[ ${#LOGINNAME} > 2 ]]
	then
			UPTIME=$(ssh $LOGINNAME@$DNSURL 'uptime')
	fi		

	isVNC=$(echo "$_line" | grep -w vnc)
	if [[ $isVNC > "" ]]
	then
		vncPAR=$(echo "$isVNC" | awk -F "vnc" '{print $2}')
		VNC=$(echo "$vncPAR" | awk -F " " '{print $1}')
	else
		VNC="none"
	fi	
	if [[ ${#_image} < 8 ]]
	then
		_image=$(echo "$_image	")
	fi

	echo "IP: $NR,  VM: $_image	PID: $PID	CPU: $CPU	vnc: $VNC "
	echo "		uptime: $UPTIME"
#			echo "ssh $LOGINNAME@$DNSURL 'uptime'"
IFS='
'
}


function extractParameter1()
{
       	_image=$1
	echo "$_image"
IFS='
'
}


hasVMs=

IFS='
'

KVMIMAGELIST=$(ls -l --time-style="+%Y-%m-%d %H:%M" . | grep '^d' | awk '{print $8}' )


for kvmimage in $KVMIMAGELIST
do
if [[ ( $kvmimage != lost+found) && ( $kvmimage != $(cat /etc/hostname) ) ]]
then
	# look for VM  started with virsh
	KVMLINE=$(ps aux | grep kvm | grep monitor | grep -w $kvmimage)
        if [[ ${#KVMLINE}  > 0 ]]
        then
		#echo "$KVMLINE"
#                echo "is running in virsh"
		extractParameter $KVMLINE $kvmimage
		hasVMs="true"
                echo "---------"
	else
		# look for VM  started with simple script
		KVMLINE=`ps aux | grep kvm | grep -w $kvmimage` 
        	if [[ ${#KVMLINE} > 0 ]]
        	then
#                	echo "is running with script"
			if [[ $1 == "-1" ]]
			then
				echo "$kvmimage"
			else
				extractParameter $KVMLINE $kvmimage
	                	echo "---------"
			fi	
			hasVMs="true"
	        fi
        fi
fi
done

if [[ ${#hasVMs} = 0 ]]
then
	echo "no VM is running here"
fi
exit

																																																
