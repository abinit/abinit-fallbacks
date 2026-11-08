# -*- Autoconf -*-
#
# MPI detection helper inspired by arch-mpi in the ABINIT tree.
#

# AFB_MPI_CHECK_CC()
# -------------------
#
# Checks whether the C compiler is able to produce MPI binaries.
# Sets afb_mpi_cc_ok accordingly (yes/no).
#
AC_DEFUN([AFB_MPI_CHECK_CC],[
  afb_mpi_cc_ok="no"

  # Back-up build environment
  AFB_ENV_BACKUP

  # Prepare build environment
  CPPFLAGS="${CPPFLAGS} ${afb_mpi_incs}"
  LDFLAGS="${CC_LDFLAGS}"
  LIBS="${CC_LIBS} ${afb_mpi_libs}"

  # Try to compile a C MPI program
  AC_MSG_CHECKING([whether the C compiler supports MPI])
  AC_LANG_PUSH([C])
  AC_LINK_IFELSE([AC_LANG_PROGRAM(
    [[
#include <stdlib.h>
#include <mpi.h>
    ]],
    [[
      int rc;

      MPI_Init(NULL, NULL);
      rc = MPI_Finalize();
    ]])], [afb_mpi_cc_ok="yes"], [afb_mpi_cc_ok="no"])
  AC_LANG_POP([C])
  AC_MSG_RESULT([${afb_mpi_cc_ok}])

  # Restore build environment
  AFB_ENV_RESTORE
]) # AFB_MPI_CHECK_CC


# AFB_MPI_CHECK_FC()
# -------------------
#
# Checks whether the Fortran compiler is able to produce MPI binaries.
# Sets afb_mpi_fc_ok accordingly (yes/no).
#
AC_DEFUN([AFB_MPI_CHECK_FC],[
  afb_mpi_fc_ok="no"

  # Back-up build environment
  AFB_ENV_BACKUP

  # Prepare build environment
  CPPFLAGS="${CPPFLAGS} ${afb_mpi_incs}"
  LDFLAGS="${FC_LDFLAGS}"
  LIBS="${FC_LIBS} ${afb_mpi_libs}"

  # Try to compile a Fortran MPI program
  AC_MSG_CHECKING([whether the Fortran compiler supports MPI])
  AC_LANG_PUSH([Fortran])
  AC_LINK_IFELSE([AC_LANG_PROGRAM([],
    [[
      include "mpif.h"
      integer :: ierr
      call mpi_init(ierr)
      call mpi_finalize(ierr)
    ]])], [afb_mpi_fc_ok="yes"], [afb_mpi_fc_ok="no"])
  AC_LANG_POP([Fortran])
  AC_MSG_RESULT([${afb_mpi_fc_ok}])

  # Restore build environment
  AFB_ENV_RESTORE
]) # AFB_MPI_CHECK_FC
