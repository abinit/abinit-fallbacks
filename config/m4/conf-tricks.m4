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



# AFB_TRICKS_ATOMPAW(FC_VENDOR,FC_VERSION)
# ----------------------------------------
#
# Applies tricks and workarounds to have the AtomPAW library correctly
# linked to the binaries.
#
AC_DEFUN([AFB_TRICKS_ATOMPAW],[
  dnl Do some sanity checking of the arguments
  m4_if([$1], [], [AC_FATAL([$0: missing argument 1])])dnl
  m4_if([$2], [], [AC_FATAL([$0: missing argument 2])])dnl

  dnl Init
  afb_atompaw_tricks="no"
  afb_atompaw_tricky_vars=""

  dnl Configure tricks
  if test "${afb_atompaw_cfgflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying AtomPAW tricks (vendor: $1, version: $2, flags: config)])

    dnl Linear algebra
    tmpflags_atompaw='--with-linalg-libs="$(afb_linalg_libs)"'
    CFGFLAGS_ATOMPAW="${CFGFLAGS_ATOMPAW} ${tmpflags_atompaw}"

    dnl LibXC
    CFGFLAGS_ATOMPAW="${CFGFLAGS_ATOMPAW} --enable-libxc"
    tmpflags_atompaw='--with-libxc-incs="$(afb_libxc_incs)"'
    CFGFLAGS_ATOMPAW="${CFGFLAGS_ATOMPAW} ${tmpflags_atompaw}"
    tmpflags_atompaw='--with-libxc-libs="$(afb_libxc_libs)"'
    CFGFLAGS_ATOMPAW="${CFGFLAGS_ATOMPAW} ${tmpflags_atompaw}"

    dnl Force static build (shared libraries fail to build)
    CFGFLAGS_ATOMPAW="${CFGFLAGS_ATOMPAW} --enable-static --disable-shared"

    dnl Finish
    test "${afb_atompaw_tricks}" = "no" && afb_atompaw_tricks="yes"
    afb_atompaw_tricky_vars="${afb_atompaw_tricky_vars} CFGFLAGS"
    unset tmpflags_atompaw
  else
    AC_MSG_NOTICE([CFGFLAGS_ATOMPAW set => skipping AtomPAW config tricks])
    test "${afb_atompaw_tricks}" = "yes" && afb_atompaw_tricks="partial"
  fi
]) # AFB_TRICKS_ATOMPAW



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
  tmp_bigdft_num_tricks=3
  tmp_bigdft_cnt_tricks=0

  dnl Configure tricks
  if test "${afb_bigdft_cfgflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying BigDFT tricks (vendor: $1, version: $2, flags: config)])

    dnl LibXC
    tmpflags_libxc='--disable-internal-libxc --with-libxc-incs="$(afb_libxc_incs)" --with-libxc-libs="$(afb_libxc_libs) ${LIBS}"'

    dnl YAML
    dnl FIXME: disabled internal YAML because PyYAML requires shared objects
    tmpflags_libyaml='--disable-internal-libyaml --disable-shared --with-yaml-path="$(prefix)/$(yaml_pkg_name)"'

    dnl Internal BigDFT parameters
    tmpflags_options='--without-archives --with-moduledir="$(prefix)/$(bigdft_pkg_name)/include"'
    tmpflags_bigdft='--disable-binaries --disable-bindings --enable-libbigdft'
    CFGFLAGS_BIGDFT="${CFGFLAGS_BIGDFT} ${tmpflags_bigdft} ${tmpflags_options} ${tmpflags_libyaml} ${tmpflags_libxc}"

    dnl Finish
    tmp_bigdft_cnt_tricks=`expr ${tmp_bigdft_cnt_tricks} \+ 1`
    afb_bigdft_tricky_vars="${afb_bigdft_tricky_vars} CFGFLAGS"
    unset tmpflags_libxc
    unset tmpflags_libyaml
    unset tmpflags_options
    unset tmpflags_bigdft
  else
    AC_MSG_NOTICE([CFGFLAGS_BIGDFT set => skipping BigDFT config tricks])
  fi

  dnl CPP tricks
  if test "${afb_bigdft_cppflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying BigDFT tricks (vendor: $1, version: $2, flags: C preprocessing)])

    CPPFLAGS_BIGDFT="${CPPFLAGS_BIGDFT} \$(afb_libxc_incs) \$(afb_yaml_incs)"

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

    dnl Finish
    tmp_bigdft_cnt_tricks=`expr ${tmp_bigdft_cnt_tricks} \+ 1`
    afb_bigdft_tricky_vars="${afb_bigdft_tricky_vars} FCFLAGS"
  else
    AC_MSG_NOTICE([FCFLAGS_BIGDFT set => skipping BigDFT Fortran tricks])
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
    CFGFLAGS_LIBXC="--enable-fortran --enable-static --disable-shared"

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



