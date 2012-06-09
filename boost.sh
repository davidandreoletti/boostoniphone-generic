#===============================================================================
# Filename:  boost.sh
# Authors:    
#            Pete Goodliffe  Copyright: (c) Copyright 2009 Pete Goodliffe
#               - Original Script
#            David Andreoletti (http://davidandreoletti.com)
#               - Refactored script to compile Boost version:
#                   - 1.44.0
#                   - 1.48.0
#               - Added support to automatically download Boost version from sourceforge.net
#               - Added support to automatically discover Xcode path.
#               - Added support to automatically set bjam with -j option with number of logical cores availables on the machine (See bjam's -j option).
#               - Added auto detection of GCC/Clang compiler version.
#               - Added support to not build specific libraries (via BOOST_NO_LIBS)
#               - Fixed Boost Test Library integration issue with Boost.framework (library not at the expected path)
#               - Fixed Boost Math Library integration issue with Boost.framework (library produces multiple libraries files)
#               - 
# Licence:   Please feel free to use this, with attribution
#===============================================================================
#
# Builds a Boost framework for the iPhone.
# Creates a set of universal libraries that can be used on an iPhone and in the
# iPhone simulator. Then creates a pseudo-framework to make using boost in Xcode
# less painful.
#
# To configure the script, define:
#    BOOST_LIBS:        Libraries to build. Each library name must be 
#                       separated by a single whitespace.
#                       Valid values: any library name OR an empty string
#                       (Empty string is similar to 'all' option). Do not use 'all' 
#                       in this variable, use empty string instead!
#
#                       Default value: empty string.
#
#    BOOST_NO_LIBS      which libraries to not build. Each library name must be 
#                       separated by a single whitespace. An empty string meanings
#                       no library to exclude
#
#                       Default value: graph_parallel mpi wave locale
#
#    BOOST_VERSION:     version number of the boost library (e.g. 1_41_0). 
#                       If the version tarball for the requested version does not 
#                       exist, then it will be downloaded.
#
#                       Default value: 1_44_0
#
#    IPHONE_SDKVERSION: iPhone SDK version (e.g. 4.3).
#
#                       Default value: 4.3
#
# Grab a cuppa and voila!
#
#===============================================================================

: ${BOOST_VERSION:=1_44_0}
: ${BOOST_LIBS:=""}

# Add extra libraries to compilation
[ -f "./boost_extra_libs.txt" ] && BOOST_EXTRA_LIBS=`cat ./boost_extra_libs.txt`
: ${BOOST_EXTRA_LIBS:=""}
BOOST_LIBS="${BOOST_LIBS} ${BOOST_EXTRA_LIBS}"
REGEX_ALL_WHITESPACES="^[ ]*$"
[[ $BOOST_LIBS =~ $REGEX_ALL_WHITESPACES ]] && BOOST_LIBS=""

# Remove some libraries from being compiled
: ${BOOST_NO_LIBS:="graph_parallel mpi wave locale"}

# Boost library with special names or producing multiple libraries for one name
BOOST_LIBS_SPECIAL_NAMES[0]="test"
BOOST_LIBS_SPECIAL_NAMES[1]="unit_test_framework"
BOOST_LIBS_SPECIAL_NAMES[2]="math"
BOOST_LIBS_SPECIAL_NAMES[3]="math_c99"
BOOST_LIBS_SPECIAL_NAMES[4]="math"
BOOST_LIBS_SPECIAL_NAMES[5]="math_c99f"
BOOST_LIBS_SPECIAL_NAMES[6]="math"
BOOST_LIBS_SPECIAL_NAMES[7]="math_tr1"
BOOST_LIBS_SPECIAL_NAMES[8]="math"
BOOST_LIBS_SPECIAL_NAMES[9]="math_tr1f"

: ${IPHONE_SDKVERSION:=4.3}
: ${EXTRA_CPPFLAGS:="-DBOOST_AC_USE_PTHREADS -DBOOST_SP_USE_PTHREADS"}
#: ${EXTRA_CPPFLAGS2:="pch=off"}

