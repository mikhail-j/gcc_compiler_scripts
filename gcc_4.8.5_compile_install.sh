#! /bin/sh
# Compile and install GCC 4.8.5.
#
# Compiling on CentOS requires the 'glibc-devel.i686' package
# to fix dependency on 'gnu/stubs-32.h'.
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

# Get GNU project public keys.
sh ./get_gnu_public_keys.sh
if test $? -ne 0; then
	exit $?
fi

# Build GMP 6.1.2 and install.
sh ./gmp_6.1.2_compile.sh
if test $? -ne 0; then
	exit $?
fi

# Build MPFR 3.1.5 and install.
sh ./mpfr_3.1.5_compile.sh
if test $? -ne 0; then
	exit $?
fi

# Build MPC 1.0.3 and install.
sh ./mpc_1.0.3_compile.sh
if test $? -ne 0; then
	exit $?
fi

# Build ISL 0.14 and install.
sh ./isl_0.14_compile.sh
if test $? -ne 0; then
	exit $?
fi

# Build Libtool 2.4.6 and install.
sh ./libtool_2.4.6_compile.sh
if test $? -ne 0; then
	exit $?
fi

# Build Guile 2.0.13 and install.
sh ./guile_2.0.13_compile.sh
if test $? -ne 0; then
	exit $?
fi

# Build AutoGen 5.18.12 and install.
sh ./autogen_5.18.12_compile.sh
if test $? -ne 0; then
	exit $?
fi

# Build GCC 4.8.5 and install.
sh ./gcc_4.8.5_compile.sh
if test $? -ne 0; then
	exit $?
fi
