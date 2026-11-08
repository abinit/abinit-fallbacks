# -*- Autoconf -*-
#
# Copyright (C) 2014 ABINIT Group (Yann Pouillon)
#
# This file is part of the ABINIT software package. For license information,
# please see the COPYING file in the top-level directory of the ABINIT source
# distribution.
#



# AFB_CHECK_LINALG()
# ----------------------------
#
# Check whether the specified libraries are BLAS and LAPACK
# implementations.
#
AC_DEFUN([AFB_CHECK_LINALG],[
  dnl Init
  afb_linalg_default_libs="-llapack -lblas"
  afb_linalg_has_incs="unknown"
  afb_linalg_has_libs="unknown"
  afb_linalg_has_blas="unknown"
  afb_linalg_has_blas_axbpy="unknown"
  afb_linalg_has_blas_gemm3m="unknown"
  afb_linalg_has_blas_mkl_imatcopy="unknown"
  afb_linalg_has_blas_mkl_omatcopy="unknown"
  afb_linalg_has_blas_mkl_omatadd="unknown"
  afb_linalg_has_lapack="unknown"
  afb_linalg_has_lapacke="unknown"
  afb_linalg_has_blacs="unknown"
  afb_linalg_has_scalapack="unknown"
  afb_linalg_has_elpa="unknown"
  afb_linalg_has_elpa_new="unknown"
  afb_linalg_has_plasma="unknown"
  afb_linalg_has_magma="unknown"
  afb_linalg_ext_ok="unknown"

  dnl Prepare environment
  tmp_saved_CPPFLAGS="${CPPFLAGS}"
  tmp_saved_FCFLAGS="${FCFLAGS}"
  tmp_saved_LIBS="${LIBS}"
  CPPFLAGS="${CPPFLAGS} ${with_linalg_incs}"
  FCFLAGS="${FCFLAGS} ${with_linalg_incs}"
  dnl Do not add default libraries when the detection found that none
  dnl is needed, e.g. Cray LibSci linked by the compiler wrappers
  if test "${afb_linalg_libs}" = "" -a "${afb_linalg_det_serial_ok}" != "yes"; then
    AC_MSG_CHECKING([for linear algebra libraries to try])
    LIBS="${afb_linalg_default_libs} ${LIBS}"
    AC_MSG_RESULT([${afb_linalg_default_libs}])
  else
    LIBS="${afb_linalg_libs} ${LIBS}"
  fi

  dnl BLAS?
  AC_MSG_CHECKING([for BLAS support in specified libraries])
  AC_LANG_PUSH([Fortran])
  AC_LINK_IFELSE([AC_LANG_PROGRAM([],
    [[
      call zgemm
    ]])], [afb_linalg_has_blas="yes"], [afb_linalg_has_blas="no"])
  AC_LANG_POP([Fortran])
  AC_MSG_RESULT([${afb_linalg_has_blas}])

  dnl BLAS AXPBY extensions?
  if test "${afb_linalg_has_blas}" = "yes"; then
    AC_MSG_CHECKING([for BLAS AXPBY support in specified libraries])
    AC_LANG_PUSH([Fortran])
    AC_LINK_IFELSE([AC_LANG_PROGRAM([],
      [[
        call saxpby
        call daxpby
        call caxpby
        call zaxpby
      ]])], [afb_linalg_has_blas_axpby="yes"], [afb_linalg_has_blas_axpby="no"])
    AC_LANG_POP([Fortran])
    AC_MSG_RESULT([${afb_linalg_has_blas_axpby}])
  fi

  dnl BLAS GEMM3M extensions?
  if test "${afb_linalg_has_blas}" = "yes"; then
    AC_MSG_CHECKING([for GEMM3M support in specified libraries])
    AC_LANG_PUSH([Fortran])
    AC_LINK_IFELSE([AC_LANG_PROGRAM([],
      [[
        call cgemm3m
        call zgemm3m
      ]])], [afb_linalg_has_blas_gemm3m="yes"], [afb_linalg_has_blas_gemm3m="no"])
    AC_LANG_POP([Fortran])
    AC_MSG_RESULT([${afb_linalg_has_blas_gemm3m}])
  fi

  dnl BLAS MKL IMATCOPY extensions?
  if test "${afb_linalg_has_blas}" = "yes"; then
    AC_MSG_CHECKING([for MKL IMATCOPY support in specified libraries])
    AC_LANG_PUSH([Fortran])
    AC_LINK_IFELSE([AC_LANG_PROGRAM([],
      [[
        call mkl_simatcopy
        call mkl_dimatcopy
        call mkl_cimatcopy
        call mkl_zimatcopy
      ]])], [afb_linalg_has_blas_mkl_imatcopy="yes"], [afb_linalg_has_blas_mkl_imatcopy="no"])
    AC_LANG_POP([Fortran])
    AC_MSG_RESULT([${afb_linalg_has_blas_mkl_imatcopy}])
  fi

  dnl BLAS MKL OMATCOPY extensions?
  if test "${afb_linalg_has_blas}" = "yes"; then
    AC_MSG_CHECKING([for MKL OMATCOPY support in specified libraries])
    AC_LANG_PUSH([Fortran])
    AC_LINK_IFELSE([AC_LANG_PROGRAM([],
      [[
        call mkl_somatcopy
        call mkl_domatcopy
        call mkl_comatcopy
        call mkl_zomatcopy
      ]])], [afb_linalg_has_blas_mkl_omatcopy="yes"], [afb_linalg_has_blas_mkl_omatcopy="no"])
    AC_LANG_POP([Fortran])
    AC_MSG_RESULT([${afb_linalg_has_blas_mkl_omatcopy}])
  fi

  dnl BLAS MKL OMATADD extensions?
  if test "${afb_linalg_has_blas}" = "yes"; then
    AC_MSG_CHECKING([for MKL OMATADD support in specified libraries])
    AC_LANG_PUSH([Fortran])
    AC_LINK_IFELSE([AC_LANG_PROGRAM([],
      [[
        call mkl_somatadd
        call mkl_domatadd
        call mkl_comatadd
        call mkl_zomatadd
      ]])], [afb_linalg_has_blas_mkl_omatadd="yes"], [afb_linalg_has_blas_mkl_omatadd="no"])
    AC_LANG_POP([Fortran])
    AC_MSG_RESULT([${afb_linalg_has_blas_mkl_omatadd}])
  fi

  dnl LAPACK?
  if test "${afb_linalg_has_blas}" = "yes"; then
    AC_MSG_CHECKING([for LAPACK support in specified libraries])
    AC_LANG_PUSH([Fortran])
    AC_LINK_IFELSE([AC_LANG_PROGRAM([],
      [[
        call zhpev
      ]])], [afb_linalg_has_lapack="yes"], [afb_linalg_has_lapack="no"])
    AC_LANG_POP([Fortran])
    AC_MSG_RESULT([${afb_linalg_has_lapack}])
  fi

  dnl LAPACKE?
  if test "${afb_linalg_has_lapack}" = "yes"; then
    AC_MSG_CHECKING([for LAPACKE C API support in specified libraries])
    AC_LANG_PUSH([C])
    AC_LINK_IFELSE([AC_LANG_PROGRAM(
      [
#include <lapacke.h>
      ],[[
        zhpev_;
      ]])],[afb_linalg_has_lapacke="yes"], [afb_linalg_has_lapacke="no"])
    AC_LANG_POP([C])
    AC_MSG_RESULT([${afb_linalg_has_lapacke}])
  fi

  dnl BLACS?
  if test "${afb_linalg_has_lapack}" = "yes"; then
    AC_MSG_CHECKING([for BLACS support in specified libraries])
    AC_LANG_PUSH([Fortran])
    AC_LINK_IFELSE([AC_LANG_PROGRAM([],
      [[
        call blacs_gridinit
      ]])], [afb_linalg_has_blacs="yes"], [afb_linalg_has_blacs="no"])
    AC_LANG_POP([Fortran])
    AC_MSG_RESULT([${afb_linalg_has_blacs}])
  fi

  dnl ScaLAPACK?
  if test "${afb_linalg_has_blacs}" = "yes"; then
    AC_MSG_CHECKING([for ScaLAPACK support in specified libraries])
    AC_LANG_PUSH([Fortran])
    AC_LINK_IFELSE([AC_LANG_PROGRAM([],
      [[
        call pzheevx
      ]])], [afb_linalg_has_scalapack="yes"], [afb_linalg_has_scalapack="no"])
    AC_LANG_POP([Fortran])
    AC_MSG_RESULT([${afb_linalg_has_scalapack}])
  fi

  dnl ELPA?
  if test "${afb_linalg_has_scalapack}" = "yes"; then
    AC_MSG_CHECKING([for ELPA support in specified libraries])
    AC_LANG_PUSH([Fortran])
    AC_LINK_IFELSE([AC_LANG_PROGRAM([],
      [[
        use elpa1
        logical :: success
        real*8 :: a(lda,na),ev(na),q(ldq,na)
        success=solve_evp_real(na,nev,a,lda,ev,q,ldq,nblk,comm_r,comm_c)
      ]])], [afb_linalg_has_elpa="yes"], [afb_linalg_has_elpa="no"])
    AC_LANG_POP([Fortran])
    AC_MSG_RESULT([${afb_linalg_has_elpa}])
  fi

  dnl PLASMA?
  if test "${afb_linalg_has_lapacke}" = "yes"; then
    AC_MSG_CHECKING([for PLASMA support in specified libraries])
    AC_LANG_PUSH([Fortran])
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM([],
      [[
        use plasma
        call plasma_zhegv
      ]])], [afb_linalg_has_plasma="yes"], [afb_linalg_has_plasma="no"])
    AC_LANG_POP([Fortran])
    AC_MSG_RESULT([${afb_linalg_has_plasma}])
  fi

  dnl MAGMA?
  if test "${afb_linalg_has_lapack}" = "yes"; then
    AC_MSG_CHECKING([for MAGMA (version>=1.1.0) support in specified libraries])
    AC_LANG_PUSH([Fortran])
    AC_LINK_IFELSE([AC_LANG_PROGRAM([],
      [[
        call magmaf_zhegvd
      ]])], [afb_linalg_has_magma="yes"], [afb_linalg_has_magma="no"])
    AC_LANG_POP([Fortran])
    AC_MSG_RESULT([${afb_linalg_has_magma}])
  fi

  dnl Final adjustments
  if test "${afb_linalg_has_lapacke}" = "yes"; then
    afb_linalg_has_incs="yes"
  fi
  if test "${afb_linalg_has_blas}" -a \
          "${afb_linalg_has_lapack}" = "yes"; then
    afb_linalg_has_libs="yes"
  fi
  if test "${afb_linalg_has_libs}" = "yes"; then
    afb_linalg_ext_ok="yes"
  else
    afb_linalg_ext_ok="no"
  fi

  dnl Restore environment
  CPPFLAGS="${tmp_saved_CPPFLAGS}"
  FCFLAGS="${tmp_saved_FCFLAGS}"
  LIBS="${tmp_saved_LIBS}"
]) # AFB_CHECK_LINALG