# The EXTRA_CPPFLAGS definition works around a thread race issue in
# shared_ptr. I encountered this historically and have not verified that
# the fix is no longer required. Without using the posix thread primitives
# an invalid compare-and-swap ARM instruction (non-thread-safe) was used for the
# shared_ptr use count causing nasty and subtle bugs.
#
# Should perhaps also consider/use instead: -BOOST_SP_USE_PTHREADS

: ${TARBALLDIR:=`pwd`}
: ${SRCDIR:=`pwd`/src}
: ${BUILDDIR:=`pwd`/build}
: ${PREFIXDIR:=`pwd`/prefix}
: ${FRAMEWORKDIR:=`pwd`/framework}

BOOST_TARBALL=$TARBALLDIR/boost_$BOOST_VERSION.tar.bz2
BOOST_SRC=$SRCDIR/boost_${BOOST_VERSION}

: ${BOOST_BJAM_MAX_PARALLEL_COMMANDS:=`sysctl hw.logicalcpu | awk '{print $2}'`}

#===============================================================================

: ${DEVELOPER_DIR_PATH:="`xcode-select -print-path`"}

ARM_DEV_DIR=${DEVELOPER_DIR_PATH}/Platforms/iPhoneOS.platform/Developer/usr/bin
SIM_DEV_DIR=${DEVELOPER_DIR_PATH}/Platforms/iPhoneSimulator.platform/Developer/usr/bin

: ${COMPILER_ARM_PATH:="${ARM_DEV_DIR}/gcc-4.2"}
: ${COMPILER_SIM_PATH:="${SIM_DEV_DIR}/gcc-4.2"}

compilerFileName=`basename "$COMPILER_ARM_PATH"`
if [[ $compilerFileName =~ ^gcc ]]
then
: ${COMPILER_ARM_VERSION:=`$COMPILER_ARM_PATH -v 2>&1 | tail -1 | awk '{print $3}'`}
elif [[ $compilerFileName =~ ^clang ]]
then
: ${COMPILER_ARM_VERSION:=`$COMPILER_ARM_PATH -v 2>&1 | head -n 1 | awk '{print $4}'`}
fi

compilerFileName=`basename "$COMPILER_SIM_PATH"`
if [[ $compilerFileName =~ ^gcc ]]
then
: ${COMPILER_SIM_VERSION:=`$COMPILER_SIM_PATH -v 2>&1 | tail -1 | awk '{print $3}'`}
elif [[ $compilerFileName =~ ^clang ]]
then
: ${COMPILER_SIM_VERSION:=`$COMPILER_SIM_PATH -v 2>&1 | head -n 1 | awk '{print $4}'`}
fi

ARM_COMBINED_LIB=$BUILDDIR/lib_boost_arm.a
SIM_COMBINED_LIB=$BUILDDIR/lib_boost_x86.a

#===============================================================================

echo "BOOST_VERSION:     $BOOST_VERSION"
echo "BOOST_LIBS:        $BOOST_LIBS"
echo "BOOST_NO_LIBS:        $BOOST_NO_LIBS"
echo "BOOST_TARBALL:     $BOOST_TARBALL"
echo "BOOST_SRC:         $BOOST_SRC"
echo "BUILDDIR:          $BUILDDIR"
echo "PREFIXDIR:         $PREFIXDIR"
echo "FRAMEWORKDIR:      $FRAMEWORKDIR"
echo "IPHONE_SDKVERSION: $IPHONE_SDKVERSION"
echo "COMPILER_SIM_PATH: $COMPILER_SIM_PATH"
echo "COMPILER_ARM_PATH: $COMPILER_ARM_PATH"
echo "COMPILER_ARM_VERSION: $COMPILER_ARM_VERSION"
echo "COMPILER_SIM_VERSION: $COMPILER_SIM_VERSION"
echo

#===============================================================================

ARCH_X86="x86"
ARCH_ARM="arm"

#===============================================================================
# Functions
#===============================================================================

abort()
{
    echo
    echo "Aborted: $@"
    exit 1
}

doneSection()
{
    echo
    echo "    ================================================================="
    echo "    Done"
    echo
}

