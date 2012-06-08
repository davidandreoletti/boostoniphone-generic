boostoniphone-generic

ABOUT
================================================================================

Builds a Boost framework for the iPhone.

boostoniphone-generic improves Pete Goodlffe's original boostoniphone. This new 
script builds most C++ Boost Libraries for iOS.

"Creates a set of universal libraries that can be used on an iPhone and in the
iPhone simulator. Then creates a pseudo-framework to make using boost in Xcode
less painful" (from Pete Goodliffe's original boostoniphone documentation)

MOTIVATION:
================================================================================

Boost On iPhone was initially created by Pete Goodliffe. However, some important 
libraries (eg: Boost Math or Boost Test) could not be integrated into 
boost.framework produced by the script. This version fixes those issues as well 
as improve and add new functionalities (see CHANGELOG.rst for further 
information)

INSTALLATION:
================================================================================

- Run ./boost.sh (configuration options are described at the top of the script)
- Grab a cuppa.
- Enjoy your boost.framework.

DOCUMENTATION
================================================================================

The script is fully documented.

SOURCE
================================================================================

Main source repository: 

https://github.com/davidandreoletti/boostoniphone-generic.git

DEVELOPMENT STATUS
================================================================================

This implementation is in ALPHA version. I only implements features required 
for my own needs but feel free to extend it.

CHANGELOG
================================================================================

See CHANGELOG.rst

REQUIREMENTS
================================================================================

See CHANGELOG.rst

CONTRIBUTORS:
================================================================================

If you would like to contribute, feel free to drop me an email or contribute 
patches.

AUTHOR
================================================================================
- Pete Goodliffe    http://www.goodliffe.net
    - Original author of boostoniphone (http://gitorious.org/boostoniphone)

- David Andreoletti http://davidandreoletti.com 
    - Improved various aspects of boostoniphone's boost.sh script

