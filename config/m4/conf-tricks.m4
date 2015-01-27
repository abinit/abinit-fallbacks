# -*- Autoconf -*-
#
# Copyright (C) 2006-2014 ABINIT Group (Yann Pouillon)
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

  dnl Configure tricks
  if test "${afb_bigdft_cfgflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying BigDFT tricks (vendor: $1, version: $2, flags: config)])

    dnl LibXC
    tmpflags_libxc='--disable-internal-libxc --with-libxc-incs="$(afb_libxc_incs)" --with-libxc-libs="$(afb_libxc_libs)"'

    dnl Internal BigDFT parameters
    tmpflags_libyaml='--enable-internal-libyaml --disable-shared'
    tmpflags_options='--without-archives --with-moduledir="$(includedir)"'
    tmpflags_bigdft='--disable-binaries --disable-bindings --enable-libbigdft'
    CFGFLAGS_BIGDFT="${CFGFLAGS_BIGDFT} ${tmpflags_bigdft} ${tmpflags_options} ${tmpflags_libyaml} ${tmpflags_libxc}"

    dnl Finish
    test "${afb_bigdft_tricks}" = "no" && afb_bigdft_tricks="yes"
    afb_bigdft_tricky_vars="${afb_bigdft_tricky_vars} CFGFLAGS"
    unset tmpflags_libxc
    unset tmpflags_libyaml
    unset tmpflags_options
    unset tmpflags_bigdft
  else
    AC_MSG_NOTICE([CFGFLAGS_BIGDFT set => skipping BigDFT config tricks])
    test "${afb_bigdft_tricks}" = "yes" && afb_bigdft_tricks="partial"
  fi
]) # AFB_TRICKS_BIGDFT



# AFB_TRICKS_ETSF_IO(FC_VENDOR,FC_VERSION)
# ----------------------------------------
#
# Applies tricks and workarounds to have the ETSF I/O library correctly
# linked to the binaries.
#
AC_DEFUN([AFB_TRICKS_ETSF_IO],[
  dnl Do some sanity checking of the arguments
  m4_if([$1], , [AC_FATAL([$0: missing argument 1])])dnl
  m4_if([$2], , [AC_FATAL([$0: missing argument 2])])dnl

  dnl Init
  afb_etsf_io_tricks="no"
  afb_etsf_io_tricky_vars=""
  tmp_etsf_io_num_tricks=2
  tmp_etsf_io_cnt_tricks=0

  dnl Configure tricks
  if test "${afb_etsf_io_cfgflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying ETSF_IO tricks (vendor: $1, version: $2, flags: config)])

    dnl NetCDF
    tmpflags_etsf_io='--with-netcdf-incs="$(afb_netcdf_incs)"'
    CFGFLAGS_ETSF_IO="${CFGFLAGS_ETSF_IO} ${tmpflags_etsf_io}"
    tmpflags_etsf_io='--with-netcdf-libs="$(afb_netcdf_libs)"'
    CFGFLAGS_ETSF_IO="${CFGFLAGS_ETSF_IO} ${tmpflags_etsf_io}"

    dnl Internal ETSF_IO parameters
    tmpflags_etsf_io='--with-moduledir="$(prefix)/include"'
    CFGFLAGS_ETSF_IO="${CFGFLAGS_ETSF_IO} ${tmpflags_etsf_io}"

    dnl Finish
    tmp_etsf_io_cnt_tricks=`expr ${tmp_etsf_io_cnt_tricks} \+ 1`
    afb_etsf_io_tricky_vars="${afb_etsf_io_tricky_vars} CFGFLAGS"
  else
    AC_MSG_NOTICE([CFGFLAGS_ETSF_IO set => skipping ETSF_IO config tricks])
  fi

  dnl Fortran tricks
  if test "${afb_etsf_io_fcflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying ETSF_IO tricks (vendor: $1, version: $2, flags: Fortran)])

    case "$1" in
      ibm)
        FCFLAGS_ETSF_IO="${FCFLAGS_ETSF_IO} -qsuffix=cpp=f90:f=f"
        ;;
    esac

    dnl Finish
    tmp_etsf_io_cnt_tricks=`expr ${tmp_etsf_io_cnt_tricks} \+ 1`
    afb_etsf_io_tricky_vars="${afb_etsf_io_tricky_vars} FCFLAGS"
    unset tmpflags_etsf_io
  else
    AC_MSG_NOTICE([FCFLAGS_ETSF_IO set => skipping ETSF_IO Fortran tricks])
  fi

  dnl Count applied tricks
  case "${tmp_etsf_io_cnt_tricks}" in
    0)
      afb_etsf_io_tricks="no"
      ;;
    ${tmp_etsf_io_num_tricks})
      afb_etsf_io_tricks="yes"
      ;;
    *)
      afb_etsf_io_tricks="partial"
      ;;
  esac
  unset tmp_etsf_io_cnt_tricks
  unset tmp_etsf_io_num_tricks
]) # AFB_TRICKS_ETSF_IO



