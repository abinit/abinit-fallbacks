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



# AFB_TRICKS_ELPA(FC_VENDOR,FC_VERSION)
# -------------------------------------
#
# Applies tricks and workarounds to have the ELPA library correctly
# linked to the binaries.
#
AC_DEFUN([AFB_TRICKS_ELPA],[
  dnl Do some sanity checking of the arguments
  m4_if([$1], [], [AC_FATAL([$0: missing argument 1])])dnl
  m4_if([$2], [], [AC_FATAL([$0: missing argument 2])])dnl

  dnl Init
  afb_elpa_tricks="no"
  afb_elpa_tricky_vars=""
  tmp_elpa_num_tricks=2
  tmp_elpa_cnt_tricks=0

  AC_ARG_ENABLE(elpa-openmp,
    AS_HELP_STRING([--enable-elpa-openmp],
      [Activate support for OpenMP in ELPA (default: no)]),
    [afb_elpa_enable_openmp="${enableval}"],
    [afb_elpa_enable_openmp="no"])
  AC_MSG_NOTICE([ELPA OpenMP support: ${afb_elpa_enable_openmp}])

  AC_ARG_ENABLE(elpa-simd,
    AS_HELP_STRING([--disable-elpa-simd],
      [Build only the generic ELPA kernels instead of the SIMD kernels supported by the build host, e.g. for heterogeneous clusters (default: enabled)]),
    [afb_elpa_enable_simd="${enableval}"],
    [afb_elpa_enable_simd="yes"])
  AC_MSG_NOTICE([ELPA SIMD kernels: ${afb_elpa_enable_simd}])

  dnl Configure tricks
  if test "${afb_elpa_cfgflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying ELPA tricks (vendor: $1, version: $2, flags: config)])
    
    dnl Basic configuration options
    CFGFLAGS_ELPA="--enable-static --disable-shared"
    
    dnl Disable tests
    CFGFLAGS_ELPA="${CFGFLAGS_ELPA} --enable-c-tests=no --enable-cpp-tests=no --enable-fortran-tests=no"

    dnl OpenMP support
    if test "${afb_elpa_enable_openmp}" = "yes"; then
      CFGFLAGS_ELPA="${CFGFLAGS_ELPA} --enable-openmp=yes"
    else
      CFGFLAGS_ELPA="${CFGFLAGS_ELPA} --enable-openmp=no"
    fi

    dnl SIMD kernels: ELPA uses the best compiled kernel by default and
    dnl does not check the CPU at run time, so only build the kernels
    dnl supported by the build host
    if test "${host_cpu}" = "x86_64" -a "${afb_elpa_enable_simd}" = "yes"; then
      tmp_saved_CFLAGS="${CFLAGS}"
      AC_LANG_PUSH([C])

      dnl Target the instruction set of the build host
      if test "${afb_elpa_cflags_custom}" = "no"; then
        tmp_elpa_host_flag=""
        for tmp_flag in -march=native -xHost; do
          if test "${tmp_elpa_host_flag}" = ""; then
            CFLAGS="${CFLAGS_ELPA} ${tmp_flag}"
            AC_COMPILE_IFELSE([AC_LANG_PROGRAM([], [])],
              [tmp_elpa_host_flag="${tmp_flag}"])
          fi
        done
        AC_MSG_CHECKING([for the C flag targeting the build host in ELPA])
        if test "${tmp_elpa_host_flag}" = ""; then
          AC_MSG_RESULT([none])
        else
          AC_MSG_RESULT([${tmp_elpa_host_flag}])
          CFLAGS_ELPA="${CFLAGS_ELPA} ${tmp_elpa_host_flag}"
        fi
        unset tmp_flag
        unset tmp_elpa_host_flag
      fi

      dnl Same tests as ELPA's configure, which fails on unusable kernels
      CFLAGS="${CFLAGS_ELPA}"
      tmpcfg_elpa=""
      _AFB_ELPA_CHECK_KERNEL([sse], [__m128d h1 = _mm_loaddup_pd(q);])
      tmpcfg_elpa="${tmpcfg_elpa} --${tmp_elpa_kernel_ok}-sse-kernels --${tmp_elpa_kernel_ok}-sse-assembly-kernels"
      _AFB_ELPA_CHECK_KERNEL([avx], [__m256d a1 = _mm256_load_pd(q);])
      tmpcfg_elpa="${tmpcfg_elpa} --${tmp_elpa_kernel_ok}-avx-kernels"
      _AFB_ELPA_CHECK_KERNEL([avx2], [__m256d q1 = _mm256_load_pd(q); __m256d y1 = _mm256_fmadd_pd(q1, q1, q1);])
      tmpcfg_elpa="${tmpcfg_elpa} --${tmp_elpa_kernel_ok}-avx2-kernels"
      _AFB_ELPA_CHECK_KERNEL([avx512], [__m512d q1 = _mm512_load_pd(q); __m512d y1 = _mm512_fmadd_pd(q1, q1, q1);])
      tmpcfg_elpa="${tmpcfg_elpa} --${tmp_elpa_kernel_ok}-avx512-kernels"
      unset tmp_elpa_kernel_ok

      AC_LANG_POP([C])
      CFLAGS="${tmp_saved_CFLAGS}"
      unset tmp_saved_CFLAGS
    else
      tmpcfg_elpa="--disable-avx-kernels --disable-avx2-kernels --disable-avx512-kernels --disable-sse-kernels --disable-sse-assembly-kernels"
    fi
    CFGFLAGS_ELPA="${tmpcfg_elpa} ${CFGFLAGS_ELPA}"
    unset tmpcfg_elpa
    # TODO: add support for 64bit integer support (--enable-64bit-integer-math-support)

    dnl Finish
    tmp_elpa_cnt_tricks=`expr ${tmp_elpa_cnt_tricks} \+ 1`
    afb_elpa_tricky_vars="${afb_elpa_tricky_vars} CFGFLAGS"
  else
    AC_MSG_NOTICE([CFGFLAGS_ELPA set => skipping ELPA arch tricks])
  fi

  dnl Build and install the library only: ELPA always builds hundreds of
  dnl validate_* test programs, even with --enable-*-tests=no, which takes
  dnl time and fails to link with some compilers (e.g. AOCC, duplicate
  dnl GPU layer symbols between libelpatest and libelpa). The test library
  dnl must be skipped as well: its dependency on the elpa module is only
  dnl known through the test programs, which breaks parallel builds.
  dnl $(SUFFIX) is expanded by the Makefile of ELPA.
  MAKEARGS_ELPA="noinst_PROGRAMS= 'noinst_LTLIBRARIES=libelpa\$\$(SUFFIX)_public.la libelpa\$\$(SUFFIX)_private.la'"
  AC_SUBST(MAKEARGS_ELPA)

  dnl Linar algebra tricks
  if test "${afb_elpa_ldflag_custom}" = "no"; then
    AC_MSG_NOTICE([applying ELPA tricks (vendor: $1, version: $2, flags: linalg)])
    
    dnl Add standard flags
    tmplibs_elpa='$(afb_linalg_libs)'
    LDFLAGS_ELPA="${tmplibs_elpa} ${LDFLAGS_ELPA}"
    unset tmplibs_elpa
    
    dnl Finish
    tmp_elpa_cnt_tricks=`expr ${tmp_elpa_cnt_tricks} \+ 1`
    afb_elpa_tricky_vars="${afb_elpa_tricky_vars} LDFLAGS"
  else
    AC_MSG_NOTICE([LDFLAGS_ELPA set => skipping ELPA linalg tricks])
  fi

  dnl Count applied tricks
  case "${tmp_elpa_cnt_tricks}" in
    0)
      afb_elpa_tricks="no"
      ;;
    ${tmp_elpa_num_tricks})
      afb_elpa_tricks="yes"
      ;;
    *)
      afb_elpa_tricks="partial"
      ;;
  esac
  unset tmp_elpa_cnt_tricks
  unset tmp_elpa_num_tricks
]) # AFB_TRICKS_ELPA



# _AFB_ELPA_CHECK_KERNEL(KERNEL, STATEMENTS)
# ------------------------------------------
#
# Checks whether the C compiler can build the ELPA KERNEL kernels with
# the current CFLAGS, and sets tmp_elpa_kernel_ok to "enable" or
# "disable" accordingly.
#
AC_DEFUN([_AFB_ELPA_CHECK_KERNEL],[
  AC_MSG_CHECKING([whether to build the ELPA $1 kernels])
  AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <x86intrin.h>]],
    [[double *q; $2]])],
    [tmp_elpa_kernel_ok="enable"; AC_MSG_RESULT([yes])],
    [tmp_elpa_kernel_ok="disable"; AC_MSG_RESULT([no])])
]) # _AFB_ELPA_CHECK_KERNEL
