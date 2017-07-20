#! /bin/sh
# Compile and install isl 0.14.
#
# Copyright (C) 2017 Qijia (Michael) Jin
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

found_curl=$(command -v curl >/dev/null 2>&1)
found_curl_exit_code=$?

# The following runs when we need a new download of both the archive
# and its respective signature.
if test ! -f isl-0.14.tar.gz; then
	if test $found_curl_exit_code -eq 0; then
		curl -O http://isl.gforge.inria.fr/isl-0.14.tar.gz
		if test $? -ne 0; then
			exit 1
		fi
	else
		echo "error: curl could not be found!"
		exit 1
	fi
fi

# Remove directory from previous compilation attempt (if isl-0.14 already exists).
if test -d isl-0.14; then
	rm -rf isl-0.14
fi


# isl archive cannot be verified, as the developer does not provide a GPG signature.
tar -xzf isl-0.14.tar.gz
if test $? -ne 0; then
	exit $?
fi

if test -d isl-0.14; then
	cd isl-0.14
else
	echo "error: The isl-0.14 folder does not exist!"
	exit 1
fi

if test -f configure; then
	./configure --enable-static --enable-shared --prefix=/usr/local --with-gmp=/usr/local
	if test $? -ne 0; then
		exit $?
	fi
else
	echo "error: configure was not found!"
	exit 1
fi

make -j 8
if test $? -ne 0; then
	exit $?
fi

make check
if test $? -ne 0; then
	exit $?
fi

sudo make install

sudo ldconfig

cd ../
