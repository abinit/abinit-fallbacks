# -*- Autoconf -*-
#
# Copyright (C) 2006-2017 ABINIT Group (Yann Pouillon)
#
# This file is part of the ABINIT software package. For license information,
# please see the COPYING file in the top-level directory of the ABINIT source
# distribution.
#

#
# Tricks for external packages
#



# AFB_TRICKS_HDF5(FC_VENDOR,FC_VERSION)
# --------------------------------------
#
# Applies tricks and workarounds to have the HDF5 library correctly
# linked to the binaries.
#
AC_DEFUN([AFB_TRICKS_HDF5],[
  dnl Do some sanity checking of the arguments
  m4_if([$1], [], [AC_FATAL([$0: missing argument 1])])dnl
  m4_if([$2], [], [AC_FATAL([$0: missing argument 2])])dnl

  dnl Init
  afb_hdf5_tricks="no"
  afb_hdf5_tricky_vars=""
  tmp_hdf5_num_tricks=2
  tmp_hdf5_cnt_tricks=0

  dnl Configure tricks
  if test "${afb_hdf5_cfgflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying HDF5 tricks (vendor: $1, version: $2, flags: config)])
    dnl Internal HDF5 parameters
    CFGFLAGS_HDF5="--enable-static --disable-shared"

    dnl Finish
    tmp_hdf5_cnt_tricks=`expr ${tmp_hdf5_cnt_tricks} \+ 1`
    afb_hdf5_tricky_vars="${afb_hdf5_tricky_vars} CFGFLAGS"
  else
    AC_MSG_NOTICE([CFGFLAGS_HDF5 set => skipping HDF5 config tricks])
  fi

  dnl C tricks
  if test "${afb_hdf5_cflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying HDF5 tricks (vendor: $1, version: $2, flags: C)])
    case "$1" in
      ibm)
        if test "${ac_cv_prog_cc_c99}" != "no"; then
          CFLAGS_HDF5="${CFLAGS_HDF5} ${ac_cv_prog_cc_c99}"
        fi
        ;;
    esac

    dnl Finish
    tmp_hdf5_cnt_tricks=`expr ${tmp_hdf5_cnt_tricks} \+ 1`
    afb_hdf5_tricky_vars="${afb_hdf5_tricky_vars} CFLAGS"
  else
    AC_MSG_NOTICE([CFLAGS_HDF5 set => skipping HDF5 C tricks])
  fi

  dnl Count applied tricks
  case "${tmp_hdf5_cnt_tricks}" in
    0)
      afb_hdf5_tricks="no"
      ;;
    ${tmp_hdf5_num_tricks})
      afb_hdf5_tricks="yes"
      ;;
    *)
      afb_hdf5_tricks="partial"
      ;;
  esac
  unset tmp_hdf5_cnt_tricks
  unset tmp_hdf5_num_tricks
]) # AFB_TRICKS_HDF5
