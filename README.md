# This is a repository for ARM Ne10 Library for ZCU106 board

## Original repository location
https://github.com/projectNe10/Ne10

## Build instruction (v1.2.1 only)


### 1. Comment out the following context at the end of CMakeLists.txt:
    #if(GNULINUX_PLATFORM AND (NOT CMAKE_SYSTEM_PROCESSOR MATCHES "^arm"))
    #    message(FATAL_ERROR "You are trying to compile for non-ARM (CMAKE_SYSTEM_PROCESSOR='${CMAKE_SYSTEM_PROCESSOR}')! see doc/building.md for cross compilation instructions.")
    #endif()
### 2. Enter the Ne10 root directory
    > cd $NE10_PATH                                                # Change directory to the location of the Ne10 source
### 3. Create build folder
    > mkdir build && cd build                                     # Create the `build` directory and navigate into it
### 4. Define the build target architecture
    > export NE10_LINUX_TARGET_ARCH=aarch64                         # Set the target architecture (can also be "armv7")
### 5. Configure the cmake
    > cmake -DNE10_BUILD_SHARED=ON -DGNULINUX_PLATFORM=ON ..      # Run CMake to generate the build files
### 6. Build the library
    > make                                                        # Build the project

## Usage
