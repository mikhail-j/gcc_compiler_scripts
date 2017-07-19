#! /bin/sh
# Compile and install cmake 3.9.0.
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

found_sha256sum=$(command -v sha256sum >/dev/null 2>&1)
found_sha256sum_exit_code=$?

cmake_checksums_verified=false

verify_cmake_checksums()
{
case $1 in
	*"GOODSIG"*"VALIDSIG"*)
		case $1 in
			*"C6C265324BBEBDC350B513D02D2CEF1034921684"*)
				cmake_checksums_verified=true
			;;
		esac
	;;
esac
}

if test $found_curl_exit_code -ne 0; then
	echo "error: curl could not be found!"
	exit $found_curl_exit_code
elif test $found_sha256sum_exit_code -ne 0; then
	echo "error: sha256 could not be found!"
	exit $found_sha256sum_exit_code
fi

# Verify the checksum file by using the GPG key ID to obtain the public key.
gpg --keyserver pgp.mit.edu --recv-keys 0x34921684

# Verify checksums file if it already exists.
if test -f cmake-3.9.0.tar.gz && test -f cmake-3.9.0-SHA-256.txt && test -f cmake-3.9.0-SHA-256.txt.asc; then
	verify_cmake_checksums "$(gpg --status-fd 1 --verify cmake-3.9.0-SHA-256.txt.asc)"
fi

# The following runs when we need a new download of both the archive
# and its respective signature.
if ! $cmake_checksums_verified; then
	curl -O https://cmake.org/files/v3.9/cmake-3.9.0.tar.gz
	if test $? -ne 0; then
		exit $?
	fi

	curl -O https://cmake.org/files/v3.9/cmake-3.9.0-SHA-256.txt
	if test $? -ne 0; then
		exit $?
	fi

	curl -O https://cmake.org/files/v3.9/cmake-3.9.0-SHA-256.txt.asc
	if test $? -ne 0; then
		exit $?
	fi

	verify_cmake_checksums "$(gpg --status-fd 1 --verify cmake-3.9.0-SHA-256.txt.asc)"
fi

if ! $cmake_checksums_verified; then
	echo "error: cmake-3.9.0-SHA-256.txt could not be verfied!"
	exit 1
fi

# Check for SHA256 checksum
if test $(cat cmake-3.9.0-SHA-256.txt | grep "cmake-3.9.0.tar.gz" | sha256sum -c | gawk '{print $2}') != "OK"; then
	echo "error: cmake-3.9.0.tar.gz has the wrong sha256 hash!"
	exit 1
fi

# Remove directory from previous compilation attempt (if cmake-3.9.0 already exists).
if test -d cmake-3.9.0; then
	rm -rf cmake-3.9.0
fi

# Uncompress the verified archive.
tar -xzf cmake-3.9.0.tar.gz
if test $? -ne 0; then
	exit $?
fi

if test -d cmake-3.9.0; then
	cd cmake-3.9.0
else
	echo "error: The cmake-3.9.0 folder does not exist!"
	exit 1
fi

./bootstrap --prefix=/usr/local
if test $? -ne 0; then
	exit $?
fi

make
if test $? -ne 0; then
	exit $?
fi

sudo make install
if test $? -ne 0; then
	error_exit_code=$?
	echo "error: cmake-3.9.0 failed to install properly!"
	exit $error_exit_code
fi

cd ../