# AFB_LINALG_DETECT()
# -------------------
#
# Looks for an external linear algebra implementation exactly as Abinit
# does (same --with-linalg-flavor syntax, vendor settings, detection
# sequences and link tests, see config/m4/sd_math_linalg*.m4 in Abinit),
# so that the fallbacks and Abinit select the same libraries on a given
# machine. On success, sets with_linalg_incs and with_linalg_libs, which
# disables the internal LINALG fallback.
#
AC_DEFUN([AFB_LINALG_DETECT],[
  dnl Init
  afb_linalg_det_valid_flavors="auto acml aocl asl atlas easybuild elpa essl libsci magma mkl netlib none openblas plasma slate"
  afb_linalg_det_chk_serial=""
  afb_linalg_det_chk_mpi=""

  AC_ARG_WITH([linalg-flavor],
    AS_HELP_STRING([--with-linalg-flavor],
      [Linear algebra flavor to look for, with the same syntax as for Abinit (default: auto)]),
    [ for tmp_flavor in `echo "${withval}" | sed -e 's/+/ /g'`; do
        tmp_flavor_ok="no"
        for tmp_valid in ${afb_linalg_det_valid_flavors}; do
          test "${tmp_flavor}" = "${tmp_valid}" && tmp_flavor_ok="yes"
        done
        if test "${tmp_flavor_ok}" != "yes"; then
          AC_MSG_ERROR([invalid linear algebra flavor: '${tmp_flavor}'])
        fi
      done
      unset tmp_flavor tmp_flavor_ok tmp_valid
      afb_linalg_det_flavor="${withval}"],
    [ afb_linalg_det_flavor="auto"])

  dnl Explicit LINALG options and the 'none' flavor bypass the detection
  if test "${enable_linalg}" = "yes" -o \
          "${with_linalg_incs}" != "" -o \
          "${with_linalg_libs}" != "" -o \
          "${afb_linalg_det_flavor}" = "none"; then
    AC_MSG_NOTICE([skipping the detection of external linear algebra])
  else
    _AFB_LINALG_DETECT_SEQUENCES
    _AFB_LINALG_DETECT_EXPLORE

    AC_MSG_CHECKING([for the detected linear algebra flavor])
    if test "${afb_linalg_det_serial_ok}" = "yes"; then
      afb_linalg_det_flavor_found=`echo "${afb_linalg_det_flavor_found}" | tr '+' '\n' | sort -u | paste -sd+ -`
      AC_MSG_RESULT([${afb_linalg_det_flavor_found}])

      dnl Compile flags go to the include flags, link flags to the libraries
      with_linalg_incs=""
      for tmp_flag in ${afb_linalg_det_fcflags} ${afb_linalg_det_cppflags} ${afb_linalg_det_cflags}; do
        case " ${with_linalg_incs} " in
          *" ${tmp_flag} "*)
            ;;
          *)
            with_linalg_incs="${with_linalg_incs} ${tmp_flag}"
            ;;
        esac
      done
      unset tmp_flag
      with_linalg_incs=`echo ${with_linalg_incs}`
      dnl Link flags may have been added once per component
      tmp_ldflags=""
      for tmp_flag in ${afb_linalg_det_ldflags}; do
        case " ${tmp_ldflags} " in
          *" ${tmp_flag} "*)
            ;;
          *)
            tmp_ldflags="${tmp_ldflags} ${tmp_flag}"
            ;;
        esac
      done
      unset tmp_flag
      with_linalg_libs=`echo ${tmp_ldflags} ${afb_linalg_det_libs}`
      unset tmp_ldflags
      AC_MSG_NOTICE([linear algebra include flags: ${with_linalg_incs:-none}])
      AC_MSG_NOTICE([linear algebra libraries: ${with_linalg_libs:-none required}])

      dnl Flags may all be empty (e.g. Cray LibSci), in which case they
      dnl are not enough to disable the internal LINALG fallback
      enable_linalg="no"
      if test "${afb_has_mpi}" = "yes" -a "${afb_linalg_det_has_scalapack}" != "yes"; then
        AC_MSG_WARN([no ScaLAPACK found, which ELPA requires])
      fi
    else
      AC_MSG_RESULT([none])
      if test "${afb_linalg_det_flavor}" = "auto"; then
        AC_MSG_NOTICE([no external linear algebra found => using the internal LINALG fallback])
      else
        AC_MSG_ERROR([the requested linear algebra flavor '${afb_linalg_det_flavor}' does not work])
      fi
    fi
  fi
]) # AFB_LINALG_DETECT



