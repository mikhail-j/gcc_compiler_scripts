#! /bin/sh
# Compile and install yum 3.4.3 on CentOS 6 (experimental).
#
# This is necessary due to yum's dependency on Python 2.6.
#
# Note: The compiled yum 3.4.3 will try and fail to import
# the "refresh-packagekit" yum plugin when using yum.
#
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

# Update nose to use Python 2.7
sh ./nose_1.3.7_compile.sh
if test $? -ne 0; then
	exit $?
fi

found_curl=$(command -v curl >/dev/null 2>&1)
found_curl_exit_code=$?

found_md5sum=$(command -v md5sum >/dev/null 2>&1)
found_md5sum_exit_code=$?

found_git=$(command -v git >/dev/null 2>&1)
found_git_exit_code=$?

if test $found_curl_exit_code -ne 0; then
	echo "error: curl could not be found!"
	exit $found_curl_exit_code
elif test $found_md5sum_exit_code -ne 0; then
	echo "error: md5sum could not be found!"
	echo $found_md5sum_exit_code
elif test $found_git_exit_code -ne 0; then
	echo "error: git could not be found!"
	exit $found_git_exit_code
fi

# The following runs when we need a new download of both the archive
# and its respective signature.
if test ! -f setuptools-36.2.0.zip; then
	curl -O https://pypi.python.org/packages/25/c1/344fdd1f543cba2d38c6fb7db86f2ffc468e72006487005e50df08f0243d/setuptools-36.2.0.zip
	if test $? -ne 0; then
		exit 1
	fi
fi
# Now get pip-9.0.1.tar.gz
if test ! -f pip-9.0.1.tar.gz; then
	curl -O https://pypi.python.org/packages/11/b6/abcb525026a4be042b486df43905d6893fb04f05aac21c32c638e939e447/pip-9.0.1.tar.gz
	if test $? -ne 0; then
		exit 1
	fi
fi

# Check for MD5 checksum
if test $(md5sum setuptools-36.2.0.zip | awk '{print $1}') != "60df703040ad8024d24727dc95483740"; then
	echo "error: found wrong md5 hash for setuptools-36.2.0.zip!"
	exit 1
elif test $(md5sum pip-9.0.1.tar.gz | awk '{print $1}') != "35f01da33009719497f01a4ba69d63c9"; then
	echo "error: found wrong md5 hash for pip-9.0.1.tar.gz!"
	exit 1
fi

# Install setuptools first

# Remove directory from previous compilation attempt (if setuptools-36.2.0 already exists).
if test -d setuptools-36.2.0; then
	rm -rf setuptools-36.2.0
fi


# setuptools archive cannot be verified, as the developer does not provide a GPG signature.
unzip setuptools-36.2.0.zip
if test $? -ne 0; then
	exit $?
fi

if test -d setuptools-36.2.0; then
	cd setuptools-36.2.0
else
	echo "error: The setuptools-36.2.0 folder does not exist!"
	exit 1
fi

sudo python setup.py install
if test $? -ne 0; then
	error_exit_code=$?
	echo "error: setuptools-36.2.0 failed to install properly!"
	exit $error_exit_code
fi

cd ../

# setuptools should be installed by now, pip can now be installed.

# Remove directory from previous compilation attempt (if pip-9.0.1 already exists).
if test -d pip-9.0.1; then
        rm -rf pip-9.0.1
fi


# pip archive cannot be verified, as the developer does not provide a GPG signature.
tar -xzf pip-9.0.1.tar.gz
if test $? -ne 0; then
        exit $?
fi

if test -d pip-9.0.1; then
        cd pip-9.0.1
else
        echo "error: The pip-9.0.1 folder does not exist!"
        exit 1
fi

sudo python setup.py install
if test $? -ne 0; then
	error_exit_code=$?
	echo "error: pip-9.0.1 failed to install properly!"
        exit $error_exit_code
fi

cd ../

# Use pip to install urlgrabber and pycurl.
sudo python -m pip install urlgrabber
if test $? -ne 0; then
	exit $?
fi

sudo python -m pip install pycurl
if test $? -ne 0; then
	exit $?
fi

# Install yum-metadata-parser
if test -d yum-metadata-parser; then
	rm -rf yum-metadata-parser
fi

git clone https://github.com/rpm-software-management/yum-metadata-parser
if test $? -ne 0; then
	error_exit_code=$?
	echo "error: git failed to clone yum-metadata-parser repository!"
	exit $error_exit_code
fi

if test -d yum-metadata-parser; then
	cd yum-metadata-parser
else
	echo "error: The yum-metadata-parser folder does not exist!"
	exit 1
fi

python setup.py build
if test $? -ne 0; then
	exit $?
fi

sudo python setup.py install --prefix=/usr
if test $? -ne 0; then
	error_exit_code=$?
	echo "error: yum-meta-data-parser failed to install properly!"
	exit $error_exit_code
fi

cd ../

# Install yum-utils
if test -d yum-utils; then
	rm -rf yum-utils
fi
git clone https://github.com/rpm-software-management/yum-utils
if test $? -ne 0; then
	error_exit_code=$?
	echo "error: git failed to clone yum-utils repository!"
	exit $error_exit_code
fi

if test -d yum-utils; then
	cd yum-utils
else
	echo "error: The yum-utils folder does not exist!"
	exit 1
fi

make -j 8
if test $? -ne 0; then
	exit $?
fi

sudo make install
if test $? -ne 0; then
	error_exit_code=$?
	echo "error: yum-utils failed to install properly!"
	exit $error_exit_code
fi

cd ../

# sudo make install moved yumutils to the wrong directory
sudo cp -R /root/usr/lib/python2.7/site-packages/yumutils /usr/lib/python2.7/site-packages/
if test $? -ne 0; then
	exit $?
fi

# Use installed Python 2.6 'rpm' module in Python 2.7.
sudo cp -R /usr/lib64/python2.6/site-packages/rpm /usr/lib/python2.7/site-packages/
if test $? -ne 0; then
        exit $?
fi

# Install yum 3.4.3 now
sudo sh yum_3.4.3_compile.sh
if test $? -ne 0; then
        exit $?
fi

# Move the installed packages (yum and rpmUtils) from /root/usr/lib/python2.7/site-packages to /usr/lib/python2.7/site-packages
sudo cp -R /root/usr/lib/python2.7/site-packages/yum /usr/lib/python2.7/site-packages/
if test $? -ne 0; then
        exit $?
fi

sudo cp -R /root/usr/lib/python2.7/site-packages/rpmUtils /usr/lib/python2.7/site-packages/
if test $? -ne 0; then
        exit $?
fi


