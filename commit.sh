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



SYSTEM=precise1

cd /home/qemu/$SYSTEM

echo "Commit Ovl-Image: $SYSTEM.ovl"
qemu-img commit $SYSTEM.ovl
rm $SYSTEM.ovl
echo "Neues Ovl-Image anlegen: $SYSTEM.ovl"
qemu-img create -b $SYSTEM.raw -f qcow2 $SYSTEM.ovl
echo "done"
