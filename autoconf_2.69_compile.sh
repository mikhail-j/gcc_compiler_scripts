#! /bin/sh
# Compile and install autoconf 2.69.
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

autoconf_tar_verified=false

verify_autoconf_archive()
{
case $1 in
	*"GOODSIG"*)
		case $1 in
			*"VALIDSIG"*)
				case $1 in
					*"71C2CC22B1C4602927D2F3AAA7A16B4A2527436A"*)
						autoconf_tar_verified=true
					;;
				esac
			;;
		esac
	;;
esac
}

# Verify files immediately if they already exist.
if test $found_gpg_exit_code -eq 0; then
	if test -f autoconf-2.69.tar.gz && test -f autoconf-2.69.tar.gz.sig; then
		verify_autoconf_archive "$(gpg --status-fd 1 --verify autoconf-2.69.tar.gz.sig)"
	fi
else
	echo "error: gpg could not be found!"
	exit 1
fi

# The following runs when we need a new download of both the archive
# and its respective signature.
if ! $autoconf_tar_verified; then
	if test $found_curl_exit_code -eq 0; then
		curl -O https://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
		if test $? -ne 0; then
			exit 1
		fi
	
		curl -O https://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz.sig
		if test $? -ne 0; then
			exit 1
		fi
	
		if test $found_gpg_exit_code -eq 0; then
			if test -f autoconf-2.69.tar.gz && test -f autoconf-2.69.tar.gz.sig; then
				verify_autoconf_archive "$(gpg --status-fd 1 --verify autoconf-2.69.tar.gz.sig)"
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

# Remove directory from previous compilation attempt (if autoconf-2.69  already exists).
if test -d autoconf-2.69; then
	rm -rf autoconf-2.69
fi

if $autoconf_tar_verified; then
	tar -xzf autoconf-2.69.tar.gz
	if test $? -ne 0; then
		exit $?
	fi 
else
	echo "error: autoconf-2.69.tar.gz could not be verified!"
	exit 1
fi

if test -d autoconf-2.69; then
	cd autoconf-2.69
else
	echo "error: The autoconf-2.69 folder does not exist!"
	exit 1
fi

if test -f configure; then
	./configure --enable-shared --enable-static --prefix=/usr
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

# A known bug with libtool-2.4.3 (https://lists.gnu.org/archive/html/bug-autoconf/2014-11/msg00000.html), but libtool-2.4.6 seems to have the same behavior.
testsuite_error_exception()
{
case $1 in
	*"501: Libtool                                         FAILED (foreign.at:61)"*"5 failed (4 expected failures)."*)
		return 0
	;;
	*)
		return $?
	;;
esac
}

testsuite_error_exception $(make check 2>&1 | tee -a /dev/tty)

sudo make install
