#!/bin/bash -e

if [ -z "$TRAVIS_BUILD_DIR" ] ; then
	header="../iio.h"
else
	header="$TRAVIS_BUILD_DIR/iio.h"
fi

cat <<EOF
.\" Copyright (c) 2018-2020 Robin Getz
.\" Copyright (c) 2018-2020 Analog Devices Inc.
.\"
.\" %%%LICENSE_START(GPLv2+_DOC_FULL)
.\" This is free documentation; you can redistribute it and/or
.\" modify it under the terms of the GNU General Public License as
.\" published by the Free Software Foundation; either version 2 of
.\" the License, or (at your option) any later version.
.\"
.\" The GNU General Public License's references to "object code"
.\" and "executables" are to be interpreted as the output of any
.\" document formatting or typesetting system, including
.\" intermediate and printed output.
.\"
.\" This manual is distributed in the hope that it will be useful,
.\" but WITHOUT ANY WARRANTY; without even the implied warranty of
.\" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
.\" GNU General Public License for more details.
.\"
.\" You should have received a copy of the GNU General Public
.\" License along with this manual; if not, see
.\" <http://www.gnu.org/licenses/>.
.\" %%%LICENSE_END
.\"
.\" This file is autogenerated, and should not be editted
.\"
.if n .po 0
.TH INTRO 3LIBIIO "@CMAKE_DATE@" "libiio-@LIBIIO_VERSION_MAJOR@.@LIBIIO_VERSION_MINOR@"
.SH NAME
libiio-@LIBIIO_VERSION_MAJOR@.@LIBIIO_VERSION_MINOR@ \- introduction to
.IR libiio ,
a library for interacting with the Linux
.SM IIO
subsystem and devices
.SH SYNOPSIS
.B "#include <iio.h>"
.sp
cc file.c
.B -liio
.SH OPTIONS
The define
.B
IIO_CHECK_REG
will warn if return values are not checked. Most
.B
libiio
functions, if/when a failure occurs will return a negative error number.
this warning will ensure these error numbers are looked at. There is
nothing more frustraining than calling a function, debugging some hardware,
and then eventually realizing there was a typo in an attribute name.
This option will force libraries users to at least capture the return value.
.sp
cc file.c
.B -DIIO_CHECK_REG -liio

.SH DESCRIPTION
.I libiio
is a library used to interface to the
.I "Linux Industrial Input/Output (IIO)"
Subsystem. The Linux
.I IIO
subsystem is intended to provide support for devices that in some sense
are analog to digital or digital to analog converters (ADCs, DACs). This
includes, but is not limited to ADCs, Accelerometers, Gyros, IMUs,
Capacitance to Digital Converters (CDCs), Pressure Sensors, Color,
Light and Proximity Sensors, Temperature Sensors, Magnetometers, DACs,
DDS (Direct Digital Synthesis), PLLs (Phase Locked Loops),
Variable/Programmable Gain Amplifiers (VGA, PGA), and RF transceivers.
You can use
.I libiio
natively on an embedded Linux target (local mode), or use libiio to
communicate remotely to that same target from a host Linux, Windows
or MAC over USB, Ethernet or Serial.
.SH "DATA TYPES"
The library makes use of C structures and typedefs to promote portability,
and is known to run on various GNU/Linux distributions, macOS,
Windows, and mbed (via tiny-iiod). The main C structures are:
.in +.5i
EOF

tmp=$(grep @struct "${header}" | sed 's:^[[:space:]]*\*[[:space:]]*@::g' | awk '{print length($0)}' | sort -n | tail -1)
echo  .TP $((tmp - 5))

grep @struct ../iio.h -A 1 | \
	sed -e 's:^[[:space:]]*\*[[:space:]]*@::g' \
       	    -e 's:struct[[:space:]]*:.TP\n.B :' \
	    -e 's:brief[[:space:]]*::' \
	    -e 's:[[:space:]]*\*\/[[:space:]]*::' \
	    -e '/^--$/d'

cat <<EOF
.LP
.in -.5i
.SH "LIST OF ROUTINES"
The following routines are part of the library. Consult the Doxygen pages
for details on their operation (in the SEE ALSO section).
EOF

IFS="
"
long=0
longest=""

#go over things by groups
for i in $(grep -e defgroup "${header}" |sed 's|\/\*\*[[:space:]]*||')
do
	echo .sp
	echo "${i//@defgroup /}"

	n=$(grep -e defgroup "${header}" | grep -A 1 "$i" | tail -1 | sed 's|\/\*\*[[:space:]]*||')
	f=$(awk "/${i}/{f=1;next} /${n}/{f=0} f" "${header}" | grep __api | \
		awk 'split(substr($0, match($0, /iio[a-z_]*\(/)), a, " ") {print a[1]}' | \
		sed 's/(.*$//' | grep -ve "^#undef")
	for func in ${f}
	do
		if [ $(echo "$func" | wc -c) -gt "$long" ] ; then
			long=$(echo "$func" | wc -c)
			longest=$func
		fi
	done
	echo .in +.5i
	echo .TP $(echo "${longest}" | wc -c)
	echo .TP
	echo "\fIFunction\fP"
	echo "\fIDescription\fP"

	for func in ${f}
	do
		echo -e ".TP\n.B ${func}"
		l=$(grep -B 40 "${func}" "${header}" | \
			grep @brief | \
			tail -1 | \
			awk '{$1=$2=""; print $0}'| \
			sed -e 's:^[[:space:]]*::' -e 's:(.*<.*)::')
		echo "${l}"
	done
	echo .LP

done

cat <<EOF
.SH DIAGNOSTICS
All error codes are returned as negative number return codes.
In these cases, the value can be passed to the
.IR iio_strerror
routine.
.SH "SEE ALSO"
.BR iio_attr (1),
.BR iio_info (1),
.BR iio_readdev (1),
.BR iio_writedev (1),
.BR iio_reg (1)
.PP
.nh
libiio home page:
.br
.BR \%https://wiki.analog.com/resources/tools-software/linux-software/libiio
.PP
libiio code:
.br
.BR \%https://github.com/analogdevicesinc/libiio
.PP
Doxygen for libiio:
.br
.BR \%https://analogdevicesinc.github.io/libiio/
.PP
Kernel Doc:
.br
.BR \%https://www.kernel.org/doc/html/latest/driver-api/iio/index.html
.BR \%https://www.kernel.org/doc/Documentation/ABI/testing/sysfs-bus-iio
.SH BUGS
.ad l
All bugs are tracked at:
.BR \%https://github.com/analogdevicesinc/libiio/issues
.hy
.ad b
.SH LICENSE
The
.IR libiio
source code and resulting binaries (libraries) are released and distributed under the GNU Lesser General Public License, v2.1 or (at your option) any later version.
.br
The
.IR libiio
test and example application(s) source code and resulting binaries (executables) are released and distributed under the GNU General Public License, v2.0  or (at your option) any later version.
.br
The
.IR libiio
man pages are released and distributed under the Creative Commons Attribution-ShareAlike 4.0 International Public License.
EOF