# _AFB_LINALG_DETECT_SEQUENCES()
# ------------------------------
#
# Sets the serial and MPI detection sequences (see _SD_LINALG_CHECK_FLAVOR
# in Abinit).
#
AC_DEFUN([_AFB_LINALG_DETECT_SEQUENCES],[
  if test "${afb_linalg_det_flavor}" = "auto"; then

    dnl Set generic flavors first
    afb_linalg_det_chk_serial="netlib"
    if test "${afb_has_mpi}" = "yes"; then
      afb_linalg_det_chk_mpi="netlib"
    fi

    dnl Refine with vendor-specific flavors
    case "${afb_fc_vendor}" in
      gnu)
        if test "${MKLROOT}" != ""; then
          afb_linalg_det_chk_serial="mkl ${afb_linalg_det_chk_serial}"
        fi
        afb_linalg_det_chk_serial="openblas atlas ${afb_linalg_det_chk_serial}"
        AC_CHECK_PROG([PKG_CONFIG], [pkg-config], [pkg-config], [no])
        if test "${PKG_CONFIG}" != "no"; then
          afb_linalg_det_chk_serial="${afb_linalg_det_chk_serial} openblas_pkg"
        fi
        ;;
      intel)
        afb_linalg_det_chk_serial="mkl atlas ${afb_linalg_det_chk_serial}"
        afb_linalg_det_chk_mpi="mkl netlib"
        AC_CHECK_PROG([PKG_CONFIG], [pkg-config], [pkg-config], [no])
        if test "${PKG_CONFIG}" != "no"; then
          afb_linalg_det_chk_serial="${afb_linalg_det_chk_serial} openblas_pkg"
        fi
        ;;
    esac

    dnl Cray LibSci comes first on a Cray Programming Environment, since
    dnl the compiler wrappers link it automatically when it is loaded
    if test "${afb_cray_pe}" = "yes"; then
      afb_linalg_det_chk_serial="libsci ${afb_linalg_det_chk_serial}"
      if test "${afb_has_mpi}" = "yes"; then
        afb_linalg_det_chk_mpi="libsci ${afb_linalg_det_chk_mpi}"
      fi
    fi

  else

    dnl Reformat flavor
    tmp_netlib_explicit=`echo "${afb_linalg_det_flavor}" | grep "netlib"`
    tmp_iter=`echo "${afb_linalg_det_flavor}" | tr '+' '\n' | grep -v "netlib" | sort -u`

    dnl Check flavor unicity for each detection sequence
    for tmp_flavor in ${tmp_iter}; do
      case "${tmp_flavor}" in
        easybuild|libsci|mkl)
          if test "${afb_linalg_det_chk_serial}" != ""; then
            AC_MSG_ERROR([only one serial linear algebra flavor is permitted])
          fi
          afb_linalg_det_chk_serial="${tmp_flavor}"
          if test "${afb_has_mpi}" = "yes"; then
            if test "${afb_linalg_det_chk_mpi}" != ""; then
              AC_MSG_ERROR([only one MPI linear algebra flavor is permitted])
            fi
            afb_linalg_det_chk_mpi="${tmp_flavor}"
          fi
          ;;
        elpa|magma|slate)
          dnl Accelerators are not needed to build the fallbacks
          AC_MSG_NOTICE([ignoring '${tmp_flavor}' to build the fallbacks])
          ;;
        plasma)
          if test "${afb_has_mpi}" = "yes"; then
            if test "${afb_linalg_det_chk_mpi}" != ""; then
              AC_MSG_ERROR([only one MPI linear algebra flavor is permitted])
            fi
            afb_linalg_det_chk_mpi="${tmp_flavor}"
          else
            AC_MSG_NOTICE([ignoring '${tmp_flavor}', since MPI is disabled])
          fi
          ;;
        *)
          if test "${afb_linalg_det_chk_serial}" != ""; then
            AC_MSG_ERROR([only one serial linear algebra flavor is permitted])
          fi
          afb_linalg_det_chk_serial="${tmp_flavor}"
          ;;
      esac
    done

    dnl Some vendors only provide a partial serial linear algebra support
    case "${afb_linalg_det_chk_serial}" in
      atlas|openblas)
        afb_linalg_det_chk_serial="${afb_linalg_det_chk_serial} netlib"
        if test "${tmp_netlib_explicit}" != "" -a \
                "${afb_has_mpi}" = "yes" -a \
                "${afb_linalg_det_chk_mpi}" = ""; then
          afb_linalg_det_chk_mpi="netlib"
        fi
        ;;
    esac
    if test "${afb_linalg_det_chk_serial}" = ""; then
      afb_linalg_det_chk_serial="netlib"
    fi
    unset tmp_flavor tmp_iter tmp_netlib_explicit

  fi

  dnl Display detection sequences
  AC_MSG_CHECKING([for the serial linear algebra detection sequence])
  AC_MSG_RESULT([${afb_linalg_det_chk_serial}])
  if test "${afb_has_mpi}" = "yes"; then
    AC_MSG_CHECKING([for the MPI linear algebra detection sequence])
    if test "${afb_linalg_det_chk_mpi}" = ""; then
      AC_MSG_RESULT([none])
    else
      AC_MSG_RESULT([${afb_linalg_det_chk_mpi}])
    fi
  fi
]) # _AFB_LINALG_DETECT_SEQUENCES



