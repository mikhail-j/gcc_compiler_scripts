#! /bin/sh
# Compile and install GCC 4.8.5.
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

gcc_tar_verified=false

# Set LD_LIBRARY_PATH
case $LD_LIBRARY_PATH in
	'')
		export LD_LIBRARY_PATH=/usr/local/lib
	;;
	*"/usr/local/lib"*)
	;;
	*)
		export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
	;;
esac

verify_gcc_archive()
{
case $1 in
	*"GOODSIG"*)
		case $1 in
			*"VALIDSIG"*)
				# Check for fingerprint from https://gcc.gnu.org/mirrors.html
				case $1 in
					*"7F74F97C103468EE5D750B583AB00996FC26A641"*)
						gcc_tar_verified=true
					;;
				esac
			;;
		esac
	;;
esac
}

# Verify files immediately if they already exist.
if test $found_gpg_exit_code -eq 0; then
	if test -f gcc-4.8.5.tar.bz2 && test -f gcc-4.8.5.tar.bz2.sig; then
		verify_gcc_archive "$(gpg --status-fd 1 --verify gcc-4.8.5.tar.bz2.sig)"
	fi
else
	echo "error: gpg could not be found!"
	exit 1
fi

# The following runs when we need a new download of both the archive
# and its respective signature.
if ! $gcc_tar_verified; then
	if test $found_curl_exit_code -eq 0; then
		curl -O http://mirrors.kernel.org/gnu/gcc/gcc-4.8.5/gcc-4.8.5.tar.bz2
		if test $? -ne 0; then
			exit 1
		fi
	
		curl -O http://mirrors.kernel.org/gnu/gcc/gcc-4.8.5/gcc-4.8.5.tar.bz2.sig
		if test $? -ne 0; then
			exit 1
		fi
	
		if test $found_gpg_exit_code -eq 0; then
			if test -f gcc-4.8.5.tar.bz2 && test -f gcc-4.8.5.tar.bz2.sig; then
				verify_gcc_archive "$(gpg --status-fd 1 --verify gcc-4.8.5.tar.bz2.sig)"
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

# Remove directory from previous compilation attempt (if gcc-4.8.5 already exists).
if test -d gcc-4.8.5; then
	rm -rf gcc-4.8.5
fi

if $gcc_tar_verified; then
	tar -xjf gcc-4.8.5.tar.bz2
	if test $? -ne 0; then
		exit $?
	fi 
else
	echo "error: gcc-4.8.5.tar.bz2 could not be verified!"
	exit 1
fi

if test -d gcc-4.8.5; then
	cd gcc-4.8.5
else
	echo "error: The gcc-4.8.5 folder does not exist!"
	exit 1
fi

if test -f configure; then
	./configure --enable-languages=c,c++,fortran --enable-static --enable-shared --enable-threads=posix --enable-checking=release --enable-ssp --disable-libssp --with-system-zlib --enable-__cxa_atexit --enable-libstdcxx-allocator=new --prefix=/usr --program-suffix=-4.8 --with-gmp=/usr/local --with-mpfr=/usr/local --with-mpc=/usr/local --with-isl=/usr/local
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
