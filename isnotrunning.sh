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

IFS='
'

KVMIMAGELIST=$(ls -l --time-style="+%Y-%m-%d %H:%M" . | grep '^d' | awk '{print $8}' )


for kvmimage in $KVMIMAGELIST
do
if [[ ( $kvmimage != lost+found) && ( $kvmimage != $(cat /etc/hostname) ) ]]
then
	KVMLINE=$(ps aux | grep kvm | grep -w $kvmimage)
        if [[ $KVMLINE  == "" ]]
        then
		LINE=`grep -w $kvmimage ./config.txt`
		IPADR=`grep -w $kvmimage ./config.txt | awk '{ print $2 }'`
#		echo "$IPADR"
		NR=$(echo $IPADR | sed s/'\.'/' '/g  | awk '{ print $4 }')       
#		NR=$(echo $IPADR | sed s/'\.'/' '/g  )       
		if [[ $LINE > "" ]]
		then
			echo "IP: $NR, name: $kvmimage"
		fi

        fi
fi
done


																																																
