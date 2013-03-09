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


#KVMIMAGELIST=$(ls -l --time-style="+%Y-%m-%d %H:%M" . | grep '^d' | awk '{print $8}')


KVMIMAGELIST="bodhi dapper debian eserver homexp kserver maverick precise1 userver win2008de win7basje win7basvs win7basvv win7fibu winw2k winxp"

cd /home/qemu
runninglist=$(./isrunning.sh -1)

for KVMIMAGE in $KVMIMAGELIST
do
	IFS='
	'
	echo "=== copy ==="
	echo "$KVMIMAGE"
	echo "============"
	isrunningkvm=
	for running in $runninglist
	do
		if [[ $running == $KVMIMAGE ]]
		then
			isrunningkvm=$running
		fi
	done
	isimage=$(grep $KVMIMAGE "userver")
	echo "isrunning $isrunningkvm"
	#echo "abc $abc"
	if [[ ${#isrunningkvm} > 0 ]]
	then    
		echo "skip overlay $KVMIMAGE.ovl"
		rsync -avSAXH --exclude=$KVMIMAGE.ovl --delete $KVMIMAGE /media/memory/qemu/
	else
		rsync -avSAXH --delete $KVMIMAGE /media/memory/qemu/
	fi
	IFS=' '
	#$COMMAND 
done




