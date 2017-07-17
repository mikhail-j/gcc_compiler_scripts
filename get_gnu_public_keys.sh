#!/bin/sh
# Copyright (C) 2017 Qijia (Michael) Jin
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
#
#
# Get and import the public keys from the latest GNU project GPG keyring.
#

FOUND_CURL=$(command -v curl >/dev/null 2>&1)
FOUND_CURL_EXIT_CODE=$?

FOUND_GPG=$(command -v gpg >/dev/null 2>&1)
FOUND_GPG_EXIT_CODE=$?


if test $FOUND_CURL_EXIT_CODE -eq 0; then
	# This script is intended to download the latest version
	# of the GNU keyring file and import the public keys.
	curl -O ftp://ftp.gnu.org/pub/gnu/gnu-keyring.gpg
	if test $? -eq 0 && test $FOUND_GPG_EXIT_CODE -eq 0; then
		gpg --import gnu-keyring.gpg
	fi
else
	echo "error: curl could not be found!"
fi