# AFB_TRICKS_LINALG(FC_VENDOR,FC_VERSION)
# ---------------------------------------
#
# Applies tricks and workarounds to have the optimized linear algebra
# libraries correctly linked to the binaries.
#
AC_DEFUN([AFB_TRICKS_LINALG],[
  dnl Do some sanity checking of the arguments
  m4_if([$1], [], [AC_FATAL([$0: missing argument 1])])dnl
  m4_if([$2], [], [AC_FATAL([$0: missing argument 2])])dnl

  dnl Init
  afb_linalg_tricks="no"
  afb_linalg_tricky_vars=""

  dnl Fortran tricks
  if test "${afb_linalg_fcflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying linear algebra tricks (vendor: $1, version: $2, flags: Fortran)])

    case "$1" in
      ibm)
        FCFLAGS_LINALG="${FCFLAGS_LINALG} ${FCFLAGS_FIXEDFORM}"
        ;;
    esac

    dnl Finish
    afb_linalg_tricks="yes"
    afb_linalg_tricky_vars="${afb_linalg_tricky_vars} FCFLAGS"
  else
    AC_MSG_NOTICE([FCFLAGS_LINALG set => skipping linear algebra Fortran tricks])
  fi
]) # AFB_TRICKS_LINALG



# AFB_TRICKS_NETCDF4(FC_VENDOR,FC_VERSION)
# ----------------------------------------
#
# Applies tricks and workarounds to have the NetCDF4
# C libraries correctly linked to the binaries.
#
AC_DEFUN([AFB_TRICKS_NETCDF4],[
  dnl Do some sanity checking of the arguments
  m4_if([$1], [], [AC_FATAL([$0: missing argument 1])])dnl
  m4_if([$2], [], [AC_FATAL([$0: missing argument 2])])dnl

  dnl Init
  afb_netcdf4_tricks="no"
  afb_netcdf4_tricky_vars=""
  tmp_netcdf4_num_tricks=1
  tmp_netcdf4_cnt_tricks=0

  dnl Configure tricks
  if test "${afb_netcdf4_cfgflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying NetCDF4 tricks (vendor: $1, version: $2, flags: config)])

    dnl Internal NetCDF4 parameters
    CFGFLAGS_NETCDF4="${CFGFLAGS_NETCDF4} --disable-dap --disable-examples --disable-hdf4 --disable-v2 --enable-parallel-tests"
    #CFGFLAGS_NETCDF4="${CFGFLAGS_NETCDF4} --enable-static --disable-shared"
    if test "${afb_hdf5_ok}" != "yes"; then
      CFGFLAGS_NETCDF4="${CFGFLAGS_NETCDF4} --disable-netcdf-4"
    fi

    dnl Finish
    tmp_netcdf4_cnt_tricks=`expr ${tmp_netcdf4_cnt_tricks} \+ 1`
    afb_netcdf4_tricky_vars="${afb_netcdf4_tricky_vars} CFGFLAGS"
  else
    AC_MSG_NOTICE([CFGFLAGS_NETCDF4 set => skipping NetCDF4 config tricks])
  fi

  dnl Count applied tricks
  case "${tmp_netcdf4_cnt_tricks}" in
    0)
      afb_netcdf4_tricks="no"
      ;;
    ${tmp_netcdf4_num_tricks})
      afb_netcdf4_tricks="yes"
      ;;
    *)
      afb_netcdf4_tricks="partial"
      ;;
  esac
  unset tmp_netcdf4_cnt_tricks
  unset tmp_netcdf4_num_tricks
]) # AFB_TRICKS_NETCDF4



