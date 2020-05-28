## Dear ImGui bindings

D language bindings to C++ [Dear ImGui](https://github.com/ocornut/imgui) library.

Contains types & functions, with minimal amount of helper functions, one example is work around for inability to provide default values for **ref** parameters.

## Build and Usage

> **NOTE: imgui_base.d is no longer maintained as it can be generated using gentool**

This is simply a bindings, it has no external dependencies. However to use in your code compiled imgui library is needed. There is simple CMake config included that simpifies the process.

Inside your project's dub.json just add this to dependencies section *(assuming imgui-d is added as a submodule)*, and import/static library as well.
```json
"dependencies": {
    "imgui-d": {"path": "path/to/bindings"}

    ...
},
"libs": ["imgui"]
```

#### Building the imgui:

  
1. Clone imgui repository
    ```
    cd folder/where/to/put/imgui
    git clone https://github.com/ocornut/imgui.git
    ```
1.  Copy provided CMakeLists.txt to that folder
1.  Generate the build files, for example for VS 2017 x64 DLL target
    ```
    cd imgui
    mkdir build_x64
    cd build_x64
    
    cmake -G"Visual Studio 15 2017 Win64" ../ -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=TRUE -DBUILD_SHARED_LIBS=TRUE 
    ```
1.  Build it!
    ```
    cmake --build ./ --config RelWithDebInfo
    ```
1. Finally copy the resulting binaries to your application's binaries folder

*It is also possible to build and use as static library.

*Consult the CMake documentation for more information.*

---

## What it is?

Simply a bindings to imgui library. "Dear ImGui" is immediate-mode graphics API agnostic GUI library, it works by emitting geometry data to be rendered by your code.

## Why yet another bindings?

*Made it for my own needs, feel free to use if you like...*

## How it is done?

Originally it was semi-auto regex replace, but now it can be generated using my ```gentool``` binding generator.

Other than that it might be necessary to extract correct mangling for types that cannot be expressed in D *(such as head const types - i.e. ```float* const```, which is const pointer to mutable data and this doesn't makes sense in D)*, most of this is specific to Visual Studio C++ compiler.