# AFB_TRICKS_FOX(FC_VENDOR,FC_VERSION)
# ------------------------------------
#
# Applies tricks and workarounds to have the FoX library correctly
# linked to the binaries.
#
AC_DEFUN([AFB_TRICKS_FOX],[
  dnl Do some sanity checking of the arguments
  m4_if([$1], [], [AC_FATAL([$0: missing argument 1])])dnl
  m4_if([$2], [], [AC_FATAL([$0: missing argument 2])])dnl

  dnl Init
  afb_fox_tricks="no"
  afb_fox_tricky_vars=""
  tmp_fox_num_tricks=2
  tmp_fox_cnt_tricks=0

  dnl Configure tricks
  if test "${afb_fox_cfgflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying FoX tricks (vendor: $1, version: $2, flags: config)])
    dnl Internal FoX parameters
    CFGFLAGS_FOX="${CFGFLAGS_FOX} --enable-sax"

    dnl Finish
    tmp_fox_cnt_tricks=`expr ${tmp_fox_cnt_tricks} \+ 1`
    afb_fox_tricky_vars="${afb_fox_tricky_vars} CFGFLAGS"
  else
    AC_MSG_NOTICE([CFGFLAGS_FOX set => skipping FoX config tricks])
  fi

  dnl Fortran tricks
  if test "${afb_fox_fcflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying FoX tricks (vendor: $1, version: $2, flags: Fortran)])

    case "$1" in
      ibm)
        FCFLAGS_FOX="${FCFLAGS_FOX} -qsuffix=cpp=f90:f=f"
        ;;
    esac

    dnl Finish
    tmp_fox_cnt_tricks=`expr ${tmp_fox_cnt_tricks} \+ 1`
    afb_fox_tricky_vars="${afb_fox_tricky_vars} FCFLAGS"
  else
    AC_MSG_NOTICE([FCFLAGS_FOX set => skipping FoX Fortran tricks])
  fi

  dnl Count applied tricks
  case "${tmp_fox_cnt_tricks}" in
    0)
      afb_fox_tricks="no"
      ;;
    ${tmp_fox_num_tricks})
      afb_fox_tricks="yes"
      ;;
    *)
      afb_fox_tricks="partial"
      ;;
  esac
  unset tmp_fox_cnt_tricks
  unset tmp_fox_num_tricks
]) # AFB_TRICKS_FOX



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