# _AFB_LINALG_DETECT_EXPLORE()
# ----------------------------
#
# Goes through the detection sequences to find BLAS, LAPACK, BLACS and
# ScaLAPACK (see _SD_LINALG_EXPLORE in Abinit).
#
AC_DEFUN([_AFB_LINALG_DETECT_EXPLORE],[
  dnl Init
  afb_linalg_det_cppflags=""
  afb_linalg_det_cflags=""
  afb_linalg_det_fcflags=""
  afb_linalg_det_ldflags=""
  afb_linalg_det_libs=""
  afb_linalg_det_flavor_found=""
  afb_linalg_det_has_blas="unknown"
  afb_linalg_det_has_lapack="unknown"
  afb_linalg_det_has_blacs="unknown"
  afb_linalg_det_has_scalapack="unknown"
  afb_linalg_det_serial_ok="no"
  tmp_blas_vendor=""
  tmp_lapack_vendor=""
  tmp_blacs_vendor=""

  dnl Prepare environment
  tmp_saved_CPPFLAGS="${CPPFLAGS}"
  tmp_saved_CFLAGS="${CFLAGS}"
  tmp_saved_FCFLAGS="${FCFLAGS}"
  tmp_saved_LDFLAGS="${LDFLAGS}"
  tmp_saved_LIBS="${LIBS}"

  dnl Look for serial linear algebra support
  for tmp_vendor in ${afb_linalg_det_chk_serial}; do

    dnl Configure vendor libraries
    _AFB_LINALG_DETECT_RESTORE_FLAGS
    _AFB_LINALG_DETECT_VENDOR([${tmp_vendor}])

    dnl Look for BLAS
    tmp_proceed=`echo "${afb_linalg_vnd_provided}" | grep "blas"`
    if test "${tmp_proceed}" != "" -a \
            "${afb_linalg_det_has_blas}" != "yes"; then
      CPPFLAGS="${CPPFLAGS} ${afb_linalg_vnd_cppflags}"
      CFLAGS="${CFLAGS} ${afb_linalg_vnd_cflags}"
      FCFLAGS="${FCFLAGS} ${afb_linalg_vnd_fcflags}"
      LDFLAGS="${LDFLAGS} ${afb_linalg_vnd_ldflags}"
      LIBS="${afb_linalg_vnd_blas_libs} ${LIBS}"
      AC_MSG_CHECKING([${tmp_vendor} libraries for BLAS])
      if test "${afb_linalg_vnd_blas_libs}" = ""; then
        AC_MSG_RESULT([none required])
      else
        AC_MSG_RESULT([${afb_linalg_vnd_blas_libs}])
      fi
      _AFB_LINALG_DETECT_LINK([BLAS], [zgemm], [afb_linalg_det_has_blas])
      if test "${afb_linalg_det_has_blas}" = "yes"; then
        afb_linalg_det_flavor_found="${tmp_vendor}"
        tmp_blas_vendor="${tmp_vendor}"
        afb_linalg_det_cppflags="${afb_linalg_vnd_cppflags}"
        afb_linalg_det_cflags="${afb_linalg_vnd_cflags}"
        afb_linalg_det_fcflags="${afb_linalg_vnd_fcflags}"
        afb_linalg_det_ldflags="${afb_linalg_vnd_ldflags}"
        afb_linalg_det_libs="${afb_linalg_vnd_blas_libs}"
      fi
    fi

    dnl Look for LAPACK
    tmp_proceed=`echo "${afb_linalg_vnd_provided}" | grep "lapack"`
    if test "${tmp_proceed}" != "" -a \
            "${afb_linalg_det_has_blas}" = "yes" -a \
            "${afb_linalg_det_has_lapack}" != "yes"; then
      AC_MSG_CHECKING([${tmp_vendor} libraries for LAPACK])
      if test "${afb_linalg_vnd_lapack_libs}" = ""; then
        AC_MSG_RESULT([none required])
      else
        AC_MSG_RESULT([${afb_linalg_vnd_lapack_libs}])
        LIBS="${afb_linalg_vnd_lapack_libs} ${LIBS}"
      fi
      _AFB_LINALG_DETECT_LINK([LAPACK], [zhpev], [afb_linalg_det_has_lapack])
      if test "${afb_linalg_det_has_lapack}" = "yes"; then
        afb_linalg_det_flavor_found="${afb_linalg_det_flavor_found}+${tmp_vendor}"
        tmp_lapack_vendor="${tmp_vendor}"
        if test "${tmp_lapack_vendor}" != "${tmp_blas_vendor}"; then
          _AFB_LINALG_DETECT_ADD_VENDOR_FLAGS
        fi
        test "${afb_linalg_vnd_lapack_libs}" != "" && \
          afb_linalg_det_libs="${afb_linalg_vnd_lapack_libs} ${afb_linalg_det_libs}"
        break
      else
        afb_linalg_det_has_blas="no"
      fi
    fi

  done

  dnl Checkpoint: validate the serial linear algebra support
  if test "${afb_linalg_det_has_blas}" = "yes" -a \
          "${afb_linalg_det_has_lapack}" = "yes"; then
    afb_linalg_det_serial_ok="yes"
  fi

  dnl Look for MPI linear algebra support
  if test "${afb_linalg_det_serial_ok}" = "yes" -a "${afb_has_mpi}" = "yes"; then
    for tmp_vendor in ${afb_linalg_det_chk_mpi}; do

      dnl Configure vendor libraries
      _AFB_LINALG_DETECT_RESTORE_FLAGS
      _AFB_LINALG_DETECT_VENDOR([${tmp_vendor}])

      dnl Look for BLACS
      tmp_proceed=`echo "${afb_linalg_vnd_provided}" | grep "blacs"`
      if test "${tmp_proceed}" != "" -a \
              "${afb_linalg_det_has_blacs}" != "yes"; then
        AC_MSG_CHECKING([${tmp_vendor} libraries for BLACS])
        tmp_blacs_saved_LIBS="${LIBS}"
        if test "${afb_linalg_vnd_blacs_libs}" = ""; then
          AC_MSG_RESULT([none required])
        else
          AC_MSG_RESULT([${afb_linalg_vnd_blacs_libs}])
          LIBS="${afb_linalg_vnd_blacs_libs} ${LIBS}"
        fi
        _AFB_LINALG_DETECT_LINK([BLACS], [blacs_gridinit], [afb_linalg_det_has_blacs])
        dnl Do not let missing BLACS libraries break the ScaLAPACK check:
        dnl since ScaLAPACK 2.0, BLACS is part of libscalapack
        if test "${afb_linalg_det_has_blacs}" != "yes"; then
          LIBS="${tmp_blacs_saved_LIBS}"
        fi
        unset tmp_blacs_saved_LIBS
        if test "${afb_linalg_det_has_blacs}" = "yes"; then
          afb_linalg_det_flavor_found="${afb_linalg_det_flavor_found}+${tmp_vendor}"
          tmp_blacs_vendor="${tmp_vendor}"
          if test "${tmp_blacs_vendor}" != "${tmp_lapack_vendor}"; then
            _AFB_LINALG_DETECT_ADD_VENDOR_FLAGS
          fi
          test "${afb_linalg_vnd_blacs_libs}" != "" && \
            afb_linalg_det_libs="${afb_linalg_vnd_blacs_libs} ${afb_linalg_det_libs}"
        fi
      fi

      dnl Look for ScaLAPACK
      tmp_proceed=`echo "${afb_linalg_vnd_provided}" | grep "scalapack"`
      if test "${tmp_proceed}" != "" -a \
              "${afb_linalg_det_has_scalapack}" != "yes"; then
        AC_MSG_CHECKING([${tmp_vendor} libraries for ScaLAPACK])
        if test "${afb_linalg_vnd_scalapack_libs}" = ""; then
          AC_MSG_RESULT([none required])
        else
          AC_MSG_RESULT([${afb_linalg_vnd_scalapack_libs}])
          LIBS="${afb_linalg_vnd_scalapack_libs} ${LIBS}"
        fi
        _AFB_LINALG_DETECT_LINK([ScaLAPACK], [pzheevx], [afb_linalg_det_has_scalapack])
        if test "${afb_linalg_det_has_scalapack}" = "yes"; then
          afb_linalg_det_flavor_found="${afb_linalg_det_flavor_found}+${tmp_vendor}"
          if test "${tmp_vendor}" != "${tmp_blacs_vendor}"; then
            _AFB_LINALG_DETECT_ADD_VENDOR_FLAGS
          fi
          test "${afb_linalg_vnd_scalapack_libs}" != "" && \
            afb_linalg_det_libs="${afb_linalg_vnd_scalapack_libs} ${afb_linalg_det_libs}"
          dnl BLACS may be provided by the ScaLAPACK library itself
          if test "${afb_linalg_det_has_blacs}" != "yes"; then
            _AFB_LINALG_DETECT_LINK([BLACS], [blacs_gridinit], [afb_linalg_det_has_blacs])
          fi
          break
        fi
      fi

    done
  fi

  dnl Restore environment
  CPPFLAGS="${tmp_saved_CPPFLAGS}"
  CFLAGS="${tmp_saved_CFLAGS}"
  FCFLAGS="${tmp_saved_FCFLAGS}"
  LDFLAGS="${tmp_saved_LDFLAGS}"
  LIBS="${tmp_saved_LIBS}"
  unset tmp_saved_CPPFLAGS tmp_saved_CFLAGS tmp_saved_FCFLAGS
  unset tmp_saved_LDFLAGS tmp_saved_LIBS
  unset tmp_vendor tmp_proceed tmp_blas_vendor tmp_lapack_vendor tmp_blacs_vendor
]) # _AFB_LINALG_DETECT_EXPLORE



