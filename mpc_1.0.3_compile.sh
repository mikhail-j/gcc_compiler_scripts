#! /bin/sh
# Compile and install MPC 1.0.3.
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

mpc_tar_verified=false

verify_mpc_archive()
{
case $1 in
	*"GOODSIG"*)
		case $1 in
			*"VALIDSIG"*)
				# Check for fingerprint from http://www.multiprecision.org/index.php?prog=mpc&page=download
				case $1 in
					*"AD17A21EF8AED8F1CC02DBD9F7D5C9BF765C61E3"*)
						mpc_tar_verified=true
					;;
				esac
			;;
		esac
	;;
esac
}

# Get public key from pgp.mit.edu.
if test $found_gpg_exit_code -eq 0; then
	gpg --keyserver pgp.mit.edu --recv-keys 0xF7D5C9BF765C61E3
	if test $? -ne 0; then
		exit $?
	fi
else
	echo "error: gpg could not be found!"
	exit 1
fi

# Verify files immediately if they already exist.
if test $found_gpg_exit_code -eq 0; then
	if test -f mpc-1.0.3.tar.gz && test -f mpc-1.0.3.tar.gz.sig; then
		verify_mpc_archive "$(gpg --status-fd 1 --verify mpc-1.0.3.tar.gz.sig)"
	fi
else
	echo "error: gpg could not be found!"
	exit 1
fi

# The following runs when we need a new download of both the archive
# and its respective signature.
if ! $mpc_tar_verified; then
	if test $found_curl_exit_code -eq 0; then
		curl -O ftp://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz
		if test $? -ne 0; then
			exit 1
		fi
	
		curl -O ftp://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz.sig
		if test $? -ne 0; then
			exit 1
		fi
	
		if test $found_gpg_exit_code -eq 0; then
			if test -f mpc-1.0.3.tar.gz && test -f mpc-1.0.3.tar.gz.sig; then
				verify_mpc_archive "$(gpg --status-fd 1 --verify mpc-1.0.3.tar.gz.sig)"
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

# Remove directory from previous compilation attempt (if mpc-1.0.3 already exists).
if test -d mpc-1.0.3; then
	rm -rf mpc-1.0.3
fi

if $mpc_tar_verified; then
	tar -xzf mpc-1.0.3.tar.gz
	if test $? -ne 0; then
		exit $?
	fi 
else
	echo "error: mpc-1.0.3.tar.gz could not be verified!"
	exit 1
fi

if test -d mpc-1.0.3; then
	cd mpc-1.0.3
else
	echo "error: The mpc-1.0.3 folder does not exist!"
	exit 1
fi

if test -f configure; then
	./configure --enable-static --enable-shared --prefix=/usr/local --with-gmp=/usr/local --with-mpfr=/usr/local
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
