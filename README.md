# This is a repo for ARM Ne10 Library for ZCU106 board

## Build instruction
    1 cd $NE10_PATH                                                # Change directory to the location of the Ne10 source
    2 mkdir build && cd build                                     # Create the `build` directory and navigate into it
    3 export NE10_LINUX_TARGET_ARCH=armv8                         # Set the target architecture (can also be "armv7")
    4 cmake -DNE10_BUILD_SHARED=ON -DGNULINUX_PLATFORM=ON ..      # Run CMake to generate the build files
    5 make                                                        # Build the project

## Usage
