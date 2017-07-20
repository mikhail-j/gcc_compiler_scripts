#! /bin/sh
# Compile and install GNU libtool 2.4.6.
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

libtool_tar_verified=false

verify_libtool_archive()
{
case $1 in
	*"GOODSIG"*)
		case $1 in
			*"VALIDSIG"*)
				case $1 in
					*"CFE2BE707B538E8B26757D84151308092983D606"*)
						libtool_tar_verified=true
					;;
				esac
			;;
		esac
	;;
esac
}

# Verify files immediately if they already exist.
if test $found_gpg_exit_code -eq 0; then
	if test -f libtool-2.4.6.tar.gz && test -f libtool-2.4.6.tar.gz.sig; then
		verify_libtool_archive "$(gpg --status-fd 1 --verify libtool-2.4.6.tar.gz.sig)"
	fi
else
	echo "error: gpg could not be found!"
	exit 1
fi

# The following runs when we need a new download of both the archive
# and its respective signature.
if ! $libtool_tar_verified; then
	if test $found_curl_exit_code -eq 0; then
		curl -O ftp://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.gz
		if test $? -ne 0; then
			exit 1
		fi
	
		curl -O ftp://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.gz.sig
		if test $? -ne 0; then
			exit 1
		fi
	
		if test $found_gpg_exit_code -eq 0; then
			if test -f libtool-2.4.6.tar.gz && test -f libtool-2.4.6.tar.gz.sig; then
				verify_libtool_archive "$(gpg --status-fd 1 --verify libtool-2.4.6.tar.gz.sig)"
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

# Remove directory from previous compilation attempt (if libtool-2.4.6 already exists).
if test -d libtool-2.4.6; then
	rm -rf libtool-2.4.6
fi

if $libtool_tar_verified; then
	tar -xzf libtool-2.4.6.tar.gz
	if test $? -ne 0; then
		exit $?
	fi 
else
	echo "error: libtool-2.4.6.tar.gz could not be verified!"
	exit 1
fi

if test -d libtool-2.4.6; then
	cd libtool-2.4.6
else
	echo "error: The libtool-2.4.6 folder does not exist!"
	exit 1
fi

if test -f configure; then
	./configure --enable-shared --enable-static
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

testsuite_error_exception()
{
case $1 in
	*"6 failed (5 expected failures)."*)
		return 0;
	;;
	*)
		return 1;
	;;
esac
}

testsuite_error_exception "$(make check 2>&1 | tee -a /dev/tty)"
if test $? -ne 0; then
	exit $?
fi

sudo make install

sudo ldconfig

cd ../