# AFB_TRICKS_NETCDF(FC_VENDOR,FC_VERSION)
# ---------------------------------------
#
# Applies tricks and workarounds to have the optimized linear algebra
# libraries correctly linked to the binaries.
#
AC_DEFUN([AFB_TRICKS_NETCDF],[
  dnl Do some sanity checking of the arguments
  m4_if([$1], [], [AC_FATAL([$0: missing argument 1])])dnl
  m4_if([$2], [], [AC_FATAL([$0: missing argument 2])])dnl

  dnl Init
  afb_netcdf_tricks="no"
  afb_netcdf_tricky_vars=""
  tmp_netcdf_num_tricks=3
  tmp_netcdf_cnt_tricks=0

  dnl Configure tricks
  if test "${afb_netcdf_cfgflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying NetCDF tricks (vendor: $1, version: $2, flags: config)])

    dnl Internal NetCDF parameters
    CFGFLAGS_NETCDF="${CFGFLAGS_NETCDF} --disable-cxx --disable-cxx-4 --disable-dap --disable-hdf4 --disable-netcdf4 --enable-fortran"
    CFGFLAGS_NETCDF="${CFGFLAGS_NETCDF} --enable-static --disable-shared"

    dnl Finish
    tmp_netcdf_cnt_tricks=`expr ${tmp_netcdf_cnt_tricks} \+ 1`
    afb_netcdf_tricky_vars="${afb_netcdf_tricky_vars} CFGFLAGS"
  else
    AC_MSG_NOTICE([CFGFLAGS_NETCDF set => skipping NetCDF config tricks])
  fi

  dnl CPP tricks
  if test "${afb_netcdf_cppflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying NetCDF tricks (vendor: $1, version: $2, flags: C preprocessing)])

    CPPFLAGS_NETCDF="${CPPFLAGS_NETCDF} -DNDEBUG"

    case "$1" in
      g95)
        CPPFLAGS_NETCDF="${CPPFLAGS_NETCDF} -Df2cFortran"
        ;;
      gnu)
        case "$2" in
          4.4|4.5|4.6|4.7)
            CPPFLAGS_NETCDF="${CPPFLAGS_NETCDF} -DpgiFortran"
            ;;
        esac
        ;;
      ibm)
        CPPFLAGS_NETCDF="${CPPFLAGS_NETCDF} -DIBMR2Fortran"
        ;;
      intel)
        CPPFLAGS_NETCDF="${CPPFLAGS_NETCDF} -DpgiFortran"
        ;;
      pathscale)
        case "$2" in
          1.0|4.0|5.0)
            CPPFLAGS_NETCDF="${CPPFLAGS_NETCDF} -DpgiFortran"
            ;;
          *)
            CPPFLAGS_NETCDF="${CPPFLAGS_NETCDF} -Df2cFortran"
            ;;
        esac
        ;;
      open64)
        CPPFLAGS_NETCDF="${CPPFLAGS_NETCDF} -Df2cFortran -DF2CSTYLE"
        ;;
      pgi)
        CPPFLAGS_NETCDF="${CPPFLAGS_NETCDF} -DpgiFortran"
        ;;
      sun)
        CPPFLAGS_NETCDF="${CPPFLAGS_NETCDF} -DsunFortran"
        ;;
      *)
        CPPFLAGS_NETCDF="${CPPFLAGS_NETCDF} -DpgiFortran"
        ;;
    esac

    dnl Finish
    tmp_netcdf_cnt_tricks=`expr ${tmp_netcdf_cnt_tricks} \+ 1`
    afb_netcdf_tricky_vars="${afb_netcdf_tricky_vars} CPPFLAGS"
  else
    AC_MSG_NOTICE([CPPFLAGS_NETCDF set => skipping NetCDF C preprocessing tricks])
  fi

  dnl Fortran tricks
  if test "${afb_netcdf_fcflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying NetCDF tricks (vendor: $1, version: $2, flags: Fortran)])

    FCFLAGS_NETCDF="${CPPFLAGS_NETCDF} ${FCFLAGS_NETCDF}"

    case "$1" in
      ibm)
        FCFLAGS_NETCDF="${FCFLAGS_NETCDF} -WF,-DIBMR2Fortran,-DNDEBUG"
        ;;
      intel)
        case "$2" in
          9.0|9.1)
            FCFLAGS_NETCDF="${FCFLAGS_NETCDF} -mp"
            ;;
        esac
        ;;
    esac

    dnl Finish
    tmp_netcdf_cnt_tricks=`expr ${tmp_netcdf_cnt_tricks} \+ 1`
    afb_netcdf_tricky_vars="${afb_netcdf_tricky_vars} FCFLAGS"
  else
    AC_MSG_NOTICE([FCFLAGS_NETCDF set => skipping NetCDF Fortran tricks])
  fi

  dnl Count applied tricks
  case "${tmp_netcdf_cnt_tricks}" in
    0)
      afb_netcdf_tricks="no"
      ;;
    ${tmp_netcdf_num_tricks})
      afb_netcdf_tricks="yes"
      ;;
    *)
      afb_netcdf_tricks="partial"
      ;;
  esac
  unset tmp_netcdf_cnt_tricks
  unset tmp_netcdf_num_tricks
]) # AFB_TRICKS_NETCDF



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
    afb_wannier90_tricky_vars="${afb_wannier90_tricky_vars} CFGFLAGS"
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
