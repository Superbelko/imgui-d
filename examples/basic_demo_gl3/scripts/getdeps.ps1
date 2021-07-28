$curdir = Get-Location
$root = Join-Path $curdir "../../../" -Resolve

# Create project dependencies folder
mkdir ../deps -Force

# Download and unzip 'gentool'
if (-Not (Test-Path("../deps/gentool.zip")))
{
    Invoke-WebRequest "https://github.com/Superbelko/ohmygentool/releases/download/v0.4.0/gentool-v0.4.0-win64.zip" -OutFile ../deps/gentool.zip -UseBasicParsing
}
Expand-Archive ../deps/gentool.zip ../deps -force

# Grab imgui sources
if (-Not (Test-Path("../deps/imgui.zip")))
{
    Invoke-WebRequest "https://github.com/ocornut/imgui/archive/refs/tags/v1.83.zip" -OutFile ../deps/imgui.zip -UseBasicParsing
}
Expand-Archive ../deps/imgui.zip ../deps -force

# Prepare build
if (-Not (Test-Path("../deps/imgui-1.83/build/RelWithDebInfo/imgui.lib")))
{
    # Copy cmake config
    Copy-Item $root/cmake/CMakeLists.txt "../deps/imgui-1.83" -force
    mkdir "../deps/imgui-1.83/build" -force
    cd "../deps/imgui-1.83/build"
    # Generate build files and build
    cmake ../ 
    cmake --build . --config RelWithDebInfo
    cd $curdir
    Copy-Item "../deps/imgui-1.83/build/RelWithDebInfo/imgui.lib" ../bin
}

# Generate bindings
if (-Not (Test-Path("$curdir/../deps/imgui-1.83/imgui_base.d")))
{
    Copy-Item $root/gentool/imgui.json $curdir/../deps/imgui-1.83 -force
    cd $curdir/../deps/imgui-1.83
    ../gentool.exe imgui.json
    Copy-Item imgui_base.d $root/source/imgui -Force
    cd $curdir
}

# Grab glfw sources
if (-Not (Test-Path("../deps/glfw.zip")))
{
    Invoke-WebRequest "https://github.com/glfw/glfw/archive/refs/tags/3.3.4.zip" -OutFile ../deps/glfw.zip -UseBasicParsing
}
Expand-Archive ../deps/glfw.zip ../deps -force

# build glfw
if (-Not (Test-Path("../deps/glfw-3.3.4/build/RelWithDebInfo/glfw.lib")))
{
    mkdir "../deps/glfw-3.3.4/build" -force
    cd "../deps/glfw-3.3.4/build"
    $buildParentDir = (split-path -parent $pwd)
    # WARNING: powershell has some crazy behaviour with -B in -BUILD_SHARED_LIBS, now using -D prefix for it
    $arguments = "$buildParentDir", "-DGLFW_BUILD_EXAMPLES=OFF", "-DGLFW_BUILD_TESTS=OFF", "-DGLFW_BUILD_DOCS=OFF", "-DGLFW_INSTALL=OFF", '-DBUILD_SHARED_LIBS=ON'
    Start-Process cmake -ArgumentList ($arguments) -NoNewWindow -Wait
    cmake --build . --config RelWithDebInfo
    cd $curdir
    Copy-Item "../deps/glfw-3.3.4/build/src/RelWithDebInfo/glfw3.dll" ../bin
}
