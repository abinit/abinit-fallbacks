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



# AFB_TRICKS_BIGDFT(FC_VENDOR,FC_VERSION)
# ---------------------------------------
#
# Applies tricks and workarounds to have the BigDFT library correctly
# linked to the binaries.
#
AC_DEFUN([AFB_TRICKS_BIGDFT],[
  dnl Do some sanity checking of the arguments
  m4_if([$1], , [AC_FATAL([$0: missing argument 1])])dnl
  m4_if([$2], , [AC_FATAL([$0: missing argument 2])])dnl

  dnl Init
  afb_bigdft_tricks="no"
  afb_bigdft_tricky_vars=""
  tmp_bigdft_num_tricks=4
  tmp_bigdft_cnt_tricks=0

  dnl Configure tricks
  if test "${afb_bigdft_cfgflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying BigDFT tricks (vendor: $1, version: $2, flags: config)])

    dnl LibXC
    tmpflags_libxc='--disable-internal-libxc --with-libxc-incs="$(afb_libxc_incs)" --with-libxc-libs="$(afb_libxc_libs) ${LIBS}"'

    dnl YAML
    dnl FIXME: disabled internal YAML because PyYAML requires shared objects

    dnl Internal BigDFT parameters
    tmpflags_options='--without-archives --with-moduledir="$(prefix)/$(bigdft_pkg_inst)/include"'
    tmpflags_bigdft='--disable-binaries --disable-bindings --enable-libbigdft'
    CFGFLAGS_BIGDFT="${CFGFLAGS_BIGDFT} ${tmpflags_bigdft} ${tmpflags_options} ${tmpflags_libxc}"

    dnl ScaLAPACK: the configure script of BigDFT only tries -lscalapack.
    dnl Without ScaLAPACK, BigDFT compiles fake BLACS/ScaLAPACK routines
    dnl (src/modules/blacs_fake.f90, which stop the program), and these
    dnl replace the real ones in the programs linking libbigdft when the
    dnl real library comes later on the link line (e.g. Cray LibSci, added
    dnl at the end by the compiler wrappers): name the actual library
    case "${afb_linalg_det_flavor_found}" in
      *libsci*)
        tmp_bigdft_sci=`echo "${PE_ENV}" | tr 'A-Z' 'a-z'`
        if test "${tmp_bigdft_sci}" != "" -a "${CRAY_LIBSCI_PREFIX_DIR}" != ""; then
          CFGFLAGS_BIGDFT="${CFGFLAGS_BIGDFT} --with-scalapack=-lsci_${tmp_bigdft_sci}_mpi --with-scalapack-path=${CRAY_LIBSCI_PREFIX_DIR}/lib"
        fi
        unset tmp_bigdft_sci
        ;;
      *mkl*)
        CFGFLAGS_BIGDFT="${CFGFLAGS_BIGDFT} --with-scalapack=-lmkl_scalapack_lp64"
        ;;
    esac

    dnl Python: the configure script of S_GPU, bundled with BigDFT and
    dnl always run, stops if there is no "python" executable, which is often
    dnl only available as "python3"
    AC_PATH_PROGS([afb_bigdft_python], [python3 python])
    if test "${afb_bigdft_python}" != ""; then
      CFGFLAGS_BIGDFT="${CFGFLAGS_BIGDFT} PYTHON=${afb_bigdft_python}"
    fi

    dnl Finish
    tmp_bigdft_cnt_tricks=`expr ${tmp_bigdft_cnt_tricks} \+ 1`
    afb_bigdft_tricky_vars="${afb_bigdft_tricky_vars} CFGFLAGS"
    unset tmpflags_libxc
    unset tmpflags_options
    unset tmpflags_bigdft
  else
    AC_MSG_NOTICE([CFGFLAGS_BIGDFT set => skipping BigDFT config tricks])
  fi

  dnl C tricks
  if test "${afb_bigdft_cflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying BigDFT tricks (vendor: $1, version: $2, flags: C)])

    case "$1" in
      intel)
        CFLAGS_BIGDFT="${CFLAGS_BIGDFT} -std=gnu89"
        ;;
    esac

    dnl Finish
    tmp_bigdft_cnt_tricks=`expr ${tmp_bigdft_cnt_tricks} \+ 1`
    afb_bigdft_tricky_vars="${afb_bigdft_tricky_vars} CFLAGS"
  else
    AC_MSG_NOTICE([CFLAGS_BIGDFT set => skipping BigDFT C tricks])
  fi

  dnl CPP tricks
  if test "${afb_bigdft_cppflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying BigDFT tricks (vendor: $1, version: $2, flags: C preprocessing)])

    CPPFLAGS_BIGDFT="${CPPFLAGS_BIGDFT} \$(afb_libxc_incs)"

    dnl Finish
    tmp_bigdft_cnt_tricks=`expr ${tmp_bigdft_cnt_tricks} \+ 1`
    afb_bigdft_tricky_vars="${afb_bigdft_tricky_vars} CPPFLAGS"
  else
    AC_MSG_NOTICE([CPPFLAGS_BIGDFT set => skipping BigDFT C preprocessing tricks])
  fi

  dnl Fortran tricks
  if test "${afb_bigdft_fcflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying BigDFT tricks (vendor: $1, version: $2, flags: Fortran)])

    FCFLAGS_BIGDFT="${CPPFLAGS_BIGDFT} ${FCFLAGS_BIGDFT}"
    dnl GCC >= 10 rejects argument mismatches by default (other compilers
    dnl do not know this option, e.g. Cray Fortran stops with an error)
    if test "$1" = "gnu"; then
      if test "`echo "$2" | cut -d. -f1`" -ge 10 2>/dev/null; then
        FCFLAGS_BIGDFT="${FCFLAGS_BIGDFT} -fallow-argument-mismatch"
      fi
    fi
    dnl CCE 18 crashes in its backend (LLVM "Broken module found") when
    dnl compiling flib/src/dictionaries.f90 with the default IPA level
    if test "$1" = "cray"; then
      FCFLAGS_BIGDFT="${FCFLAGS_BIGDFT} -h ipa1"
    fi
    dnl AOCC 4.1 (flang) crashes in the LLVM inliner when compiling
    dnl src/forces.f90 at its default optimization level (-O2)
    if test "$1" = "llvm"; then
      if ${FC} --version 2>&1 | grep AOCC >/dev/null; then
        FCFLAGS_BIGDFT="${FCFLAGS_BIGDFT} -O1"
      fi
    fi

    dnl Finish
    tmp_bigdft_cnt_tricks=`expr ${tmp_bigdft_cnt_tricks} \+ 1`
    afb_bigdft_tricky_vars="${afb_bigdft_tricky_vars} FCFLAGS"
  else
    AC_MSG_NOTICE([FCFLAGS_BIGDFT set => skipping BigDFT Fortran tricks])
  fi

  dnl Linker tricks
  dnl The NetCDF fallbacks are static libraries, so -lnetcdff alone is not
  dnl enough: the NetCDF-C and HDF5 libraries it depends on (and their own
  dnl dependencies, e.g. -lz -lcurl) must be linked as well. Since NetCDF-C
  dnl is installed before BigDFT is configured, ask nc-config for them.
  dnl (With Cray CCE, -lnetcdff alone even breaks the configure checks of
  dnl BigDFT, as the Cray runtime pulls objects out of libnetcdff.a.)
  if test "${afb_bigdft_libs_custom}" = "no" -a \
          "${enable_netcdf4}" = "yes" -a "${enable_netcdf4_fortran}" = "yes"; then
    AC_MSG_NOTICE([applying BigDFT tricks (vendor: $1, version: $2, flags: libraries)])

    tmplibs_bigdft='$(afb_netcdf4_fortran_libs) `$(prefix)/netcdf4/default/bin/nc-config --static --libs`'
    LIBS_BIGDFT="${tmplibs_bigdft} ${LIBS_BIGDFT}"
    afb_bigdft_tricky_vars="${afb_bigdft_tricky_vars} LIBS"
    unset tmplibs_bigdft
  fi

  dnl Count applied tricks
  case "${tmp_bigdft_cnt_tricks}" in
    0)
      afb_bigdft_tricks="no"
      ;;
    ${tmp_bigdft_num_tricks})
      afb_bigdft_tricks="yes"
      ;;
    *)
      afb_bigdft_tricks="partial"
      ;;
  esac
  unset tmp_bigdft_cnt_tricks
  unset tmp_bigdft_num_tricks
]) # AFB_TRICKS_BIGDFT
