#.rst:
# FindFstrcmp
# --------
# Finds the fstrcmp library
#
# This will define the following variables::
#
# FSTRCMP_FOUND - system has libfstrcmp
# FSTRCMP_INCLUDE_DIRS - the libfstrcmp include directory
# FSTRCMP_LIBRARIES - the libfstrcmp libraries
#

if(ENABLE_INTERNAL_FSTRCMP)
  find_program(LIBTOOL libtool REQUIRED)
  include(ExternalProject)
  include(cmake/scripts/common/ModuleHelpers.cmake)

  set(MODULE_LC fstrcmp)

  SETUP_BUILD_VARS()

  set(FSTRCMP_LIBRARY ${CMAKE_BINARY_DIR}/${CORE_BUILD_DIR}/lib/libfstrcmp.a)
  set(FSTRCMP_INCLUDE_DIR ${CMAKE_BINARY_DIR}/${CORE_BUILD_DIR}/include)
  set(FSTRCMP_VER ${${MODULE}_VER})

  externalproject_add(fstrcmp
                      URL ${${MODULE}_URL}
                      URL_HASH ${${MODULE}_HASH}
                      DOWNLOAD_DIR ${TARBALL_DIR}
                      DOWNLOAD_NAME ${${MODULE}_ARCHIVE}
                      PREFIX ${CORE_BUILD_DIR}/fstrcmp
                      PATCH_COMMAND autoreconf -vif
                      CONFIGURE_COMMAND ./configure --prefix ${CMAKE_BINARY_DIR}/${CORE_BUILD_DIR}
                      BUILD_BYPRODUCTS ${FSTRCMP_LIBRARY}
                      BUILD_COMMAND make lib/libfstrcmp.la
                      BUILD_IN_SOURCE 1
                      INSTALL_COMMAND make install-libdir install-include)

  set_target_properties(fstrcmp PROPERTIES FOLDER "External Projects")
else()
  if(PKG_CONFIG_FOUND)
    pkg_check_modules(PC_FSTRCMP fstrcmp QUIET)
  endif()

  find_path(FSTRCMP_INCLUDE_DIR NAMES fstrcmp.h
                                 PATHS ${PC_FSTRCMP_INCLUDEDIR})

  find_library(FSTRCMP_LIBRARY NAMES fstrcmp
                                PATHS ${PC_FSTRCMP_LIBDIR})

  set(FSTRCMP_VER ${PC_FSTRCMP_VERSION})
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Fstrcmp
                                  REQUIRED_VARS FSTRCMP_LIBRARY FSTRCMP_INCLUDE_DIR
                                  VERSION_VAR FSTRCMP_VER)

if(FSTRCMP_FOUND)
  set(FSTRCMP_INCLUDE_DIRS ${FSTRCMP_INCLUDE_DIR})
  set(FSTRCMP_LIBRARIES ${FSTRCMP_LIBRARY})

  if(NOT TARGET fstrcmp)
    add_library(fstrcmp UNKNOWN IMPORTED)
    set_target_properties(fstrcmp PROPERTIES
                                  IMPORTED_LOCATION "${FSTRCMP_LIBRARY}"
                                  INTERFACE_INCLUDE_DIRECTORIES "${FSTRCMP_INCLUDE_DIR}")
  endif()

  set_property(GLOBAL APPEND PROPERTY INTERNAL_DEPS_PROP fstrcmp)
endif()

mark_as_advanced(FSTRCMP_INCLUDE_DIR FSTRCMP_LIBRARY)
