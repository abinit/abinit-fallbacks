# -*- Autoconf -*-
#
# Copyright (C) 2014 ABINIT Group (Yann Pouillon)
#
# This file is part of the ABINIT software package. For license information,
# please see the COPYING file in the top-level directory of the ABINIT source
# distribution.
#



# ABI_FALLBACKS_CHECK_NETCDF_FORTRAN()
# ------------------------------------
#
# Check whether the specified NetCDF-Fortran library is working.
#
AC_DEFUN([ABI_FALLBACKS_CHECK_NETCDF_FORTRAN],[
  dnl Init
  afb_netcdf_fortran_default_libs="-lnetcdf_fortranf -lnetcdf_fortran"
  afb_netcdf_fortran_has_hdrs="unknown"
  afb_netcdf_fortran_has_mods="unknown"
  afb_netcdf_fortran_has_incs="unknown"
  afb_netcdf_fortran_has_libs="unknown"
  afb_netcdf_fortran_has_par="unknown"
  afb_netcdf_fortran_ext_ok="unknown"

  dnl Prepare environment
  tmp_saved_CPPFLAGS="${CPPFLAGS}"
  tmp_saved_FCFLAGS="${FCFLAGS}"
  tmp_saved_LIBS="${LIBS}"
  CPPFLAGS="${CPPFLAGS} ${afb_netcdf_fortran_incs}"
  FCFLAGS="${FCFLAGS} ${afb_netcdf_fortran_incs}"
  if test "${afb_netcdf_fortran_libs}" = ""; then
    AC_MSG_CHECKING([for NetCDF-Fortran libraries to try])
    LIBS="${afb_netcdf_fortran_default_libs} ${LIBS}"
    AC_MSG_RESULT([${afb_netcdf_fortran_default_libs}])
  else
    LIBS="${afb_netcdf_fortran_libs} ${LIBS}"
  fi

  dnl Look for C includes
  AC_LANG_PUSH([C])
  AC_CHECK_HEADERS([netcdf_fortran.h],[afb_netcdf_fortran_has_hdrs="yes"],[afb_netcdf_fortran_has_hdrs="no"])
  AC_LANG_POP([C])

  dnl Look for Fortran includes
  AC_MSG_CHECKING([for NetCDF-Fortran Fortran modules])
  AC_LANG_PUSH([Fortran])
  AC_COMPILE_IFELSE([AC_LANG_PROGRAM([],
    [[
      use netcdf_fortran
    ]])], [afb_netcdf_fortran_has_mods="yes"], [afb_netcdf_fortran_has_mods="no"])
  AC_LANG_POP([Fortran])
  AC_MSG_RESULT([${afb_netcdf_fortran_has_mods}])

  dnl Check status of include files
  if test "${afb_netcdf_fortran_has_hdrs}" = "yes" -a \
          "${afb_netcdf_fortran_has_mods}" = "yes"; then
    afb_netcdf_fortran_has_incs="yes"
  else
    afb_netcdf_fortran_has_incs="no"
  fi

  dnl Check whether the Fortran wrappers work
  if test "${afb_netcdf_fortran_has_incs}" = "yes"; then
    AC_MSG_CHECKING([whether NetCDF-Fortran Fortran wrappers work])
    AC_LANG_PUSH([Fortran])
    AC_LINK_IFELSE([AC_LANG_PROGRAM([],
      [[
        use netcdf_fortran
        character(len=*), parameter :: path = "dummy"
        integer :: mode, ncerr, ncid
        ncerr = nf90_open(path,mode,ncid)
      ]])], [afb_netcdf_fortran_has_libs="yes"], [afb_netcdf_fortran_has_libs="no"])
    AC_LANG_POP([Fortran])
    AC_MSG_RESULT([${afb_netcdf_fortran_has_libs}])
  fi

  dnl Final adjustments
  if test "${afb_netcdf_fortran_has_incs}" = "yes" -a \
          "${afb_netcdf_fortran_has_libs}" = "yes"; then
    afb_netcdf_fortran_ext_ok="yes"
    if test "${afb_netcdf_fortran_libs}" = ""; then
      afb_netcdf_fortran_libs="${afb_netcdf_fortran_default_libs}"
    fi
  else
    afb_netcdf_fortran_ext_ok="no"
  fi

  dnl Check for parallel I/O support
  if test "${afb_netcdf_fortran_ext_ok}" = "yes"; then
    AC_MSG_CHECKING([whether NetCDF-Fortran supports parallel I/O])
    AC_LINK_IFELSE([AC_LANG_PROGRAM([],
      [[
        use netcdf_fortran
        character(len=*), parameter :: path = "dummy"
        integer :: cmode, comm, info, ncerr, ncid
        ncerr = nf90_open_par(path, cmode, comm, info, ncid)
      ]])], [afb_netcdf_fortran_has_par="yes"], [afb_netcdf_fortran_has_par="no"])
    AC_MSG_RESULT([${afb_netcdf_fortran_has_par}])
  fi

  dnl Restore environment
  CPPFLAGS="${tmp_saved_CPPFLAGS}"
  FCFLAGS="${tmp_saved_FCFLAGS}"
  LIBS="${tmp_saved_LIBS}"
]) # ABI_FALLBACKS_CHECK_NETCDF_FORTRAN
