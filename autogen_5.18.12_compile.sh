#! /bin/sh
# Compile and install AutoGen 5.18.12.
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

autogen_tar_verified=false

found_guile=$(command -v guile >/dev/null 2>&1)
found_guile_exit_code=$?
guile_version=

# Get guile version for pkgconfig .pc file.
if test $found_guile_exit_code -eq 0; then
	guile_version_query=$(guile --version | grep "(GNU Guile)" | awk '{print $4}')
	case $guile_version_query in
		"2.0"*)
			guile_version="2.0"
		;;
		"1.8"*)
			guile_version="1.8"
		;;
	esac
fi

# AutoGen checks /usr/lib/pkgconfig rather than /usr/local/lib/pkgconfig
if test -s /usr/local/bin/guile; then
	if test -s /usr/local/lib/pkgconfig/guile-${guile_version}.pc; then
		if test -d /usr/lib/pkgconfig; then
			if ! test -s /usr/lib/pkgconfig/guile-${guile_version}.pc; then
				sudo cp /usr/local/lib/pkgconfig/guile-${guile_version}.pc /usr/lib/pkgconfig/
			fi
		elif test -d /usr/lib64/pkgconfig; then
			if ! test -s /usr/lib64/pkgconfig/guile-${guile_version}.pc; then
				sudo cp /usr/local/lib/pkgconfig/guile-${guile_version}.pc /usr/lib64/pkgconfig/
			fi
		fi
	fi
fi

verify_autogen_archive()
{
case $1 in
	*"GOODSIG"*)
		case $1 in
			*"VALIDSIG"*)
				case $1 in
					*"44A088E295C3A722C450590EC9EF76DEB74EE762"*)
						autogen_tar_verified=true
					;;
				esac
			;;
		esac
	;;
esac
}

# Verify files immediately if they already exist.
if test $found_gpg_exit_code -eq 0; then
	if test -f autogen-5.18.12.tar.gz && test -f autogen-5.18.12.tar.gz.sig; then
		verify_autogen_archive "$(gpg --status-fd 1 --verify autogen-5.18.12.tar.gz.sig)"
	fi
else
	echo "error: gpg could not be found!"
	exit 1
fi

# The following runs when we need a new download of both the archive
# and its respective signature.
if ! $autogen_tar_verified; then
	if test $found_curl_exit_code -eq 0; then
		curl -O https://ftp.gnu.org/gnu/autogen/rel5.18.12/autogen-5.18.12.tar.gz
		if test $? -ne 0; then
			exit 1
		fi
	
		curl -O https://ftp.gnu.org/gnu/autogen/rel5.18.12/autogen-5.18.12.tar.gz.sig
		if test $? -ne 0; then
			exit 1
		fi
	
		if test $found_gpg_exit_code -eq 0; then
			if test -f autogen-5.18.12.tar.gz && test -f autogen-5.18.12.tar.gz.sig; then
				verify_autogen_archive "$(gpg --status-fd 1 --verify autogen-5.18.12.tar.gz.sig)"
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

# Remove directory from previous compilation attempt (if autogen-5.18.12 already exists).
if test -d autogen-5.18.12; then
	rm -rf autogen-5.18.12
fi

if $autogen_tar_verified; then
	tar -xzf autogen-5.18.12.tar.gz
	if test $? -ne 0; then
		exit $?
	fi 
else
	echo "error: autogen-5.18.12.tar.gz could not be verified!"
	exit 1
fi

if test -d autogen-5.18.12; then
	cd autogen-5.18.12
else
	echo "error: The autogen-5.18.12 folder does not exist!"
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

make check
if test $? -ne 0; then
	exit $?
fi

sudo make install
if test $? -ne 0; then
	exit $?
fi

cd ../
