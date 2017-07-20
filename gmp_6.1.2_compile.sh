#! /bin/sh
# Compile and install GMP v6.1.2.
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

gmp_tar_verified=false

verify_gmp_archive()
{
case $1 in
	*"GOODSIG"*)
		case $1 in
			*"VALIDSIG"*)
				# Check for fingerprint from https://gmplib.org/
				case $1 in
					*"343C2FF0FBEE5EC2EDBEF399F3599FF828C67298"*)
						gmp_tar_verified=true
					;;
				esac
			;;
		esac
	;;
esac
}

# Verify files immediately if they already exist.
if test $found_gpg_exit_code -eq 0; then
	if test -f gmp-6.1.2.tar.bz2 && test -f gmp-6.1.2.tar.bz2.sig; then
		verify_gmp_archive "$(gpg --status-fd 1 --verify gmp-6.1.2.tar.bz2.sig)"
	fi
else
	echo "error: gpg could not be found!"
	exit 1
fi

# The following runs when we need a new download of both the archive
# and its respective signature.
if ! $gmp_tar_verified; then
	if test $found_curl_exit_code -eq 0; then
		curl -O https://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.bz2
		if test $? -ne 0; then
			exit 1
		fi
	
		curl -O https://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.bz2.sig
		if test $? -ne 0; then
			exit 1
		fi
	
		if test $found_gpg_exit_code -eq 0; then
			if test -f gmp-6.1.2.tar.bz2 && test -f gmp-6.1.2.tar.bz2.sig; then
				verify_gmp_archive "$(gpg --status-fd 1 --verify gmp-6.1.2.tar.bz2.sig)"
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
if test -d gmp-6.1.2; then
	rm -rf gmp-6.1.2
fi

if $gmp_tar_verified; then
	tar -xjf gmp-6.1.2.tar.bz2
	if test $? -ne 0; then
		exit $?
	fi 
else
	echo "error: gmp-6.1.2.tar.bz2 could not be verified!"
	exit 1
fi

if test -d gmp-6.1.2; then
	cd gmp-6.1.2
else
	echo "error: The gmp-6.1.2 folder does not exist!"
	exit 1
fi

if test -f configure; then
	./configure --enable-shared --enable-static --prefix=/usr/local
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

cd ../