#===============================================================================
addToBOOST_LIBS()
{
    local LIB_NAME=$1
    BOOST_LIBS="$BOOST_LIBS $LIB_NAME"
}

removeFromBOOST_LIBS()
{
    local LIB_NAME=$1
    BOOST_LIBS=`echo "$BOOST_LIBS" | sed "s/^$LIB_NAME //g" | sed "s/ $LIB_NAME$//g" | sed "s/ $LIB_NAME / /g"`
    BOOST_LIBS=`echo "$BOOST_LIBS" | sed 's/ \{2,\}/ /g'`
}

#===============================================================================
# Return 0 is library name has special name(s). 1 otherwise
isSpecialLibraryName()
{
    local libName="$1"
    local index=0
    local expectedLibName=""
    local count="${#BOOST_LIBS_SPECIAL_NAMES[@]}"
    local returnValue=1
    while [ $index -lt $count ]; do
        expectedLibName=${BOOST_LIBS_SPECIAL_NAMES[$index]}
        [ "$expectedLibName" == "$libName" ] && returnValue=0 && break
        let index++; let index++;
    done
    echo $returnValue;
}

#===============================================================================
getSpecialLibraryNames()
{
local libName="$1"
local libsNames=""
local expectedLibName=""
local currentLibName=""
local index=0
local count="${#BOOST_LIBS_SPECIAL_NAMES[@]}"
while [ $index -lt $count ]; do
    expectedLibName=${BOOST_LIBS_SPECIAL_NAMES[$index]}
    let index++
    currentLibName=${BOOST_LIBS_SPECIAL_NAMES[$index]}
    [ "$expectedLibName" == "$libName" ] && libsNames="$libsNames $currentLibName"
    let index++
done
echo "$libsNames"
}

#===============================================================================
getLibraryFilePath()
{
    local expectedLibName="$1"
    local currentLibName="$2"
    local arch="$3" # Supported values: x86,arm
    local compilerFlags="$4" #Supported values: pch=off,pch=on
    local compilerVersion="COMPILER_VERSION_UNDEFINED";
    local target="TARGET_UNDEFINED"
    # Retrieve compiler version
    if [ "$arch" == "$ARCH_ARM" ]
    then
        compilerVersion="$COMPILER_ARM_VERSION"
        target="iphone"
    elif [ "$arch" == "$ARCH_X86" ]
    then
        compilerVersion="$COMPILER_SIM_VERSION"
        target="iphonesim"
    fi
    
    # Retrieve path dependent on compiler option
    local compilerFlagsDependentPath=""
    for flag in $compilerFlags; do
        if [ "$flag" == "pch=off" ]
        then
            compilerFlagsDependentPath="pch-off/"
        elif [ "$flag" == "pch=on" ]
        then
            compilerFlagsDependentPath="pch-on/"
        fi
    done;

    local filePath="${BOOST_SRC}/bin.v2/libs/${expectedLibName}/build/darwin-${compilerVersion}~${target}/release/architecture-${arch}/link-static/macosx-version-${target}-$IPHONE_SDKVERSION/${compilerFlagsDependentPath}target-os-iphone/threading-multi/libboost_${currentLibName}.a"
    echo "$filePath"
}

#===============================================================================
patchBoost()
{
    case $BOOST_VERSION in
	1_48_0)
		echo Patching boost ...
		# Should include patches for libraries I do not use ?
		doneSection
	;;
    esac
}

#===============================================================================
cleanEverythingReadyToStart()
{
    echo Cleaning everything before we start to build...
    rm -rf $SRCDIR
    rm -rf $BOOST_SRC
    rm -rf $BUILDDIR
    rm -rf $PREFIXDIR
    rm -rf $FRAMEWORKDIR
    doneSection
}

