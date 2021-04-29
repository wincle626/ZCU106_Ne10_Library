# This is a repository for ARM Ne10 Library for ZCU106 board

## Original repository location
https://github.com/projectNe10/Ne10

## Build instruction (v1.2.1 only)

    Comment out the following contextin CMakeLists.txt:
    #if(GNULINUX_PLATFORM AND (NOT CMAKE_SYSTEM_PROCESSOR MATCHES "^arm"))
    #    message(FATAL_ERROR "You are trying to compile for non-ARM (CMAKE_SYSTEM_PROCESSOR='${CMAKE_SYSTEM_PROCESSOR}')! see doc/building.md for cross compilation instructions.")
    #endif()

    1 cd $NE10_PATH                                                # Change directory to the location of the Ne10 source
    2 mkdir build && cd build                                     # Create the `build` directory and navigate into it
    3 export NE10_LINUX_TARGET_ARCH=armv8                         # Set the target architecture (can also be "armv7")
    4 cmake -DNE10_BUILD_SHARED=ON -DGNULINUX_PLATFORM=ON ..      # Run CMake to generate the build files
    5 make                                                        # Build the project

## Usage