# AFB_TRICKS_NETCDF4_FORTRAN(FC_VENDOR,FC_VERSION)
# ----------------------------------------
#
# Applies tricks and workarounds to have the NetCDF4 Fortran
# C libraries correctly linked to the binaries.
#
AC_DEFUN([AFB_TRICKS_NETCDF4_FORTRAN],[
  dnl Do some sanity checking of the arguments
  m4_if([$1], [], [AC_FATAL([$0: missing argument 1])])dnl
  m4_if([$2], [], [AC_FATAL([$0: missing argument 2])])dnl

  dnl Init
  afb_netcdf4_fortran_tricks="no"
  afb_netcdf4_fortran_tricky_vars=""
  tmp_netcdf4_fortran_num_tricks=1
  tmp_netcdf4_fortran_cnt_tricks=0

  dnl Configure tricks
  if test "${afb_netcdf4_fortran_cfgflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying NetCDF4 Fortran tricks (vendor: $1, version: $2, flags: config)])

    dnl Internal NetCDF4 Fortran parameters
    CFGFLAGS_NETCDF4_FORTRAN="${CFGFLAGS_NETCDF4_FORTRAN} --disable-dap --disable-examples --disable-hdf4 --disable-v2 --enable-parallel-tests"
    #CFGFLAGS_NETCDF4_FORTRAN="${CFGFLAGS_NETCDF4_FORTRAN} --enable-static --disable-shared"
    if test "${afb_hdf5_ok}" != "yes"; then
      CFGFLAGS_NETCDF4_FORTRAN="${CFGFLAGS_NETCDF4_FORTRAN} --disable-netcdf-4"
    fi

    dnl Finish
    tmp_netcdf4_fortran_cnt_tricks=`expr ${tmp_netcdf4_fortran_cnt_tricks} \+ 1`
    afb_netcdf4_fortran_tricky_vars="${afb_netcdf4_fortran_tricky_vars} CFGFLAGS"
  else
    AC_MSG_NOTICE([CFGFLAGS_NETCDF4_FORTRAN set => skipping NetCDF4 Fortran config tricks])
  fi

  dnl Count applied tricks
  case "${tmp_netcdf4_fortran_cnt_tricks}" in
    0)
      afb_netcdf4_fortran_tricks="no"
      ;;
    ${tmp_netcdf4_fortran_num_tricks})
      afb_netcdf4_fortran_tricks="yes"
      ;;
    *)
      afb_netcdf4_fortran_tricks="partial"
      ;;
  esac
  unset tmp_netcdf4_fortran_cnt_tricks
  unset tmp_netcdf4_fortran_num_tricks
]) # AFB_TRICKS_NETCDF4_FORTRAN



# AFB_TRICKS_PSML(FC_VENDOR,FC_VERSION)
# -------------------------------------
#
# Applies tricks and workarounds to have the PSML library correctly
# linked to the binaries.
#
AC_DEFUN([AFB_TRICKS_PSML],[
  dnl Do some sanity checking of the arguments
  m4_if([$1], [], [AC_FATAL([$0: missing argument 1])])dnl
  m4_if([$2], [], [AC_FATAL([$0: missing argument 2])])dnl

  dnl Init
  afb_psml_tricks="no"
  afb_psml_tricky_vars=""

  AC_MSG_NOTICE([no tricks to apply for PSML])
]) # AFB_TRICKS_PSML



