#! /bin/sh
# Get and import the public keys from the latest GNU project GPG keyring.
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

found_gpg=$(command -v gpg >/dev/null 2>&1)
found_gpg_exit_code=$?


if test $found_curl_exit_code -eq 0; then
	# This script is intended to download the latest version
	# of the GNU keyring file and import the public keys.
	curl -O ftp://ftp.gnu.org/pub/gnu/gnu-keyring.gpg
	if test $? -eq 0; then
		if test $found_gpg_exit_code -eq 0; then
			gpg --import gnu-keyring.gpg
		else
			echo "error: gpg could not be found!"
		fi
	fi
else
	echo "error: curl could not be found!"
	exit 1
fi