#===============================================================================
downloadBoost()
{
    if [ ! -f "$BOOST_TARBALL" ]
    then
        echo "Downloading Boost $BOOST_VERSION ..."
        version=${BOOST_VERSION//_/.}
        curl --progress-bar -L -o boost_$BOOST_VERSION.tar.bz2 http://sourceforge.net/projects/boost/files/boost/$version/boost_$BOOST_VERSION.tar.bz2/download
        doneSection
    else
        echo "Boost $BOOST_VERSION already donwloaded."
        echo ""
    fi
}

#===============================================================================
unpackBoost()
{
    echo Unpacking boost into $SRCDIR...
    [ -d $SRCDIR ]    || mkdir -p $SRCDIR
    [ -d $BOOST_SRC ] || ( cd $SRCDIR; tar xfj $BOOST_TARBALL )
    [ -d $BOOST_SRC ] && echo "    ...unpacked as $BOOST_SRC"
    doneSection
}

#===============================================================================

writeBjamUserConfig()
{
    # You need to do this to point bjam at the right compiler
    # ONLY SEEMS TO WORK IN HOME DIR GRR
    echo Writing usr-config
    #mkdir -p $BUILDDIR
    #cat > ~/user-config.jam <<EOF
    cat >> $BOOST_SRC/tools/build/v2/user-config.jam <<EOF
using darwin : $COMPILER_ARM_VERSION~iphone
   : $COMPILER_ARM_PATH -arch armv7 -mthumb -fvisibility=hidden -fvisibility-inlines-hidden $EXTRA_CPPFLAGS
   : <striper>
   : <architecture>arm <target-os>iphone
   ;
using darwin : $COMPILER_SIM_VERSION~iphonesim
   : $COMPILER_SIM_PATH -arch i386 -fvisibility=hidden -fvisibility-inlines-hidden $EXTRA_CPPFLAGS
   : <striper>
   : <architecture>x86 <target-os>iphone
   ;
EOF
    doneSection
}

#===============================================================================

inventMissingHeaders()
{
    # These files are missing in the ARM iPhoneOS SDK, but they are in the simulator.
    # They are supported on the device, so we copy them from x86 SDK to a staging area
    # to use them on ARM, too.
    echo Invent missing headers
    cp /Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator${IPHONE_SDKVERSION}.sdk/usr/include/{crt_externs,bzlib}.h $BOOST_SRC
}

#===============================================================================

retrieveAllBoostLibrariesRequiringSeparateBuild()
{
    case $BOOST_VERSION in
    1_44_0)
    retrieveAllBoostLibrariesRequiringSeparateBuild_1_44_0
    ;;
    1_48_0)
    retrieveAllBoostLibrariesRequiringSeparateBuild_1_48_0
    ;;
    default )
    abort "This version ($BOOST_VERSION) is not supported"
    ;;
    esac
}

retrieveAllBoostLibrariesRequiringSeparateBuild_1_48_0()
{
    if [[ -z "$BOOST_LIBS" || "$BOOST_LIBS" == "" || "$BOOST_LIBS" == "all" ]]
    then
        echo "Looking for Boost Libraries names requiring separate building..."
        tmp_out=`cd $BOOST_SRC && ./bootstrap.sh --show-libraries`
        tmp_outfile="./outfile"
        echo "$tmp_out" >> "$tmp_outfile"
        regex0="^- (.*)$"
        librariesNames=""
        while read line ; do
        if [[ $line =~ $regex0 ]]
        then
            librariesNames="$librariesNames ${BASH_REMATCH[1]}"
        fi
        done < "$tmp_outfile"
        librariesNames=`echo "$librariesNames" | sed 's/ *$//g'`; #Remove trailing whitespaces
        librariesNames=`echo "$librariesNames" | sed 's/^ *//g'`; #Remove leading whitespaces
        BOOST_LIBS="$librariesNames"
        rm -f "$tmp_outfile"
    fi
    doneSection
}

