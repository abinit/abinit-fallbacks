# -*- Autoconf -*-
#
# Copyright (C) 2014 ABINIT Group (Yann Pouillon)
#
# This file is part of the ABINIT software package. For license information,
# please see the COPYING file in the top-level directory of the ABINIT source
# distribution.
#



# ABI_FALLBACKS_CHECK_ETSF_IO()
# -----------------------------
#
# Check whether the specified ETSF_IO library is working.
#
AC_DEFUN([ABI_FALLBACKS_CHECK_ETSF_IO],[
  dnl Init
  afb_etsf_io_default_libs="-letsf_io_utils -letsf_io -letsf_io_low_level"
  afb_etsf_io_has_incs="unknown"
  afb_etsf_io_has_libs="unknown"
  afb_etsf_io_ext_ok="unknown"

  dnl Check NetCDF status
  if test "${afb_netcdf_ok}" = "yes"; then

    dnl Prepare environment
    tmp_saved_FCFLAGS="${FCFLAGS}"
    tmp_saved_LIBS="${LIBS}"
    FCFLAGS="${FCFLAGS} ${afb_netcdf_incs} ${afb_etsf_io_incs}"
    LIBS="${afb_netcdf_libs} ${LIBS}"
    if test "${afb_etsf_io_libs}" = ""; then
      AC_MSG_CHECKING([for ETSF_IO libraries to try])
      LIBS="${afb_etsf_io_default_libs} ${LIBS}"
      AC_MSG_RESULT([${afb_etsf_io_default_libs}])
    else
      LIBS="${afb_etsf_io_libs} ${LIBS}"
    fi

    dnl Look for Fortran includes
    AC_MSG_CHECKING([for ETSF_IO Fortran modules])
    AC_LANG_PUSH([Fortran])
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM([],
      [[
        use etsf_io
      ]])], [afb_etsf_io_has_incs="yes"], [afb_etsf_io_has_incs="no"])
    AC_LANG_POP([Fortran])
    AC_MSG_RESULT([${afb_etsf_io_has_incs}])

    dnl Look for libraries and routines
    if test "${afb_etsf_io_has_incs}" = "yes"; then
      AC_MSG_CHECKING([whether ETSF_IO libraries work])
      AC_LANG_PUSH([Fortran])
      AC_LINK_IFELSE([AC_LANG_PROGRAM([],
        [[
          use etsf_io_low_level
          use etsf_io
          use etsf_io_tools
          character(len=etsf_charlen),allocatable :: atoms(:)
          integer :: ncid
          logical :: lstat
          type(etsf_io_low_error) :: err
          call etsf_io_tools_get_atom_names(ncid,atoms,lstat,err)
        ]])], [afb_etsf_io_has_libs="yes"], [afb_etsf_io_has_libs="no"])
      AC_LANG_POP([Fortran])
      AC_MSG_RESULT([${afb_etsf_io_has_libs}])
    fi

    dnl Final adjustments
    if test "${afb_etsf_io_has_incs}" = "yes" -a \
            "${afb_etsf_io_has_libs}" = "yes"; then
      afb_etsf_io_ext_ok="yes"
      if test "${afb_etsf_io_libs}" = ""; then
        afb_etsf_io_libs="${afb_etsf_io_default_libs}"
      fi
    else
      afb_etsf_io_ext_ok="no"
    fi

    dnl Restore environment
    FCFLAGS="${tmp_saved_FCFLAGS}"
    LIBS="${tmp_saved_LIBS}"

  else

    AC_MSG_WARN([ETSF_IO cannot be checked because NetCDF does not work])
    afb_etsf_io_ext_ok="no"

  fi
]) # ABI_FALLBACKS_CHECK_ETSF_IO
