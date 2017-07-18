#! /bin/sh
# Compile and install Python 2.7.13.
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

python_tar_verified=false

build_module_error_exception()
{
case $1 in
	*"Python build finished, but the necessary bits to build these modules were not found:"*"_ssl"*)
		return 1
	;;
	*"Python build finished, but the necessary bits to build these modules were not found:"*"_curses"*)
		return 1
	;;
	*"Python build finished, but the necessary bits to build these modules were not found:"*"_sqlite3"*)
		return 1
	;;
	*"Python build finished, but the necessary bits to build these modules were not found:"*"bz2"*)
		return 1
	;;
	*"Python build finished, but the necessary bits to build these modules were not found:"*"readline"*)
		return 1
	;;
	*"Python build finished, but the necessary bits to build these modules were not found:"*"zlib"*)
		return 1
	;;
	*)
		return 0
	;;
esac
}

verify_python_archive()
{
case $1 in
	*"GOODSIG"*)
		case $1 in
			*"VALIDSIG"*)
				case $1 in
					*"C01E1CAD5EA2C4F0B8E3571504C367C218ADD4FF"*)
						python_tar_verified=true
					;;
				esac
			;;
		esac
	;;
esac
}

# Get public key from pgp.mit.edu.
if test $found_gpg_exit_code -eq 0; then
	gpg --keyserver pgp.mit.edu --recv-keys 0x6A45C816 0x36580288 0x7D9DC8D2 0x18ADD4FF 0xA4135B38 0xA74B06BF 0xEA5BBD71 0xED9D77D5 0xE6DF025C 0xAA65421D 0x6F5E1540 0xF73C700D 0x487034E5
	if test $? -ne 0; then
		exit $?
	fi
else
	echo "error: gpg could not be found!"
	exit 1
fi

# Verify files immediately if they already exist.
if test $found_gpg_exit_code -eq 0; then
	if test -f Python-2.7.13.tgz && test -f Python-2.7.13.tgz.asc; then
		verify_python_archive "$(gpg --status-fd 1 --verify Python-2.7.13.tgz.asc)"
	fi
else
	echo "error: gpg could not be found!"
	exit 1
fi

# The following runs when we need a new download of both the archive
# and its respective signature.
if ! $python_tar_verified; then
	if test $found_curl_exit_code -eq 0; then
		curl -O https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tgz
		if test $? -ne 0; then
			exit 1
		fi
	
		curl -O https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tgz.asc
		if test $? -ne 0; then
			exit 1
		fi
	
		if test $found_gpg_exit_code -eq 0; then
			if test -f Python-2.7.13.tgz && test -f Python-2.7.13.tgz.asc; then
				verify_python_archive "$(gpg --status-fd 1 --verify Python-2.7.13.tgz.asc)"
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

# Remove directory from previous compilation attempt (if Python-2.7.13 already exists).
if test -d Python-2.7.13; then
	rm -rf Python-2.7.13
fi

if $python_tar_verified; then
	tar -xzf Python-2.7.13.tgz
	if test $? -ne 0; then
		exit $?
	fi 
else
	echo "error: Python-2.7.13.tgz could not be verified!"
	exit 1
fi

if test -d Python-2.7.13; then
	cd Python-2.7.13
else
	echo "error: The mpc-1.0.3 folder does not exist!"
	exit 1
fi

if test -f configure; then
	./configure --enable-static --enable-shared --prefix=/usr --enable-ipv6 --with-system-ffi
	if test $? -ne 0; then
		exit $?
	fi
else
	echo "error: configure was not found!"
	exit 1
fi

build_module_error_exception "$(make -j 8 2>&1 | tee -a /dev/tty)"
if test $? -ne 0; then
	exit $?
fi

sudo make altinstall
