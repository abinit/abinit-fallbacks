# -*- Autoconf -*-
#
# Copyright (C) 2010-2014 ABINIT Group (Yann Pouillon)
#
# This file is part of the ABINIT software package. For license information,
# please see the COPYING file in the top-level directory of the ABINIT source
# distribution.
#

#
# Data management
#



# ABI_FALLBAKCS_CHECK_MD5SUM(FILE, MD5SUM)
# ----------------------------------------
#
# Checks that the specified file has the specified MD5 sum. The result
# (no, yes, unknown) is stored in the afb_md5_ok variable.
#
AC_DEFUN([AFB_CHECK_MD5SUM],[
  dnl Init
  if test "${MD5SUM}" = ""; then
    AC_CHECK_PROGS([MD5SUM],[md5sum md5])
  fi
  afb_md5_ok="unknown"

  dnl Check the MD5 sum and set afb_md5_ok accordingly
  if test "${MD5SUM}" = ""; then
    AC_MSG_WARN([no MD5 sum checker available])
    tmp_md5_file=""
  else
    tmp_md5_file=`${MD5SUM} $1 | sed -e 's/.*= //' | awk '{print [$]1}'`
  fi
  tmp_md5_ref="$2"

  AC_MSG_CHECKING([file '$1'])
  if test "${tmp_md5_file}" = "${tmp_md5_ref}"; then
    afb_md5_ok="yes"
    AC_MSG_RESULT([md5 ok])
  else
    if test "${tmp_md5_file}" = ""; then
      AC_MSG_RESULT([md5 unknown])
    else
      afb_md5_ok="no"
      AC_MSG_RESULT([md5 failed])
    fi
  fi
]) # AFB_CHECK_MD5SUM
