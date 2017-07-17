#! /bin/sh
# Compile and install MPFR 3.1.5.
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

mpfr_tar_verified=false

verify_mpfr_archive()
{
case $1 in
	*"GOODSIG"*)
		case $1 in
			*"VALIDSIG"*)
				# Check for fingerprint from https://gmplib.org/
				case $1 in
					*"07F3DBBECC1A39605078094D980C197698C3739D"*)
						mpfr_tar_verified=true
					;;
				esac
			;;
		esac
	;;
esac
}

# Get public key from pgp.mit.edu.
if test $found_gpg_exit_code -eq 0; then
	gpg --keyserver pgp.mit.edu --recv-keys 980C197698C3739D
	if test $? -ne 0; then
		exit $?
	fi
else
	echo "error: gpg could not be found!"
	exit 1
fi

# Verify files immediately if they already exist.
if test $found_gpg_exit_code -eq 0; then
	if test -f mpfr-3.1.5.tar.bz2 && test -f mpfr-3.1.5.tar.bz2.asc; then
		verify_mpfr_archive "$(gpg --status-fd 1 --verify mpfr-3.1.5.tar.bz2.asc)"
	fi
else
	echo "error: gpg could not be found!"
	exit 1
fi

# The following runs when we need a new download of both the archive
# and its respective signature.
if ! $mpfr_tar_verified; then
	if test $found_curl_exit_code -eq 0; then
		curl -O http://www.mpfr.org/mpfr-current/mpfr-3.1.5.tar.bz2
		if test $? -ne 0; then
			exit 1
		fi
	
		curl -O http://www.mpfr.org/mpfr-current/mpfr-3.1.5.tar.bz2.asc
		if test $? -ne 0; then
			exit 1
		fi
	
		if test $found_gpg_exit_code -eq 0; then
			if test -f mpfr-3.1.5.tar.bz2 && test -f mpfr-3.1.5.tar.bz2.asc; then
				verify_mpfr_archive "$(gpg --status-fd 1 --verify mpfr-3.1.5.tar.bz2.asc)"
			fi
		else
			echo "error: gpg could not be found!"
			exit 1
		fi
	else
		echo "error: curl could not be found!"
		exit 1
	fi
fi

# Remove directory from previous compilation attempt (if gmp-6.1.2 already exists).
if test -d mpfr-3.1.5; then
	rm -rf mpfr-3.1.5
fi

if $mpfr_tar_verified; then
	tar -xjf mpfr-3.1.5.tar.bz2
	if test $? -ne 0; then
		exit $?
	fi 
else
	echo "error: mpfr-3.1.5.tar.bz2 could not be verified!"
	exit 1
fi

if test -d mpfr-3.1.5; then
	cd mpfr-3.1.5 
else
	echo "error: The mpfr-3.1.5 folder does not exist!"
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
