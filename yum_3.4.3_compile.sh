#! /bin/sh
# Compile and install yum 3.4.3.
#
# This is necessary due to yum's dependency on Python 2.6.
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
if test ! -f yum-3.4.3.tar.gz; then
	if test $found_curl_exit_code -eq 0; then
		curl -O http://yum.baseurl.org/download/3.4/yum-3.4.3.tar.gz
		if test $? -ne 0; then
			exit 1
		fi
	else
		echo "error: curl could not be found!"
		exit 1
	fi
fi

# Remove directory from previous compilation attempt (if yum-3.4.3 already exists).
if test -d yum-3.4.3; then
	rm -rf yum-3.4.3
fi


# yum archive cannot be verified, as the developer does not provide a GPG signature.
tar -xzf yum-3.4.3.tar.gz
if test $? -ne 0; then
	exit $?
fi

if test -d yum-3.4.3; then
	cd yum-3.4.3
else
	echo "error: The yum-3.4.3 folder does not exist!"
	exit 1
fi

make
if test $? -ne 0; then
	exit $?
fi

make check
if test $? -ne 0; then
	exit $?
fi

make install
if test $? -ne 0; then
	echo "error: yum 3.4.3 failed to install properly!"
	exit 1
fi

cd ../

