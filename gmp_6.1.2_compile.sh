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
# Compile and install GMP v6.1.2.
#

FOUND_CURL=$(command -v curl >/dev/null 2>&1)
FOUND_CURL_EXIT_CODE=$?

FOUND_GPG=$(command -v gpg >/dev/null 2>&1)
FOUND_GPG_EXIT_CODE=$?

GPG_VERIFY_OUTPUT=
GMP_TAR_VERIFIED=


if test $FOUND_CURL_EXIT_CODE -eq 0; then
	curl -O https://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.bz2
	curl -O https://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.bz2.sig
	if test $FOUND_GPG_EXIT_CODE -eq 0; then
		if test -f gmp-6.1.2.tar.bz2 && test -f gmp-6.1.2.tar.bz2
			GPG_VERIFY_OUTPUT=$(gpg --verify gmp-6.1.2.tar.bz2.sig 2>&1)
		fi
	else
		echo "error: gpg could not be found!"
		exit 1
	fi
else
	echo "error: curl could not be found!"
	exit 1
fi

case "Good signature" in
	$GPG_VERIFY_OUTPUT)
	case "343C 2FF0 FBEE 5EC2 EDBE F399 F359 9FF8 28C6 7298" in
		$GPG_VERIFY_OUTPUT)
		GMP_TAR_VERIFIED=true
		;;
	esac
	;;
esac

if test $GMP_TAR_VERIFIED == true; then
	tar -xjf gmp-6.1.2.tar.bz2
else
	echo "error: gmp-6.1.2.tar.bz2 could not be verified!"
	exit 1
fi