retrieveAllBoostLibrariesRequiringSeparateBuild_1_44_0()
{
    if [[ -z "$BOOST_LIBS" || "$BOOST_LIBS" == "" || "$BOOST_LIBS" == "all" ]]
    then
        echo "Looking for Boost Libraries names requiring separate building..."
        tmp_out=`cd $BOOST_SRC && ./bootstrap.sh --show-libraries`
        tmp_outfile="./outfile"
        echo "$tmp_out" >> "$tmp_outfile"
        isNextLineLibName=1
        regex0="^-$"
        regex1="^(.*)"
        librariesNames=""
        while read line ; do
        if [[ $line =~ $regex0 ]]
        then
            isNextLineLibName=0
        elif [[ "$isNextLineLibName" -eq 0 ]]
        then
            [[ $line =~ $regex1 ]]
            librariesNames="$librariesNames ${BASH_REMATCH[1]}"
            isNextLineLibName=1
        fi
        done < "$tmp_outfile"
        librariesNames=`echo "$librariesNames" | sed 's/ *$//g'`; #Remove trailing whitespaces
        librariesNames=`echo "$librariesNames" | sed 's/^ *//g'`; #Remove leading whitespaces
        BOOST_LIBS="$librariesNames"
        rm -f "$tmp_outfile"
    fi
    doneSection
}

#===============================================================================

computeBoostLibrariesToCompile()
{
    for NAME in $BOOST_NO_LIBS; do
        removeFromBOOST_LIBS "$NAME"
#        BOOST_LIBS=`echo "$BOOST_LIBS" | sed "s/^$NAME //g" | sed "s/ $NAME$//g" | sed "s/ $NAME / /g"`
#        BOOST_LIBS=`echo "$BOOST_LIBS" | sed 's/ \{2,\}/ /g'`
    done
}

#===============================================================================

bootstrapBoost()
{
    cd $BOOST_SRC
    BOOST_LIBS_COMMA=$(echo $BOOST_LIBS | sed -e "s/ /,/g")
    echo "Bootstrapping (with libs $BOOST_LIBS_COMMA)"
    ./bootstrap.sh --with-libraries=$BOOST_LIBS_COMMA
    doneSection
}

#===============================================================================

buildBoostForiPhoneOS()
{
    # Flags purpose:
    # pch=off required to build Boost Math Library properly (see: http://continuous.wordpress.com/2010/04/11/building-boost-graph-library-with-python/)
    EXTRA_ARM_COMPILE_FLAGS=""
    EXTRA_SIM_COMPILE_FLAGS=""
    case $BOOST_VERSION in
        1_44_0)
            EXTRA_ARM_COMPILE_FLAGS="pch=off"
            EXTRA_SIM_COMPILE_FLAGS=""
        ;;
        1_48_0)
            EXTRA_ARM_COMPILE_FLAGS="pch=off"
            EXTRA_SIM_COMPILE_FLAGS=""
        ;;
    esac


    cd $BOOST_SRC
    
    ./bjam -j ${BOOST_BJAM_MAX_PARALLEL_COMMANDS} --prefix="$PREFIXDIR" toolset=darwin architecture=arm target-os=iphone macosx-version=iphone-${IPHONE_SDKVERSION} define=_LITTLE_ENDIAN link=static install $EXTRA_ARM_COMPILE_FLAGS
    doneSection

    ./bjam -j ${BOOST_BJAM_MAX_PARALLEL_COMMANDS} toolset=darwin architecture=x86 target-os=iphone macosx-version=iphonesim-${IPHONE_SDKVERSION} link=static stage $EXTRA_SIM_COMPILE_FLAGS
    doneSection
}

#===============================================================================

# $1: Name of a boost library to lipoficate (technical term)
lipoficate()
{
    : ${1:?}
    NAME=$1
    echo liboficate: $1

    local expectedLibName=""
    local libsNames="$NAME"
    if [ `isSpecialLibraryName $NAME` -eq 0 ]
    then
	expectedLibName=$NAME
        libsNames=`getSpecialLibraryNames "$NAME"`
    fi

    for currentLibName in $libsNames; do
        ARMV6=`getLibraryFilePath "$NAME" "$currentLibName" "$ARCH_ARM" "$EXTRA_ARM_COMPILE_FLAGS"`
#    ARMV6=$BOOST_SRC/bin.v2/libs/$NAME/build/darwin-${COMPILER_ARM_VERSION}~iphone/release/architecture-arm/link-static/macosx-version-iphone-$IPHONE_SDKVERSION/pch-off/target-os-iphone/threading-multi/libboost_$NAME.a
        I386=`getLibraryFilePath "$NAME" "$currentLibName" "$ARCH_X86" "$EXTRA_SIM_COMPILE_FLAGS"`
#    I386=$BOOST_SRC/bin.v2/libs/$NAME/build/darwin-${COMPILER_SIM_VERSION}~iphonesim/release/architecture-x86/link-static/macosx-version-iphonesim-$IPHONE_SDKVERSION/target-os-iphone/threading-multi/libboost_$NAME.a

        mkdir -p $PREFIXDIR/lib
        lipo \
            -create \
            "$ARMV6" \
            "$I386" \
            -o          "$PREFIXDIR/lib/libboost_$currentLibName.a" \
        || abort "Lipo $1 failed"

    done
}

