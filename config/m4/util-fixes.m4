# -*- Autoconf -*-
#
# Copyright (C) 2006-2014 ABINIT Group (Yann Pouillon)
#
# This file is part of the ABINIT software package. For license information,
# please see the COPYING file in the top-level directory of the ABINIT source
# distribution.
#



# AX_PROG_MKDIR_P()
# -----------------
#
# Wrapper for the bugged AC_PROG_MKDIR_P macro.
#
AC_DEFUN([AX_PROG_MKDIR_P],[
  AC_PROG_MKDIR_P
  ax_tmp_mkdir_p=`echo "${MKDIR_P}" | awk '{print [$]1}'`
  if test "${ax_tmp_mkdir_p}" = "config/gnu/install-sh"; then
    AC_MSG_NOTICE([fixing wrong path to mkdir replacement])
    MKDIR_P="${ac_abs_top_srcdir}/${MKDIR_P}"
  fi
  unset ax_tmp_mkdir_p
]) # AX_PROG_MKDIR_P



# AX_CHECK_ZLIB()
# ---------------
#
# Check that zlib is usable and add flags to LIBS_NETCDF4_FORTRAN.
#
AC_DEFUN([AX_CHECK_ZLIB],
[
if test "${enable_netcdf4_fortran}" = "yes"; then 
    AC_CHECK_LIB(z, deflate,
    [
        LIBS_NETCDF4_FORTRAN="$LIBS_NETCDF4_FORTRAN -lz"
    ],
    [
        AC_MSG_WARN([zlib is not usable. Compilation will continue but netcdf4_fortran may fail.
                    It is suggested that you specify zlib library flags, for example
                    LIBS_NETCDF4_FORTRAN="-L/usr/local/lib -lz"])
    ])
fi
]) # AX_CHECK_ZLIB


# AX_CHECK_CURL()
# ---------------
#
# Check that curl is usable and add flags to LIBS_NETCDF4_FORTRAN.
#
AC_DEFUN([AX_CHECK_CURL],
[
if test "${enable_netcdf4_fortran}" = "yes"; then 
    AC_CHECK_LIB(curl, curl_url,
    [
        LIBS_NETCDF4_FORTRAN="$LIBS_NETCDF4_FORTRAN -lcurl"
    ],
    [
        AC_MSG_WARN([libcurl is not usable. Compilation will continue but netcdf4_fortran may fail.
                    It is suggested that you specify curl library flags, for example
                    LIBS_NETCDF4_FORTRAN="-L/usr/local/lib -lcurl"])
    ])
fi
]) # AX_CHECK_CURL