# _AFB_LINALG_DETECT_RESTORE_FLAGS()
# ----------------------------------
#
# Resets the build flags to their initial values plus what has been
# found so far.
#
AC_DEFUN([_AFB_LINALG_DETECT_RESTORE_FLAGS],[
  CPPFLAGS="${tmp_saved_CPPFLAGS} ${afb_linalg_det_cppflags}"
  CFLAGS="${tmp_saved_CFLAGS} ${afb_linalg_det_cflags}"
  FCFLAGS="${tmp_saved_FCFLAGS} ${afb_linalg_det_fcflags}"
  LDFLAGS="${tmp_saved_LDFLAGS} ${afb_linalg_det_ldflags}"
  LIBS="${afb_linalg_det_libs} ${tmp_saved_LIBS}"
]) # _AFB_LINALG_DETECT_RESTORE_FLAGS



# _AFB_LINALG_DETECT_ADD_VENDOR_FLAGS()
# -------------------------------------
#
# Adds the build flags of the current vendor to what has been found.
#
AC_DEFUN([_AFB_LINALG_DETECT_ADD_VENDOR_FLAGS],[
  test "${afb_linalg_vnd_cppflags}" != "" && \
    afb_linalg_det_cppflags="${afb_linalg_det_cppflags} ${afb_linalg_vnd_cppflags}"
  test "${afb_linalg_vnd_cflags}" != "" && \
    afb_linalg_det_cflags="${afb_linalg_det_cflags} ${afb_linalg_vnd_cflags}"
  test "${afb_linalg_vnd_fcflags}" != "" && \
    afb_linalg_det_fcflags="${afb_linalg_det_fcflags} ${afb_linalg_vnd_fcflags}"
  test "${afb_linalg_vnd_ldflags}" != "" && \
    afb_linalg_det_ldflags="${afb_linalg_det_ldflags} ${afb_linalg_vnd_ldflags}"
]) # _AFB_LINALG_DETECT_ADD_VENDOR_FLAGS



