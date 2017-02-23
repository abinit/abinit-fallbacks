# -*- Autoconf -*-
#
# Copyright (C) 2014 ABINIT Group (Yann Pouillon)
#
# This file is part of the ABINIT software package. For license information,
# please see the COPYING file in the top-level directory of the ABINIT source
# distribution.
#



# ABI_FALLBACKS_CHECK_HDF5()
# --------------------------
#
# Check whether the specified HDF5 library is working.
#
AC_DEFUN([ABI_FALLBACKS_CHECK_HDF5],[
  dnl Init
  afb_hdf5_default_libs="-lhdf5f -lhdf5"
  afb_hdf5_has_hdrs="unknown"
  afb_hdf5_has_mods="unknown"
  afb_hdf5_has_incs="unknown"
  afb_hdf5_has_libs="unknown"
  afb_hdf5_has_par="unknown"
  afb_hdf5_ext_ok="unknown"

  dnl Prepare environment
  tmp_saved_CPPFLAGS="${CPPFLAGS}"
  tmp_saved_FCFLAGS="${FCFLAGS}"
  tmp_saved_LIBS="${LIBS}"
  CPPFLAGS="${CPPFLAGS} ${afb_hdf5_incs}"
  FCFLAGS="${FCFLAGS} ${afb_hdf5_incs}"
  if test "${afb_hdf5_libs}" = ""; then
    AC_MSG_CHECKING([for HDF5 libraries to try])
    LIBS="${afb_hdf5_default_libs} ${LIBS}"
    AC_MSG_RESULT([${afb_hdf5_default_libs}])
  else
    LIBS="${afb_hdf5_libs} ${LIBS}"
  fi

  dnl Look for C includes
  AC_LANG_PUSH([C])
  AC_CHECK_HEADERS([hdf5.h],[afb_hdf5_has_hdrs="yes"],[afb_hdf5_has_hdrs="no"])
  AC_LANG_POP([C])

  dnl Look for Fortran includes
  AC_MSG_CHECKING([for HDF5 Fortran modules])
  AC_LANG_PUSH([Fortran])
  AC_COMPILE_IFELSE([AC_LANG_PROGRAM([],
    [[
      use hdf5
    ]])], [afb_hdf5_has_mods="yes"], [afb_hdf5_has_mods="no"])
  AC_LANG_POP([Fortran])
  AC_MSG_RESULT([${afb_hdf5_has_mods}])

  dnl Check status of include files
  if test "${afb_hdf5_has_hdrs}" = "yes" -a \
          "${afb_hdf5_has_mods}" = "yes"; then
    afb_hdf5_has_incs="yes"
  else
    afb_hdf5_has_incs="no"
  fi

  dnl Check whether the Fortran wrappers work
  if test "${afb_hdf5_has_incs}" = "yes"; then
    AC_MSG_CHECKING([whether HDF5 Fortran wrappers work])
    AC_LANG_PUSH([Fortran])
    AC_LINK_IFELSE([AC_LANG_PROGRAM([],
      [[
        use hdf5
        character(len=*), parameter :: path = "dummy"
        integer :: mode, ncerr, ncid
        ncerr = nf90_open(path,mode,ncid)
      ]])], [afb_hdf5_has_libs="yes"], [afb_hdf5_has_libs="no"])
    AC_LANG_POP([Fortran])
    AC_MSG_RESULT([${afb_hdf5_has_libs}])
  fi

  dnl Final adjustments
  if test "${afb_hdf5_has_incs}" = "yes" -a \
          "${afb_hdf5_has_libs}" = "yes"; then
    afb_hdf5_ext_ok="yes"
    if test "${afb_hdf5_libs}" = ""; then
      afb_hdf5_libs="${afb_hdf5_default_libs}"
    fi
  else
    afb_hdf5_ext_ok="no"
  fi

  dnl Check for parallel I/O support
  if test "${afb_hdf5_ext_ok}" = "yes"; then
    AC_MSG_CHECKING([whether HDF5 supports parallel I/O])
    AC_LINK_IFELSE([AC_LANG_PROGRAM([],
      [[
        use hdf5
        character(len=*), parameter :: path = "dummy"
        integer :: cmode, comm, info, ncerr, ncid
        ncerr = nf90_open_par(path, cmode, comm, info, ncid)
      ]])], [afb_hdf5_has_par="yes"], [afb_hdf5_has_par="no"])
    AC_MSG_RESULT([${afb_hdf5_has_par}])
  fi

  dnl Restore environment
  CPPFLAGS="${tmp_saved_CPPFLAGS}"
  FCFLAGS="${tmp_saved_FCFLAGS}"
  LIBS="${tmp_saved_LIBS}"
]) # ABI_FALLBACKS_CHECK_HDF5
