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



# AFB_TRICKS_LIBXC(FC_VENDOR,FC_VERSION)
# --------------------------------------
#
# Applies tricks and workarounds to have the LIBXC library correctly
# linked to the binaries.
#
AC_DEFUN([AFB_TRICKS_LIBXC],[
  dnl Do some sanity checking of the arguments
  m4_if([$1], [], [AC_FATAL([$0: missing argument 1])])dnl
  m4_if([$2], [], [AC_FATAL([$0: missing argument 2])])dnl

  dnl Init
  afb_libxc_tricks="no"
  afb_libxc_tricky_vars=""
  tmp_libxc_num_tricks=2
  tmp_libxc_cnt_tricks=0

  dnl Configure tricks
  if test "${afb_libxc_cfgflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying LibXC tricks (vendor: $1, version: $2, flags: config)])
    dnl Internal LibXC parameters
    dnl Problem with NAG 7.1 -> --disable-fortran
    CFGFLAGS_LIBXC="--enable-kxc --disable-fortran --enable-static --disable-shared"
    case "$1" in
      intel)
        dnl trick for zenobe
        AC_MSG_NOTICE([
            Disabling optimization in libxc (-O0) else compilation with intel gets stuck
        ])
        CFLAGS_LIBXC="${CFLAGS_LIBXC} -traceback -Wall -O0 -fp-model=precise"
        ;;
    esac

    dnl Finish
    tmp_libxc_cnt_tricks=`expr ${tmp_libxc_cnt_tricks} \+ 1`
    afb_libxc_tricky_vars="${afb_libxc_tricky_vars} CFGFLAGS"
  else
    AC_MSG_NOTICE([CFGFLAGS_LIBXC set => skipping LibXC config tricks])
  fi

  dnl C tricks
  if test "${afb_libxc_cflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying LibXC tricks (vendor: $1, version: $2, flags: C)])
    case "$1" in
      ibm)
        if test "${ac_cv_prog_cc_c99}" != "no"; then
          CFLAGS_LIBXC="${CFLAGS_LIBXC} ${ac_cv_prog_cc_c99}"
        fi
        ;;
    esac

    dnl Finish
    tmp_libxc_cnt_tricks=`expr ${tmp_libxc_cnt_tricks} \+ 1`
    afb_libxc_tricky_vars="${afb_libxc_tricky_vars} CFLAGS"
  else
    AC_MSG_NOTICE([CFLAGS_LIBXC set => skipping LibXC C tricks])
  fi

  dnl Count applied tricks
  case "${tmp_libxc_cnt_tricks}" in
    0)
      afb_libxc_tricks="no"
      ;;
    ${tmp_libxc_num_tricks})
      afb_libxc_tricks="yes"
      ;;
    *)
      afb_libxc_tricks="partial"
      ;;
  esac
  unset tmp_libxc_cnt_tricks
  unset tmp_libxc_num_tricks
]) # AFB_TRICKS_LIBXC
