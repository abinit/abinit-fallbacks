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



# AFB_TRICKS_XMLF90(FC_VENDOR,FC_VERSION)
# --------------------------------------
#
# Applies tricks and workarounds to have the XMLF90 library correctly
# linked to the binaries.
#
AC_DEFUN([AFB_TRICKS_XMLF90],[
  dnl Do some sanity checking of the arguments
  m4_if([$1], [], [AC_FATAL([$0: missing argument 1])])dnl
  m4_if([$2], [], [AC_FATAL([$0: missing argument 2])])dnl

  dnl Init
  afb_xmlf90_tricks="no"
  afb_xmlf90_tricky_vars=""
  tmp_xmlf90_num_tricks=2
  tmp_xmlf90_cnt_tricks=0

  dnl Configure tricks
  if test "${afb_xmlf90_cfgflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying xmlf90 tricks (vendor: $1, version: $2, flags: config)])
    dnl Internal xmlf90 parameters
    CFGFLAGS_XMLF90="--enable-static --disable-shared"

    dnl Finish
    tmp_xmlf90_cnt_tricks=`expr ${tmp_xmlf90_cnt_tricks} \+ 1`
    afb_xmlf90_tricky_vars="${afb_xmlf90_tricky_vars} CFGFLAGS"
  else
    AC_MSG_NOTICE([CFGFLAGS_XMLF90 set => skipping xmlf90 config tricks])
  fi

  dnl C tricks
  if test "${afb_xmlf90_cflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying xmlf90 tricks (vendor: $1, version: $2, flags: C)])
    case "$1" in
      ibm)
        if test "${ac_cv_prog_cc_c99}" != "no"; then
          CFLAGS_XMLF90="${CFLAGS_XMLF90} ${ac_cv_prog_cc_c99}"
        fi
        ;;
    esac

    dnl Finish
    tmp_xmlf90_cnt_tricks=`expr ${tmp_xmlf90_cnt_tricks} \+ 1`
    afb_xmlf90_tricky_vars="${afb_xmlf90_tricky_vars} CFLAGS"
  else
    AC_MSG_NOTICE([CFLAGS_XMLF90 set => skipping xmlf90 C tricks])
  fi

  dnl Count applied tricks
  case "${tmp_xmlf90_cnt_tricks}" in
    0)
      afb_xmlf90_tricks="no"
      ;;
    ${tmp_xmlf90_num_tricks})
      afb_xmlf90_tricks="yes"
      ;;
    *)
      afb_xmlf90_tricks="partial"
      ;;
  esac
  unset tmp_xmlf90_cnt_tricks
  unset tmp_xmlf90_num_tricks
]) # AFB_TRICKS_XMLF90