# _AFB_LINALG_DETECT_LINK(COMPONENT, ROUTINE, RESULT_VAR)
# -------------------------------------------------------
#
# Checks whether a Fortran program calling ROUTINE can be linked.
#
AC_DEFUN([_AFB_LINALG_DETECT_LINK],[
  AC_MSG_CHECKING([for $1 support in the specified libraries])
  AC_LANG_PUSH([Fortran])
  AC_LINK_IFELSE([AC_LANG_PROGRAM([],
    [[
      call $2
    ]])], [$3="yes"], [$3="no"])
  AC_LANG_POP([Fortran])
  AC_MSG_RESULT([${$3}])
]) # _AFB_LINALG_DETECT_LINK



# _AFB_LINALG_DETECT_VENDOR(VENDOR)
# ---------------------------------
#
# Sets the build parameters of a linear algebra vendor (see
# _SD_LINALG_SET_VENDOR_FLAGS in Abinit).
#
AC_DEFUN([_AFB_LINALG_DETECT_VENDOR],[
  dnl Reset components
  afb_linalg_vnd_provided=""
  afb_linalg_vnd_cppflags=""
  afb_linalg_vnd_cflags=""
  afb_linalg_vnd_fcflags=""
  afb_linalg_vnd_ldflags=""
  afb_linalg_vnd_blas_libs=""
  afb_linalg_vnd_lapack_libs=""
  afb_linalg_vnd_blacs_libs=""
  afb_linalg_vnd_scalapack_libs=""

  dnl Update components according to specified vendor
  case "$1" in

    acml)
      afb_linalg_vnd_provided="blas lapack blacs scalapack"
      afb_linalg_vnd_blas_libs="-lacml -lacml_mv"
      ;;

    aocl|AOCL)
      dnl Abinit uses -lblis-mt with --enable-openmp
      afb_linalg_vnd_provided="blas lapack scalapack"
      afb_linalg_vnd_blas_libs="-lblis"
      afb_linalg_vnd_lapack_libs="-lflame"
      afb_linalg_vnd_scalapack_libs="-lscalapack"
      ;;

    asl)
      afb_linalg_vnd_provided="blas lapack lapacke blacs scalapack"
      afb_linalg_vnd_blas_libs="-lasl"
      ;;

    atlas)
      afb_linalg_vnd_provided="blas"
      afb_linalg_vnd_blas_libs="-lf77blas -lcblas -latlas"
      ;;

    debian-mpich)
      afb_linalg_vnd_provided="blas lapack blacs scalapack"
      afb_linalg_vnd_blas_libs="-lblas"
      afb_linalg_vnd_lapack_libs="-llapack"
      afb_linalg_vnd_blacs_libs="-lblacs-mpich -lblacsCinit-mpich -lblacsF77init-mpich"
      afb_linalg_vnd_scalapack_libs="-lscalapack-mpich"
      ;;

    debian-openmpi)
      afb_linalg_vnd_provided="blas lapack blacs scalapack"
      afb_linalg_vnd_blas_libs="-lblas"
      afb_linalg_vnd_lapack_libs="-llapack"
      afb_linalg_vnd_blacs_libs="-lblacs-openmpi -lblacsCinit-openmpi -lblacsF77init-openmpi"
      afb_linalg_vnd_scalapack_libs="-lscalapack-openmpi"
      ;;

    easybuild)
      afb_linalg_vnd_provided="blas lapack blacs scalapack"
      afb_linalg_vnd_blas_libs="-lopenblas"
      afb_linalg_vnd_blacs_libs="-lscalapack"
      ;;

    elpa|magma|plasma|slate)
      dnl No BLAS, LAPACK, BLACS nor ScaLAPACK
      afb_linalg_vnd_provided="$1"
      ;;

    essl)
      afb_linalg_vnd_provided="blas lapack lapacke blacs scalapack"
      afb_linalg_vnd_cflags="-qessl"
      afb_linalg_vnd_fcflags="-qessl"
      afb_linalg_vnd_ldflags="-qessl"
      afb_linalg_vnd_blas_libs="-lessl"
      ;;

    libsci)
      dnl Linked automatically by the Cray compiler wrappers (cc, CC, ftn)
      dnl when the cray-libsci module is loaded
      afb_linalg_vnd_provided="blas lapack blacs scalapack"
      if test "${afb_cray_wrappers}" != "yes"; then
        dnl Plain compilers (e.g. FC=gfortran on a Cray PE): link LibSci
        dnl explicitly, provided that the loaded LibSci variant has been
        dnl built for the same compiler as the one in use
        case "${PE_ENV}:${afb_fc_vendor}" in
          GNU:gnu|INTEL:intel|CRAY:cray|AOCC:llvm|AOCC:aocc)
            tmp_sci_libdir="${CRAY_LIBSCI_PREFIX_DIR}/lib"
            tmp_sci_name=`ls ${tmp_sci_libdir} 2>/dev/null | \
              sed -n -e 's/^lib\(sci_[[a-z]]*\)\.a$/\1/p' | head -n 1`
            if test "${tmp_sci_name}" != ""; then
              afb_linalg_vnd_ldflags="-L${tmp_sci_libdir}"
              afb_linalg_vnd_blas_libs="-l${tmp_sci_name}"
              afb_linalg_vnd_scalapack_libs="-l${tmp_sci_name}_mpi"
            fi
            unset tmp_sci_libdir tmp_sci_name
            ;;
        esac
      fi
      ;;

    mkl)
      if test "${MKLROOT}" = ""; then
        AC_MSG_ERROR([MKLROOT is not set, which means that MKL is not
                  properly configured])
      fi
      afb_linalg_vnd_provided="blas lapack blacs scalapack"
      case "${afb_fc_vendor}" in
        gnu)
          afb_linalg_vnd_cppflags="-I${MKLROOT}/include"
          afb_linalg_vnd_cflags="-m64"
          afb_linalg_vnd_fcflags="-m64 -I${MKLROOT}/include"
          afb_linalg_vnd_blas_libs="-L${MKLROOT}/lib/intel64 -Wl,--no-as-needed -lmkl_gf_lp64 -lmkl_sequential -lmkl_core -lpthread -lm -ldl"
          if test "${afb_has_mpi}" = "yes"; then
            afb_linalg_vnd_blas_libs="-L${MKLROOT}/lib/intel64 -Wl,--no-as-needed -lmkl_scalapack_lp64 -lmkl_gf_lp64 -lmkl_sequential -lmkl_core -lmkl_blacs_intelmpi_lp64 -lpthread -lm -ldl"
          fi
          ;;
        intel)
          afb_linalg_vnd_cppflags="-I${MKLROOT}/include"
          afb_linalg_vnd_fcflags="-I${MKLROOT}/include"
          if test "${afb_has_mpi}" = "yes"; then
            afb_linalg_vnd_ldflags="-qmkl=cluster"
          else
            afb_linalg_vnd_ldflags="-qmkl"
          fi
          ;;
        *)
          AC_MSG_ERROR([MKL is only supported with GNU and Intel compilers])
          ;;
      esac
      ;;

    netlib)
      afb_linalg_vnd_provided="blas lapack lapacke blacs scalapack"
      afb_linalg_vnd_blas_libs="-lblas"
      afb_linalg_vnd_lapack_libs="-llapack"
      afb_linalg_vnd_blacs_libs="-lblacs -lblacsCinit -lblacsF77init"
      afb_linalg_vnd_scalapack_libs="-lscalapack"
      ;;

    nvpl)
      afb_linalg_vnd_provided="blas lapack scalapack"
      afb_linalg_vnd_blas_libs="-Mnvpl=blas"
      afb_linalg_vnd_lapack_libs="-Mnvpl=lapack"
      afb_linalg_vnd_scalapack_libs="-Mscalapack"
      ;;

    openblas)
      afb_linalg_vnd_provided="blas"
      afb_linalg_vnd_blas_libs="-lopenblas -lpthread"
      ;;

    openblas_pkg)
      afb_linalg_vnd_provided="blas lapack"
      AC_PATH_TOOL([PKG_CONFIG], [pkg-config])
      if "${PKG_CONFIG}" --exists openblas; then
        afb_linalg_vnd_blas_libs=`${PKG_CONFIG} --libs --keep-system-libs openblas`
      else
        afb_linalg_vnd_blas_libs="-lopenblas -lpthread"
      fi
      if "${PKG_CONFIG}" --exists lapacke; then
        afb_linalg_vnd_lapack_libs=`${PKG_CONFIG} --libs --keep-system-libs lapacke`
      elif "${PKG_CONFIG}" --exists lapack; then
        afb_linalg_vnd_lapack_libs=`${PKG_CONFIG} --libs --keep-system-libs lapack`
      else
        afb_linalg_vnd_lapack_libs="-llapack"
      fi
      ;;

    *)
      AC_MSG_ERROR([no library settings for linear algebra flavor '$1'])
      ;;

  esac
]) # _AFB_LINALG_DETECT_VENDOR
