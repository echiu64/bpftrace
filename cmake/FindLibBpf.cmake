# - Try to find libbpf
# Once done this will define
#
#  LIBBPF_FOUND - system has libbpf
#  LIBBPF_INCLUDE_DIRS - the libbpf include directory
#  LIBBPF_LIBRARIES - Link these to use libbpf
#  LIBBPF_DEFINITIONS - Compiler switches required for using libbpf

#if (LIBBPF_LIBRARIES AND LIBBPF_INCLUDE_DIRS)
#  set (LibBpf_FIND_QUIETLY TRUE)
#endif (LIBBPF_LIBRARIES AND LIBBPF_INCLUDE_DIRS)

find_path (LIBBPF_INCLUDE_DIRS
  NAMES
    bpf/bpf.h
    bpf/btf.h
    bcc/libbpf.h
  PATHS
    /usr/include
    /usr/local/include
    /usr/local/include/bcc
    /opt/local/include
    /sw/include
    ENV CPATH)

find_path (BTF_INCLUDE_DIR
  NAMES
    linux/btf.h
  PATHS
    /usr/include
    /usr/local/include
    /usr/local/include/bcc/compat)

message(" o BTF_INCLUDE_DIR: ${BTF_INCLUDE_DIR}")
if(BTF_INCLUDE_DIR)
  list(APPEND LIBBPF_INCLUDE_DIRS ${BTF_INCLUDE_DIR})
endif()

message(" o LIBBPF_INCLUDE_DIRS: ${LIBBPF_INCLUDE_DIRS}")

find_library (LIBBPF_LIBRARIES
  NAMES
    bpf
  PATHS
    /usr/lib
    /usr/local/lib
    /opt/local/lib
    /sw/lib
    ENV LIBRARY_PATH
    ENV LD_LIBRARY_PATH)

include (FindPackageHandleStandardArgs)

# handle the QUIETLY and REQUIRED arguments and set LIBBPF_FOUND to TRUE if all listed variables are TRUE
FIND_PACKAGE_HANDLE_STANDARD_ARGS(LibBpf "Please install the libbpf development package"
  LIBBPF_LIBRARIES
  LIBBPF_INCLUDE_DIRS)

mark_as_advanced(LIBBPF_INCLUDE_DIRS LIBBPF_LIBRARIES)

# We need btf_dump support, set LIBBPF_BTF_DUMP_FOUND
# when it's found.
MESSAGE("LIBBPF_INCLUDE_DIRS: ${LIBBPF_INCLUDE_DIRS}")
if (LIBBPF_FOUND)
  MESSAGE("LIBBPF_FOUND")
  include(CheckSymbolExists)
  # adding also elf for static build check
  SET(CMAKE_REQUIRED_LIBRARIES ${LIBBPF_LIBRARIES} elf z)
  # libbpf quirk, needs upstream fix
  SET(CMAKE_REQUIRED_DEFINITIONS -include stdbool.h)
  check_symbol_exists(btf_dump_printf_fn_t "${LIBBPF_INCLUDE_DIRS}/bcc/btf.h" HAVE_BTF_DUMP)
  if (HAVE_BTF_DUMP)
    MESSAGE("HAVE_BTF_DUMP")
    set(LIBBPF_BTF_DUMP_FOUND TRUE)
  else()
    MESSAGE("NOT_HAVE_BTF_DUMP, set true anyways")
    set(LIBBPF_BTF_DUMP_FOUND TRUE)
  endif()
  check_symbol_exists(btf_dump__emit_type_decl "${LIBBPF_INCLUDE_DIRS}/bcc/btf.h" HAVE_LIBBPF_BTF_DUMP_EMIT_TYPE_DECL)
  SET(CMAKE_REQUIRED_DEFINITIONS)
  SET(CMAKE_REQUIRED_LIBRARIES)
endif()
