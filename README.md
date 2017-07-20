# GCC Compiler Scripts

A collection of shell scripts to compile GCC and the required libraries and some of the GNU autotools.

Building GCC 4.8.5
------------------

The shell scripts currently require curl (to download archives) and gpg (to verify archives when possible).

In addition, the following packages must be installed:

* glibc-devel (both 32-bit and 64-bit packages)

Centos/Red Hat

~~~~
glibc-devel (64-bit)
glibc-devel.i686 (32-bit)
~~~~

Ubuntu

~~~~
libc6-dev (64-bit)
libc6-dev-i386 (32-bit)
~~~~

SUSE SLES

~~~~
glibc-devel (32-bit)
glibc-devel-32bit (64-bit)
~~~~

* libunistring and libunistring-devel (for GNU Guile)
* libffi-devel (for GNU Guile)
* gc and gc-devel (for GNU Guile)

Assuming that your operating system's libraries are inadequate for compiling GCC 4.8.5, the following libraries would be installed in this order:

* [GMP 6.1.2](https://gmplib.org/)
* [MPFR 3.1.5](http://www.mpfr.org/)
* [MPC 1.0.3](http://www.multiprecision.org/index.php?prog=mpc)
* [ISL (Integer Set Library) 0.14](http://isl.gforge.inria.fr/)
* [GNU libtool 2.4.6](https://www.gnu.org/software/libtool/)
* [GNU Guile 2.0.13](https://www.gnu.org/software/guile/)
* [GNU AutoGen 5.18.12](https://www.gnu.org/software/autogen/)

Installing GCC 4.8.5
--------------------

When configuring GCC 4.8.5, we can specify which languages to build. By default, the shell script will build and install the gcc, g++, and gfortran binaries.

After the binaries install, it is up to you to create a symbolic link to binaries with:

~~~~
sudo ln -s /usr/bin/gcc-4.8 /usr/bin/gcc
sudo ln -s /usr/bin/g++-4.8 /usr/bin/g++
sudo ln -s /usr/bin/gfortran-4.8 /usr/bin/gfortran
~~~~

Additional Shell Scripts
------------------------

* CMake 3.9.0
* Python 2.7.13
* nose 1.3.7 (provides nosetests executable)
* yum 3.4.3 *experimental* (fails to pass checks without 'rpm' python module)
* CentOS 6 Python 2.6 to 2.7 Migration *experimental* (change yum's dependency on Python 2.6 to 2.7)
