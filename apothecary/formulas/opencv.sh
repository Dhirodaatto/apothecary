#! /bin/bash
#
# OpenCV
# library of programming functions mainly aimed at real-time computer vision
# http://opencv.org
#
# uses a CMake build system
 
FORMULA_TYPES=( "osx" "ios" "tvos" "vs" "android" "emscripten" )
 
# define the version
VER=3.1.0
 
# tools for git use
GIT_URL=https://github.com/Itseez/opencv.git
GIT_TAG=$VER

# these paths don't really matter - they are set correctly further down
local LIB_FOLDER="$BUILD_ROOT_DIR/opencv"
local LIB_FOLDER32="$LIB_FOLDER-32"
local LIB_FOLDER64="$LIB_FOLDER-64"
local LIB_FOLDER_IOS="$LIB_FOLDER-IOS"
local LIB_FOLDER_IOS_SIM="$LIB_FOLDER-IOSIM"

 
# download the source code and unpack it into LIB_NAME
function download() {
    if [ "$TYPE" != "android" ]; then
        wget https://github.com/Itseez/opencv/archive/$VER.tar.gz -O opencv-$VER.tar.gz
        tar -xf opencv-$VER.tar.gz
        mv opencv-$VER $1
        rm opencv*.tar.gz
    else
        wget http://sourceforge.net/projects/opencvlibrary/files/opencv-android/3.1.0/OpenCV-3.1.0-android-sdk.zip/download -O OpenCV-3.1.0-android-sdk.zip
        unzip -qo OpenCV-3.1.0-android-sdk.zip
        mv OpenCV-android-sdk $1
    fi
}
 
# prepare the build environment, executed inside the lib src dir
function prepare() {
    : #noop
}

