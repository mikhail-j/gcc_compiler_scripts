#! /bin/sh
# Compile and install nose 1.3.7.
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

found_md5sum=$(command -v md5sum >/dev/null 2>&1)
found_md5sum_exit_code=$?

# The following runs when we need a new download of both the archive
# and its respective signature.
if test ! -f nose-1.3.7.tar.gz; then
	if test $found_curl_exit_code -eq 0; then
		curl -O https://pypi.python.org/packages/58/a5/0dc93c3ec33f4e281849523a5a913fa1eea9a3068acfa754d44d88107a44/nose-1.3.7.tar.gz
		if test $? -ne 0; then
			exit 1
		fi
	else
		echo "error: curl could not be found!"
		exit 1
	fi
fi

# Check for MD5 checksum
if test $found_md5sum_exit_code -ne 0; then
	echo "error: md5sum could not be found!"
	exit $found_md5sum_exit_code
elif test $(md5sum nose-1.3.7.tar.gz | awk '{print $1}') != "4d3ad0ff07b61373d2cefc89c5d0b20b"; then
	echo "error: found wrong md5 hash!"
	exit 1
fi

# Remove directory from previous compilation attempt (if nose-1.3.7 already exists).
if test -d nose-1.3.7; then
	rm -rf nose-1.3.7
fi


# nose archive cannot be verified, as the developer does not provide a GPG signature.
tar -xzf nose-1.3.7.tar.gz
if test $? -ne 0; then
	exit $?
fi

if test -d nose-1.3.7; then
	cd nose-1.3.7
else
	echo "error: The nose-1.3.7 folder does not exist!"
	exit 1
fi

sudo python setup.py install
if test $? -ne 0; then
	error_exit_code=$?
	echo "error: nose-1.3.7 failed to install properly!"
	exit $error_exit_code
fi

cd ../

