Changelog:
================================================================================

Release 1.3.3f0:
================================================================================

- PBSTLIOS-24: Added support for detecting Xcode version
- PBSTLIOS-26: Added support for dry-run compilation (Script debugging feature ONLY)

Release 1.3.2f0:
================================================================================

- PBSTLIOS-23: Retrieved only first Xcode.app path when querying list of Xcode.app installed

- PBSTLIOS-22: Changed default iOS SDK to latest

Release 1.3.1f0:
================================================================================

- PBSTLIOS-20: Generated boost.framework not copied into prefix directory

Release 1.3.0f0:
================================================================================

- PBSTLIOS-18: Moved generated framework to prefix directory


Release 1.2.0f0:
================================================================================

- PBSTLIOS-15: Updated script to work with Xcode 4.4 and Boost 1.50.0 based on https://svn.boost.org/trac/boost/ticket/6686.

Sucessfully tested on the following configurations:

- Mac OS X 10.8, Xcode 4.4 (Build 4F250), iOS SDK 5.1, Boost 1.50.0

Notes: 

- Support for ALL Boost versions prior 1_50_0 is dropped.

- Boost is now compiled with Clang.

Release 1.1.0f0:
================================================================================

- PBSTLIOS-11: Fixed retrieving list of Boost libraries requiring separate build for Boost 1.48.0

- PBSTLIOS-12: Added support for optional sources build

- PBSTLIOS-13: Added support for optional build artifacts cleaning

Sucessfully tested on the following configurations:

- Mac OS X 10.6.8, Xcode 4.0.2 (Build 4A2002a), iOS SDK 4.3, Boost 1.48.0
- Mac OS X 10.6.8, Xcode 4.0.2 (Build 4A2002a), iOS SDK 4.3, Boost 1.44.0

Notes:


Release 1.0.0f0:
================================================================================

- PBSTLIOS-1: Added support to automatically download Boost version form Sourceforge.net

- PBSTLIOS-2: Added support to automatically discover Xcode path

- PBSTLIOS-3: Added support to automatically use the maximun number of logical cores when using bjam

- PBSTLIOS-4: Added support for autodetection of GCC/Clang versions

- PBSTLIOS-5: Added support to not build specific libraries

- PBSTLIOS-6: Added support for Boost Test Library integration into Boost.framework

- PBSTLIOS-7: Added support for Boost Math integration with boost.framework

- PBSTLIOS-8: Added README.rst file

- PBSTLIOS-9: Added CHANGELOG file

Sucessfully tested on the following configurations:

- Mac OS X 10.6.8, Xcode 4.0.2 (Build 4A2002a), iOS SDK 4.3, Boost 1.44.0