# executed inside the lib src dir
function build() {
  rm -f CMakeCache.txt
 
  LIB_FOLDER="$BUILD_DIR/opencv/build/$TYPE/"
  mkdir -p $LIB_FOLDER

  if [ "$TYPE" == "osx" ] ; then
    LOG="$LIB_FOLDER/opencv2-${VER}.log"
    echo "Logging to $LOG"
    cd build
    rm -f CMakeCache.txt
    echo "Log:" >> "${LOG}" 2>&1
    set +e
    cmake .. -DCMAKE_INSTALL_PREFIX=$LIB_FOLDER \
      -DCMAKE_OSX_DEPLOYMENT_TARGET=10.7 \
      -DENABLE_FAST_MATH=OFF \
      -DCMAKE_CXX_FLAGS="-fvisibility-inlines-hidden -stdlib=libc++ -O3 -fPIC -arch i386 -arch x86_64 -mmacosx-version-min=${OSX_MIN_SDK_VER}" \
      -DCMAKE_C_FLAGS="-fvisibility-inlines-hidden -stdlib=libc++ -O3 -fPIC -arch i386 -arch x86_64 -mmacosx-version-min=${OSX_MIN_SDK_VER}" \
      -DCMAKE_BUILD_TYPE="Release" \
      -DBUILD_SHARED_LIBS=OFF \
      -DBUILD_DOCS=OFF \
      -DBUILD_EXAMPLES=OFF \
      -DBUILD_FAT_JAVA_LIB=OFF \
      -DBUILD_JASPER=OFF \
      -DBUILD_PACKAGE=OFF \
      -DBUILD_opencv_java=OFF \
      -DBUILD_opencv_python=OFF \
      -DBUILD_opencv_apps=OFF \
      -DBUILD_JPEG=OFF \
      -DBUILD_PNG=OFF \
      -DWITH_1394=OFF \
      -DWITH_CARBON=OFF \
      -DWITH_JPEG=OFF \
      -DWITH_PNG=OFF \
      -DWITH_FFMPEG=OFF \
      -DWITH_OPENCL=OFF \
      -DWITH_OPENCLAMDBLAS=OFF \
      -DWITH_OPENCLAMDFFT=OFF \
      -DWITH_GIGEAPI=OFF \
      -DWITH_CUDA=OFF \
      -DWITH_CUFFT=OFF \
      -DWITH_JASPER=OFF \
      -DWITH_LIBV4L=OFF \
      -DWITH_IMAGEIO=OFF \
      -DWITH_IPP=OFF \
      -DWITH_OPENNI=OFF \
      -DWITH_QT=OFF \
      -DWITH_QUICKTIME=OFF \
      -DWITH_V4L=OFF \
      -DWITH_PVAPI=OFF \
      -DWITH_OPENEXR=OFF \
      -DWITH_EIGEN=OFF \
      -DBUILD_TESTS=OFF \
      -DBUILD_PERF_TESTS=OFF 2>&1 | tee -a ${LOG}
    echo "CMAKE Successful"
    echo "--------------------"
    echo "Running make clean"

    make clean 2>&1 | tee -a ${LOG}
    echo "Make Clean Successful"

    echo "--------------------"
    echo "Running make"
    make -j${PARALLEL_MAKE} 2>&1 | tee -a ${LOG}
    echo "Make  Successful"

    echo "--------------------"
    echo "Running make install"
    make install 2>&1 | tee -a ${LOG}
    echo "Make install Successful"

    echo "--------------------"
    echo "Joining all libs in one"
    outputlist="lib/lib*.a"
    libtool -static $outputlist -o "$LIB_FOLDER/lib/opencv.a" 2>&1 | tee -a ${LOG}
    echo "Joining all libs in one Successful"

  elif [ "$TYPE" == "vs" ] ; then
    unset TMP
    unset TEMP

    rm -f CMakeCache.txt
	#LIB_FOLDER="$BUILD_DIR/opencv/build/$TYPE"
	mkdir -p $LIB_FOLDER
    LOG="$LIB_FOLDER/opencv2-${VER}.log"
    echo "Logging to $LOG"
    echo "Log:" >> "${LOG}" 2>&1
    set +e
	if [ $ARCH == 32 ] ; then
		mkdir -p build_vs_32
		cd build_vs_32
		cmake .. -G "Visual Studio $VS_VER"\
		-DBUILD_PNG=OFF \
		-DWITH_OPENCLAMDBLAS=OFF \
		-DBUILD_TESTS=OFF \
		-DWITH_CUDA=OFF \
		-DWITH_FFMPEG=OFF \
		-DWITH_WIN32UI=OFF \
		-DBUILD_PACKAGE=OFF \
		-DWITH_JASPER=OFF \
		-DWITH_OPENEXR=OFF \
		-DWITH_GIGEAPI=OFF \
		-DWITH_JPEG=OFF \
		-DBUILD_WITH_DEBUG_INFO=OFF \
		-DWITH_CUFFT=OFF \
		-DBUILD_TIFF=OFF \
		-DBUILD_JPEG=OFF \
		-DWITH_OPENCLAMDFFT=OFF \
		-DBUILD_WITH_STATIC_CRT=OFF \
		-DBUILD_opencv_java=OFF \
		-DBUILD_opencv_python=OFF \
		-DBUILD_opencv_apps=OFF \
		-DBUILD_PERF_TESTS=OFF \
		-DBUILD_JASPER=OFF \
		-DBUILD_DOCS=OFF \
		-DWITH_TIFF=OFF \
		-DWITH_1394=OFF \
		-DWITH_EIGEN=OFF \
		-DBUILD_OPENEXR=OFF \
		-DWITH_DSHOW=OFF \
		-DWITH_VFW=OFF \
		-DBUILD_SHARED_LIBS=OFF \
		-DWITH_PNG=OFF \
		-DWITH_OPENCL=OFF \
		-DWITH_PVAPI=OFF  | tee ${LOG} 
		vs-build "OpenCV.sln"
		vs-build "OpenCV.sln" Build "Debug"
	elif [ $ARCH == 64 ] ; then
		mkdir -p build_vs_64
		cd build_vs_64
		cmake .. -G "Visual Studio $VS_VER Win64" \
		-DBUILD_PNG=OFF \
		-DWITH_OPENCLAMDBLAS=OFF \
		-DBUILD_TESTS=OFF \
		-DWITH_CUDA=OFF \
		-DWITH_FFMPEG=OFF \
		-DWITH_WIN32UI=OFF \
		-DBUILD_PACKAGE=OFF \
		-DWITH_JASPER=OFF \
		-DWITH_OPENEXR=OFF \
		-DWITH_GIGEAPI=OFF \
		-DWITH_JPEG=OFF \
		-DBUILD_WITH_DEBUG_INFO=OFF \
		-DWITH_CUFFT=OFF \
		-DBUILD_TIFF=OFF \
		-DBUILD_JPEG=OFF \
		-DWITH_OPENCLAMDFFT=OFF \
		-DBUILD_WITH_STATIC_CRT=OFF \
		-DBUILD_opencv_java=OFF \
		-DBUILD_opencv_python=OFF \
		-DBUILD_opencv_apps=OFF \
		-DBUILD_PERF_TESTS=OFF \
		-DBUILD_JASPER=OFF \
		-DBUILD_DOCS=OFF \
		-DWITH_TIFF=OFF \
		-DWITH_1394=OFF \
		-DWITH_EIGEN=OFF \
		-DBUILD_OPENEXR=OFF \
		-DWITH_DSHOW=OFF \
		-DWITH_VFW=OFF \
		-DBUILD_SHARED_LIBS=OFF \
		-DWITH_PNG=OFF \
		-DWITH_OPENCL=OFF \
		-DWITH_PVAPI=OFF  | tee ${LOG} 
		vs-build "OpenCV.sln" Build "Release|x64"
		vs-build "OpenCV.sln" Build "Debug|x64"
	fi
    
  elif [[ "$TYPE" == "ios" || "${TYPE}" == "tvos" ]] ; then
    local IOS_ARCHS
    if [[ "${TYPE}" == "tvos" ]]; then 
        IOS_ARCHS="x86_64 arm64"
    elif [[ "$TYPE" == "ios" ]]; then
        IOS_ARCHS="i386 x86_64 armv7 arm64" #armv7s
    fi
    CURRENTPATH=`pwd`
     
      # loop through architectures! yay for loops!
    for IOS_ARCH in ${IOS_ARCHS}
    do
      source ${APOTHECARY_DIR}/ios_configure.sh $TYPE $IOS_ARCH

      cmake . -DCMAKE_INSTALL_PREFIX="$CURRENTPATH/build/$TYPE/$IOS_ARCH" \
      -DIOS=1 \
      -DAPPLE=1 \
      -DUNIX=1 \
      -DCMAKE_CXX_COMPILER=$CXX \
      -DCMAKE_CC_COMPILER=$CC \
      -DIPHONESIMULATOR=$ISSIM \
      -DCMAKE_CXX_COMPILER_WORKS="TRUE" \
      -DCMAKE_C_COMPILER_WORKS="TRUE" \
      -DSDKVER="${SDKVERSION}" \
      -DCMAKE_IOS_DEVELOPER_ROOT="${CROSS_TOP}" \
      -DDEVROOT="${CROSS_TOP}" \
      -DSDKROOT="${CROSS_SDK}" \
      -DCMAKE_OSX_SYSROOT="${SYSROOT}" \
      -DCMAKE_OSX_ARCHITECTURES="${IOS_ARCH}" \
      -DCMAKE_XCODE_EFFECTIVE_PLATFORMS="-$PLATFORM" \
      -DGLFW_BUILD_UNIVERSAL=ON \
      -DENABLE_FAST_MATH=OFF \
      -DCMAKE_CXX_FLAGS="-stdlib=libc++ -fvisibility=hidden $BITCODE -fPIC -isysroot ${SYSROOT} -DNDEBUG -Os $MIN_TYPE$MIN_IOS_VERSION" \
      -DCMAKE_C_FLAGS="-stdlib=libc++ -fvisibility=hidden $BITCODE -fPIC -isysroot ${SYSROOT} -DNDEBUG -Os $MIN_TYPE$MIN_IOS_VERSION"  \
      -DCMAKE_BUILD_TYPE="Release" \
      -DBUILD_SHARED_LIBS=OFF \
      -DBUILD_DOCS=OFF \
      -DBUILD_EXAMPLES=OFF \
      -DBUILD_FAT_JAVA_LIB=OFF \
      -DBUILD_JASPER=OFF \
      -DBUILD_PACKAGE=OFF \
      -DBUILD_opencv_java=OFF \
      -DBUILD_opencv_python=OFF \
      -DBUILD_opencv_apps=OFF \
      -DBUILD_opencv_videoio=OFF \
      -DBUILD_JPEG=OFF \
      -DBUILD_PNG=OFF \
      -DWITH_1394=OFF \
      -DWITH_JPEG=OFF \
      -DWITH_PNG=OFF \
      -DWITH_CARBON=OFF \
      -DWITH_FFMPEG=OFF \
      -DWITH_OPENCL=OFF \
      -DWITH_OPENCLAMDBLAS=OFF \
      -DWITH_OPENCLAMDFFT=OFF \
      -DWITH_GIGEAPI=OFF \
      -DWITH_CUDA=OFF \
      -DWITH_CUFFT=OFF \
      -DWITH_JASPER=OFF \
      -DWITH_LIBV4L=OFF \
      -DWITH_IMAGEIO=OFF \
      -DWITH_IPP=OFF \
      -DWITH_OPENNI=OFF \
      -DWITH_QT=OFF \
      -DWITH_QUICKTIME=OFF \
      -DWITH_V4L=OFF \
      -DWITH_PVAPI=OFF \
      -DWITH_EIGEN=OFF \
      -DWITH_OPENEXR=OFF \
      -DBUILD_OPENEXR=OFF \
      -DBUILD_TESTS=OFF \
      -DBUILD_PERF_TESTS=OFF


        echo "--------------------"
        echo "Running make clean for ${IOS_ARCH}"
        make clean 

        echo "--------------------"
        echo "Running make for ${IOS_ARCH}"
        make -j${PARALLEL_MAKE} 

        echo "--------------------"
        echo "Running make install for ${IOS_ARCH}"
        make install

        rm -f CMakeCache.txt
    done

    mkdir -p lib/$TYPE
    echo "--------------------"
    echo "Creating Fat Libs"
    cd "build/$TYPE"
    # link into universal lib, strip "lib" from filename
    local lib
    rm -rf arm64/lib/pkgconfig

    for lib in $( ls -1 arm64/lib) ; do
      local renamedLib=$(echo $lib | sed 's|lib||')
      if [ ! -e $renamedLib ] ; then
        echo "renamed";
        if [[ "${TYPE}" == "tvos" ]] ; then 
          lipo -c arm64/lib/$lib x86_64/lib/$lib -o "$CURRENTPATH/lib/$TYPE/$renamedLib"
        elif [[ "$TYPE" == "ios" ]]; then
          lipo -c armv7/lib/$lib arm64/lib/$lib i386/lib/$lib x86_64/lib/$lib -o "$CURRENTPATH/lib/$TYPE/$renamedLib"
        fi  
      fi
    done

    cd ../../
    echo "--------------------"
    echo "Copying includes"
    cp -R "build/$TYPE/x86_64/include/" "lib/include/"

    echo "--------------------"
    echo "Stripping any lingering symbols"

    cd lib/$TYPE
    for TOBESTRIPPED in $( ls -1) ; do
      strip -x $TOBESTRIPPED
    done

    cd ../../

  # end if iOS    
  elif [ "$TYPE" == "emscripten" ]; then
    mkdir -p build_${TYPE}
    cd build_${TYPE}
    emcmake cmake .. -DCMAKE_INSTALL_PREFIX="${BUILD_DIR}/${1}/build_$TYPE/install" \
      -DCMAKE_BUILD_TYPE="Release" \
      -DCMAKE_C_FLAGS=-I${EMSCRIPTEN}/system/lib/libcxxabi/include/ \
      -DCMAKE_CXX_FLAGS=-I${EMSCRIPTEN}/system/lib/libcxxabi/include/ \
      -DBUILD_SHARED_LIBS=OFF \
      -DBUILD_DOCS=OFF \
      -DBUILD_EXAMPLES=OFF \
      -DBUILD_FAT_JAVA_LIB=OFF \
      -DBUILD_JASPER=OFF \
      -DBUILD_PACKAGE=OFF \
      -DBUILD_opencv_java=OFF \
      -DBUILD_opencv_python=OFF \
      -DBUILD_opencv_apps=OFF \
      -DBUILD_JPEG=OFF \
      -DBUILD_PNG=OFF \
      -DWITH_TIFF=OFF \
      -DWITH_OPENEXR=OFF \
      -DWITH_1394=OFF \
      -DWITH_JPEG=OFF \
      -DWITH_PNG=OFF \
      -DWITH_FFMPEG=OFF \
      -DWITH_OPENCL=OFF \
      -DWITH_GIGEAPI=OFF \
      -DWITH_CUDA=OFF \
      -DWITH_CUFFT=OFF \
      -DWITH_JASPER=OFF \
      -DWITH_IMAGEIO=OFF \
      -DWITH_IPP=OFF \
      -DWITH_OPENNI=OFF \
      -DWITH_QT=OFF \
      -DWITH_QUICKTIME=OFF \
      -DWITH_V4L=OFF \
      -DWITH_PVAPI=OFF \
      -DWITH_EIGEN=OFF \
      -DBUILD_TESTS=OFF \
      -DBUILD_PERF_TESTS=OFF
    make -j${PARALLEL_MAKE}
    make install
  fi 

}