# AFB_TRICKS_WANNIER90(FC_VENDOR,FC_VERSION)
# ------------------------------------------
#
# Applies tricks and workarounds to have the Wannier90 bindings correctly
# linked to the binaries.
#
AC_DEFUN([AFB_TRICKS_WANNIER90],[
  dnl Do some sanity checking of the arguments
  m4_if([$1], , [AC_FATAL([$0: missing argument 1])])dnl
  m4_if([$2], , [AC_FATAL([$0: missing argument 2])])dnl

  dnl Init
  afb_wannier90_tricks="no"
  afb_wannier90_tricky_vars=""
  tmp_wannier90_num_tricks=2
  tmp_wannier90_cnt_tricks=0

  dnl Configure tricks
  if test "${afb_wannier90_cfgflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying Wannier90 tricks (vendor: $1, version: $2, flags: config)])

    dnl Internal Wannier90 parameters
    dnl Note: Disable shared libraries, because linear algebra fallback is
    dnl only providing static libraries.
    CFGFLAGS_WANNIER90="${CFGFLAGS_WANNIER90} --disable-shared --enable-static"

    dnl Finish
    tmp_wannier90_cnt_tricks=`expr ${tmp_wannier90_cnt_tricks} \+ 1`
    afb_wannier90_tricky_vars="${afb_wannier90_tricky_vars} CFGFLAGS"
  else
    AC_MSG_NOTICE([CFGFLAGS_WANNIER90 set => skipping Wannier90 config tricks])
  fi

  dnl Libraries tricks
  if test "${afb_wannier90_libs_custom}" = "no"; then
    AC_MSG_NOTICE([applying Wannier90 tricks (vendor: $1, version: $2, flags: libraries)])

    dnl Linear algebra
    tmplibs_wannier90='$(afb_linalg_libs)'
    LIBS_WANNIER90="${tmplibs_wannier90} ${LIBS_WANNIER90}"
    unset tmplibs_wannier90

    case "$1" in
      intel)
        case "${target_cpu}" in
          ia64)
            # Do nothing
            ;;
          *)
            case "$2" in
              9.0|9.1|10.0|10.1|11.0|11.1)
              LIBS_WANNIER90="${LIBS_WANNIER90} -lsvml"
              ;;
            esac
            ;;
        esac
        ;;
    esac

    dnl Finish
    tmp_wannier90_cnt_tricks=`expr ${tmp_wannier90_cnt_tricks} \+ 1`
    afb_wannier90_tricky_vars="${afb_wannier90_tricky_vars} LIBS"
  else
    AC_MSG_NOTICE([LIBS_WANNIER90 set => skipping Wannier90 libraries tricks])
  fi

  dnl Count applied tricks
  case "${tmp_wannier90_cnt_tricks}" in
    0)
      afb_wannier90_tricks="no"
      ;;
    ${tmp_wannier90_num_tricks})
      afb_wannier90_tricks="yes"
      ;;
    *)
      afb_wannier90_tricks="partial"
      ;;
  esac
  unset tmp_wannier90_cnt_tricks
  unset tmp_wannier90_num_tricks
]) # AFB_TRICKS_WANNIER90



# AFB_TRICKS_XMLF90(FC_VENDOR,FC_VERSION)
# -------------------------------------
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

  AC_MSG_NOTICE([no tricks to apply for XMLF90])
]) # AFB_TRICKS_XMLF90



# AFB_TRICKS_YAML(FC_VENDOR,FC_VERSION)
# --------------------------------------
#
# Applies tricks and workarounds to have the YAML library correctly
# linked to the binaries.
#
AC_DEFUN([AFB_TRICKS_YAML],[
  dnl Do some sanity checking of the arguments
  m4_if([$1], [], [AC_FATAL([$0: missing argument 1])])dnl
  m4_if([$2], [], [AC_FATAL([$0: missing argument 2])])dnl

  dnl Init
  afb_yaml_tricks="no"
  afb_yaml_tricky_vars=""
  tmp_yaml_num_tricks=1
  tmp_yaml_cnt_tricks=0

  dnl Configure tricks
  if test "${afb_yaml_cfgflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying YAML tricks (vendor: $1, version: $2, flags: config)])
    dnl Internal YAML parameters
    CFGFLAGS_YAML="--enable-static --disable-shared"

    dnl Finish
    tmp_yaml_cnt_tricks=`expr ${tmp_yaml_cnt_tricks} \+ 1`
    afb_yaml_tricky_vars="${afb_yaml_tricky_vars} CFGFLAGS"
  else
    AC_MSG_NOTICE([CFGFLAGS_YAML set => skipping YAML config tricks])
  fi

  dnl Count applied tricks
  case "${tmp_yaml_cnt_tricks}" in
    0)
      afb_yaml_tricks="no"
      ;;
    ${tmp_yaml_num_tricks})
      afb_yaml_tricks="yes"
      ;;
    *)
      afb_yaml_tricks="partial"
      ;;
  esac
  unset tmp_yaml_cnt_tricks
  unset tmp_yaml_num_tricks
]) # AFB_TRICKS_YAML
