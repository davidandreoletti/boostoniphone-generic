# Locate Boost framework
# This module defines
# BOOST_LIBRARY, the name of the framework to link against
# BOOST_FOUND, True if and only if boost's framework was found (including headers and binary).
# BOOST_INCLUDE_DIR, where to find Boost's header files
#
# This modules REQUIRES any of the following variables to be set to search for Boost framework:
# - Environment variable BOOST_ROOT
# - Environment variable BOOSTROOT
# - Environment variable Boost_DIR

# macros
macro(FIND_FRAMEWORK fwname frameworkParentDirectory)
    find_library(FRAMEWORK_${fwname}
        NAMES ${fwname}
        PATHS ${frameworkParentDirectory}
        NO_DEFAULT_PATH)
    if( ${FRAMEWORK_${fwname}} STREQUAL FRAMEWORK_${fwname}-NOTFOUND)
        MESSAGE(ERROR ": Framework ${fwname} not found")
    else()
        MESSAGE(STATUS "Framework ${fwname} found at ${FRAMEWORK_${fwname}}")
    endif()
endmacro(FIND_FRAMEWORK)

# Slightly customised framework finder
MACRO(findpkg_framework fwk)
  IF(APPLE)
    SET(${fwk}_FRAMEWORK_PATH
      ${${fwk}_FRAMEWORK_SEARCH_PATH}
      ${CMAKE_FRAMEWORK_PATH}
      ~/Library/Frameworks
      /Library/Frameworks
      /System/Library/Frameworks
      /Network/Library/Frameworks
    )
    FOREACH(dir ${${fwk}_FRAMEWORK_PATH})
      SET(fwkpath ${dir}/${fwk}.framework)
      IF(EXISTS ${fwkpath})
        message("Find it!!!!! ${fwkpath}")
        SET(${fwk}_FRAMEWORK_INCLUDES ${${fwk}_FRAMEWORK_INCLUDES}
          ${fwkpath}/Headers ${fwkpath}/PrivateHeaders)
        if (NOT ${fwk}_LIBRARY_FWK)
          SET(${fwk}_LIBRARY_FWK "-framework ${fwk}")
        endif ()
      ENDIF(EXISTS ${fwkpath})
    ENDFOREACH(dir)
  ENDIF(APPLE)
ENDMACRO(findpkg_framework)

# Defines BOOST_ROOT. It contains absolute path to boost.framework
if ("$ENV{BOOST_ROOT}" STREQUAL "")
  if (NOT "$ENV{Boost_DIR}" STREQUAL "")
    set(ENV{BOOST_ROOT} $ENV{Boost_DIR})
  elseif (NOT "$ENV{BOOSTROOT}" STREQUAL "")
    set(ENV{BOOST_ROOT} $ENV{BOOSTROOT})
  endif()
endif()
set(BOOSTFRAMEWORK_ROOT $ENV{BOOST_ROOT})
message("BOOSTFRAMEWORK_ROOT = ${BOOSTFRAMEWORK_ROOT}")

if (APPLE)
  #
  # Frameworks only exist on Apple's OSes
  #
  message("CMAKE_FIND_ROOT_PATH = ${CMAKE_FIND_ROOT_PATH}")
  message("CMAKE_FIND_FRAMEWORK = ${CMAKE_FIND_FRAMEWORK}")
  message("CMAKE_FRAMEWORK_PATH = ${CMAKE_FRAMEWORK_PATH}")
  message("CMAKE_INCLUDE_PATH = ${CMAKE_INCLUDE_PATH}")
  message("CMAKE_LIBRARY_PATH = ${CMAKE_LIBRARY_PATH}")
  #set(CMAKE_FIND_FRAMEWORK ONLY)
  #SET(CMAKE_INCLUDE_PATH ${CMAKE_INCLUDE_PATH} ${BOOSTFRAMEWORK_ROOT})
  #SET(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} ${BOOSTFRAMEWORK_ROOT})
  #set(CMAKE_FRAMEWORK_PATH ${BOOSTFRAMEWORK_ROOT} ${CMAKE_FRAMEWORK_PATH})
  message("CMAKE_FIND_ROOT_PATH = ${CMAKE_FIND_ROOT_PATH}")
  message("CMAKE_FIND_FRAMEWORK = ${CMAKE_FIND_FRAMEWORK}")
  message("CMAKE_FRAMEWORK_PATH = ${CMAKE_FRAMEWORK_PATH}")
  message("CMAKE_INCLUDE_PATH = ${CMAKE_INCLUDE_PATH}")
  message("CMAKE_LIBRARY_PATH = ${CMAKE_LIBRARY_PATH}")

  find_library(
    BOOST_LIBRARY 
    NAMES boost
    PATHS ${BOOSTFRAMEWORK_ROOT}
    NO_DEFAULT_PATH)

  find_path(BOOST_INCLUDE_DIR 
    NAMES boost/config.hpp config.hpp
    PATHS PATHS ${BOOSTFRAMEWORK_ROOT}
  )

  message("BOOST_INCLUDE_DIR is ${BOOST_INCLUDE_DIR}")
  message("BOOST_LIBRARY is ${BOOST_LIBRARY}")

  # Check if Boost is considered found
  #set(BOOST_FOUND "NO")
  if (NOT "${BOOST_INCLUDE_DIR}" STREQUAL "BOOST_INCLUDE_DIR-NOTFOUND" AND DEFINED BOOST_LIBRARY)
    SET(BOOST_boost_LIBRARY "-framework boost" CACHE STRING "Boost framework for OSX") 
    #set(BOOST_FOUND "YES")
  endif()

  # handle the QUIETLY and REQUIRED arguments and set BOOSTFRAMEWORK_FOUND to TRUE if
  # all listed variables are TRUE
  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(
    BOOSTFramework
    DEFAULT_MSG
    BOOST_LIBRARY
    BOOST_INCLUDE_DIR)

  mark_as_advanced(BOOST_INCLUDE_DIR BOOST_LIBRARY)
endif (APPLE)