# executed inside the lib src dir, first arg $1 is the dest libs dir root
function copy() {

  # prepare headers directory if needed
  mkdir -p $1/include

  # prepare libs directory if needed
  mkdir -p $1/lib/$TYPE

  if [ "$TYPE" == "osx" ] ; then
    # Standard *nix style copy.
    # copy headers

    LIB_FOLDER="$BUILD_DIR/opencv/build/$TYPE/"
    
    cp -R $LIB_FOLDER/include/ $1/include/
 
    # copy lib
    cp -R $LIB_FOLDER/lib/opencv.a $1/lib/$TYPE/
	
  elif [ "$TYPE" == "vs" ] ; then 
		if [ $ARCH == 32 ] ; then
      DEPLOY_PATH="$1/lib/$TYPE/Win32"
		elif [ $ARCH == 64 ] ; then
			DEPLOY_PATH="$1/lib/$TYPE/x64"
		fi
      mkdir -p "$DEPLOY_PATH/Release"
      mkdir -p "$DEPLOY_PATH/Debug"
      # now make sure the target directories are clean.
      rm -Rf "${DEPLOY_PATH}/Release/*"
      rm -Rf "${DEPLOY_PATH}/Debug/*"
      #copy the cv libs
      cp -v build_vs_${ARCH}/lib/Release/*.lib "${DEPLOY_PATH}/Release"
      cp -v build_vs_${ARCH}/lib/Debug/*.lib "${DEPLOY_PATH}/Debug"
      #copy the zlib 
      cp -v build_vs_${ARCH}/3rdparty/lib/Release/*.lib "${DEPLOY_PATH}/Release"
      cp -v build_vs_${ARCH}/3rdparty/lib/Debug/*.lib "${DEPLOY_PATH}/Debug"

      #copy the ippicv includes and lib
      IPPICV_SRC=3rdparty/ippicv/unpack/ippicv_win
      IPPICV_DST=$1/../ippicv
      if [ $ARCH == 32 ] ; then
        IPPICV_PLATFORM="ia32"
        IPPICV_DEPLOY="${IPPICV_DST}/lib/$TYPE/Win32"
      elif [ $ARCH == 64 ] ; then
        IPPICV_PLATFORM="intel64"
        IPPICV_DEPLOY="${IPPICV_DST}/lib/$TYPE/x64"
      fi
      mkdir -p ${IPPICV_DST}/include
      cp -R ${IPPICV_SRC}/include/ ${IPPICV_DST}/
      mkdir -p ${IPPICV_DEPLOY}
      cp -v ${IPPICV_SRC}/lib/${IPPICV_PLATFORM}/*.lib "${IPPICV_DEPLOY}"

  elif [[ "$TYPE" == "ios" || "$TYPE" == "tvos" ]] ; then
    # Standard *nix style copy.
    # copy headers

    LIB_FOLDER="$BUILD_ROOT_DIR/$TYPE/FAT/opencv"

    cp -Rv lib/include/ $1/include/
    mkdir -p $1/lib/$TYPE
    cp -v lib/$TYPE/*.a $1/lib/$TYPE
  elif [ "$TYPE" == "android" ]; then
    mkdir -p $1/lib/$TYPE
    cp -r sdk/native/jni/include/opencv $1/include/
    cp -r sdk/native/jni/include/opencv2 $1/include/
    
    if [ "$TYPE" == "android" ]; then
        if [ "$ARCH" == "armv7" ]; then
            cp sdk/native/libs/armeabi-v7a/*.a $1/lib/$TYPE
        else            
            cp sdk/native/libs/armeabi-v7a/*.a $1/lib/$TYPE
        fi
    fi
  elif [ "$TYPE" == "emscripten" ]; then
    cp -r build_emscripten/install/include/* $1/include/
    cp -r build_emscripten/install/lib/*.a $1/lib/$TYPE/
    cp -r build_emscripten/install/share/OpenCV/3rdparty/lib/ $1/lib/$TYPE/
  fi

  # copy license file
  rm -rf $1/license # remove any older files if exists
  mkdir -p $1/license
  cp -v LICENSE $1/license/

}
 
# executed inside the lib src dir
function clean() {
  if [ "$TYPE" == "osx" ] ; then
    make clean;
  elif [[ "$TYPE" == "ios" || "$TYPE" == "tvos" ]] ; then
    make clean;
  fi
}