# This creates universal versions of each individual boost library
lipoAllBoostLibraries()
{
    for i in $BOOST_LIBS; do lipoficate $i; done;

    doneSection
}

scrunchAllLibsTogetherInOneLibPerPlatform()
{
    # Handle general case where a expected Boost library name is different 
    # from actual Boost lib name for that library
    # Array specification:
    # n   : Expected Boost Library Nane
    # n+1 : Current Boost Library Name
    libsToRename[0]="test"
    libsToRename[1]="unit_test_framework"
    index=0
    for NAME in ${libsToRename[*]};
    do
        let "index++"
        BOOST_CURRENT_LIB_NAME=${libsToRename[$index]}
#        currentLibArchARMFilePath="$BOOST_SRC/bin.v2/libs/$NAME/build/darwin-${COMPILER_ARM_VERSION}~iphone/release/architecture-arm/link-static/macosx-version-iphone-$IPHONE_SDKVERSION/pch-off/target-os-iphone/threading-multi/libboost_$BOOST_CURRENT_LIB_NAME.a"

 ##       currentLibArchARMFilePath=`getLibraryFilePath "$NAME" "$BOOST_CURRENT_LIB_NAME" "$ARCH_ARM" "$EXTRA_ARM_COMPILE_FLAGS"`


#        expectedLibArchARMFilePath="$BOOST_SRC/bin.v2/libs/$NAME/build/darwin-${COMPILER_ARM_VERSION}~iphone/release/architecture-arm/link-static/macosx-version-iphone-$IPHONE_SDKVERSION/pch-off/target-os-iphone/threading-multi/libboost_$NAME.a"

##        expectedLibArchARMFilePath=`getLibraryFilePath "$NAME" "$NAME" "$ARCH_ARM" "$EXTRA_ARM_COMPILE_FLAGS"`

#        currentLibArchX86FilePath="$BOOST_SRC/bin.v2/libs/$NAME/build/darwin-${COMPILER_SIM_VERSION}~iphonesim/release/architecture-x86/link-static/macosx-version-iphonesim-$IPHONE_SDKVERSION/target-os-iphone/threading-multi/libboost_$BOOST_CURRENT_LIB_NAME.a"

##        currentLibArchX86FilePath=`getLibraryFilePath "$NAME" "$BOOST_CURRENT_LIB_NAME" "$ARCH_X86" "$EXTRA_SIM_COMPILE_FLAGS"`

#        expectedLibArchX86FilePath="$BOOST_SRC/bin.v2/libs/$NAME/build/darwin-${COMPILER_SIM_VERSION}~iphonesim/release/architecture-x86/link-static/macosx-version-iphonesim-$IPHONE_SDKVERSION/target-os-iphone/threading-multi/libboost_$NAME.a"

##	expectedLibArchX86FilePath=`getLibraryFilePath "$NAME" "$NAME" "$ARCH_X86" "$EXTRA_SIM_COMPILE_FLAGS"`

#        [ -e "$currentLibArchARMFilePath" ] && mv -v "$currentLibArchARMFilePath" "$expectedLibArchARMFilePath"
#        [ -e "$currentLibArchX86FilePath" ] && mv -v "$currentLibArchX86FilePath" "$expectedLibArchX86FilePath"
    done;

    # Handle Boost Math case.

#    ALL_LIBS_ARM=""
#    ALL_LIBS_SIM=""
#    for NAME in $BOOST_LIBS; do
#        ALL_LIBS_ARM="$ALL_LIBS_ARM $BOOST_SRC/bin.v2/libs/$NAME/build/darwin-$COMPILER_ARM_VERSION~iphone/release/architecture-arm/link-static/macosx-version-iphone-$IPHONE_SDKVERSION/pch-off/target-os-iphone/threading-multi/libboost_$NAME.a";
#        ALL_LIBS_SIM="$ALL_LIBS_SIM $BOOST_SRC/bin.v2/libs/$NAME/build/darwin-$COMPILER_SIM_VERSION~iphonesim/release/architecture-x86/link-static/macosx-version-iphonesim-$IPHONE_SDKVERSION/target-os-iphone/threading-multi/libboost_$NAME.a";
#    done;

    mkdir -p $BUILDDIR/armv6/obj
    mkdir -p $BUILDDIR/armv7/obj
    mkdir -p $BUILDDIR/i386/obj

    ALL_LIBS=""

    echo Splitting all existing fat binaries...
    for NAME in $BOOST_LIBS; do

        local expectedLibName="$NAME"
        local libsNames="$NAME"
        if [ `isSpecialLibraryName $NAME` -eq 0 ]
        then
            libsNames=`getSpecialLibraryNames "$NAME"`
        fi

        for currentLibName in $libsNames; do
    #        ALL_LIBS="$ALL_LIBS libboost_$NAME.a"
            ALL_LIBS="$ALL_LIBS libboost_${currentLibName}.a"

    #        lipo "$BOOST_SRC/bin.v2/libs/$NAME/build/darwin-${COMPILER_ARM_VERSION}~iphone/release/architecture-arm/link-static/macosx-version-iphone-$IPHONE_SDKVERSION/pch-off/target-os-iphone/threading-multi/libboost_$NAME.a" -thin armv6 -o $BUILDDIR/armv6/libboost_$NAME.a

            lipo `getLibraryFilePath "${expectedLibName}" "${currentLibName}" "$ARCH_ARM" "$EXTRA_ARM_COMPILE_FLAGS"` -thin armv6 -o $BUILDDIR/armv6/libboost_${currentLibName}.a

    #        lipo "$BOOST_SRC/bin.v2/libs/$NAME/build/darwin-${COMPILER_ARM_VERSION}~iphone/release/architecture-arm/link-static/macosx-version-iphone-$IPHONE_SDKVERSION/pch-off/target-os-iphone/threading-multi/libboost_$NAME.a" -thin armv7 -o $BUILDDIR/armv7/libboost_$NAME.a

            lipo `getLibraryFilePath "${expectedLibName}" "${currentLibName}" "$ARCH_ARM" "$EXTRA_ARM_COMPILE_FLAGS"` -thin armv7 -o $BUILDDIR/armv7/libboost_${currentLibName}.a

    #        cp "$BOOST_SRC/bin.v2/libs/$NAME/build/darwin-${COMPILER_SIM_VERSION}~iphonesim/release/architecture-x86/link-static/macosx-version-iphonesim-$IPHONE_SDKVERSION/target-os-iphone/threading-multi/libboost_$NAME.a" $BUILDDIR/i386/

            cp `getLibraryFilePath "${expectedLibName}" "${currentLibName}" "$ARCH_X86" "$EXTRA_SIM_COMPILE_FLAGS"` $BUILDDIR/i386/
        done
    done

    echo "Decomposing each architecture's .a files"
    for NAME in $ALL_LIBS; do
        echo Decomposing $NAME...
        (cd $BUILDDIR/armv6/obj; ar -x ../$NAME );
        (cd $BUILDDIR/armv7/obj; ar -x ../$NAME );
        (cd $BUILDDIR/i386/obj; ar -x ../$NAME );
    done

    echo "Linking each architecture into an uberlib ($ALL_LIBS => libboost.a )"
    rm $BUILDDIR/*/libboost.a
    echo ...armv6
    (cd $BUILDDIR/armv6; $ARM_DEV_DIR/ar crus libboost.a obj/*.o; )
    echo ...armv7
    (cd $BUILDDIR/armv7; $ARM_DEV_DIR/ar crus libboost.a obj/*.o; )
    echo ...i386
    (cd $BUILDDIR/i386;  $SIM_DEV_DIR/ar crus libboost.a obj/*.o; )
}

#===============================================================================

                    VERSION_TYPE=Alpha
                  FRAMEWORK_NAME=boost
               FRAMEWORK_VERSION=A

       FRAMEWORK_CURRENT_VERSION=$BOOST_VERSION
 FRAMEWORK_COMPATIBILITY_VERSION=$BOOST_VERSION

buildFramework()
{
    FRAMEWORK_BUNDLE=$FRAMEWORKDIR/$FRAMEWORK_NAME.framework

    rm -rf $FRAMEWORK_BUNDLE

    echo "Framework: Setting up directories..."
    mkdir -p $FRAMEWORK_BUNDLE
    mkdir -p $FRAMEWORK_BUNDLE/Versions
    mkdir -p $FRAMEWORK_BUNDLE/Versions/$FRAMEWORK_VERSION
    mkdir -p $FRAMEWORK_BUNDLE/Versions/$FRAMEWORK_VERSION/Resources
    mkdir -p $FRAMEWORK_BUNDLE/Versions/$FRAMEWORK_VERSION/Headers
    mkdir -p $FRAMEWORK_BUNDLE/Versions/$FRAMEWORK_VERSION/Documentation

    echo "Framework: Creating symlinks..."
    ln -s $FRAMEWORK_VERSION               $FRAMEWORK_BUNDLE/Versions/Current
    ln -s Versions/Current/Headers         $FRAMEWORK_BUNDLE/Headers
    ln -s Versions/Current/Resources       $FRAMEWORK_BUNDLE/Resources
    ln -s Versions/Current/Documentation   $FRAMEWORK_BUNDLE/Documentation
    ln -s Versions/Current/$FRAMEWORK_NAME $FRAMEWORK_BUNDLE/$FRAMEWORK_NAME

    FRAMEWORK_INSTALL_NAME=$FRAMEWORK_BUNDLE/Versions/$FRAMEWORK_VERSION/$FRAMEWORK_NAME

    echo "Lipoing library into $FRAMEWORK_INSTALL_NAME..."
    lipo \
        -create \
        -arch armv6 "$BUILDDIR/armv6/libboost.a" \
        -arch armv7 "$BUILDDIR/armv7/libboost.a" \
        -arch i386  "$BUILDDIR/i386/libboost.a" \
        -o          "$FRAMEWORK_INSTALL_NAME" \
    || abort "Lipo $1 failed"

    echo "Framework: Copying includes..."
    cp -r $PREFIXDIR/include/boost/*  $FRAMEWORK_BUNDLE/Headers/

    echo "Framework: Creating plist..."
    cat > $FRAMEWORK_BUNDLE/Resources/Info.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>English</string>
	<key>CFBundleExecutable</key>
	<string>${FRAMEWORK_NAME}</string>
	<key>CFBundleIdentifier</key>
	<string>org.boost</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundlePackageType</key>
	<string>FMWK</string>
	<key>CFBundleSignature</key>
	<string>????</string>
	<key>CFBundleVersion</key>
	<string>${FRAMEWORK_CURRENT_VERSION}</string>
</dict>
</plist>
EOF
    doneSection
}

#===============================================================================
# Execution starts here
#===============================================================================

downloadBoost

[ -f "$BOOST_TARBALL" ] || abort "Source tarball missing."
mkdir -p $BUILDDIR

cleanEverythingReadyToStart;
unpackBoost
patchBoost
retrieveAllBoostLibrariesRequiringSeparateBuild
computeBoostLibrariesToCompile
inventMissingHeaders
writeBjamUserConfig
bootstrapBoost

case $BOOST_VERSION in
    1_4[48]_0)
        buildBoostForiPhoneOS
        ;;
    default )
        abort "This version ($BOOST_VERSION) is not supported"
        ;;
esac

scrunchAllLibsTogetherInOneLibPerPlatform
lipoAllBoostLibraries
buildFramework

echo "Completed successfully"

#===============================================================================

