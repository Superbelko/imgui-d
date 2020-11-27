$curdir = Get-Location
$root = Join-Path $curdir "../../../" -Resolve

# Create project dependencies folder
mkdir ../deps -Force

# Download and unzip 'gentool'
if (-Not (Test-Path("../deps/gentool.zip")))
{
    Invoke-WebRequest https://github.com/Superbelko/ohmygentool/releases/download/v0.2.0/gentool-v0.2.0-win64.zip -OutFile ../deps/gentool.zip
}
Expand-Archive ../deps/gentool-v0.2.0-win64.zip ../deps -force

# Grab imgui sources
if (-Not (Test-Path("../deps/imgui.zip")))
{
    Invoke-WebRequest https://github.com/ocornut/imgui/archive/v1.79.zip -OutFile ../deps/imgui.zip
}
Expand-Archive ../deps/imgui.zip ../deps -force

# Prepare build
if (-Not (Test-Path("../deps/imgui-1.79/build/RelWithDebInfo/imgui.lib")))
{
    # Copy cmake config
    Copy-Item $root/cmake/CMakeLists.txt "../deps/imgui-1.79" -force
    mkdir "../deps/imgui-1.79/build" -force
    cd "../deps/imgui-1.79/build"
    # Generate build files and build
    cmake ../ 
    cmake --build . --config RelWithDebInfo
    cd $curdir
    Copy-Item "../deps/imgui-1.79/build/RelWithDebInfo/imgui.lib" ../bin
}

# Generate bindings
if (-Not (Test-Path("$curdir/../deps/imgui-1.79/imgui_base.d")))
{
    Copy-Item $root/gentool/imgui.json $curdir/../deps/imgui-1.79 -force
    cd $curdir/../deps/imgui-1.79
    ../gentool.exe imgui.json
    Copy-Item imgui_base.d $root/source/imgui -Force
    cd $curdir
}
