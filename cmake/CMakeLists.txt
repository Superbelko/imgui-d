cmake_minimum_required(VERSION 3.0)

project(imgui)

set(STB_HEADERS stb_truetype.h stb_textedit.h stb_rect_pack.h)

set(SOURCE_FNTCOMPRESS misc/fonts/binary_to_compressed_c.cpp)

set(HEADER_FILES ${STB_HEADERS} imgui.h imgui_internal.h imconfig.h)
set(SOURCE_FILES imgui.cpp imgui_draw.cpp imgui_demo.cpp)

add_library(imgui ${HEADER_FILES} ${SOURCE_FILES})

# complicated...
# set_target_properties(imgui PROPERTIES POSITION_INDEPENDENT_CODE ON)