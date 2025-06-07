cmake_minimum_required(VERSION 3.16)
project(ImguiApp VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
# Options
option(USE_SYSTEM_GLFW "Use system-installed GLFW instead of bundled" OFF)

# Cross-compilation detection
if(CMAKE_CROSSCOMPILING)
    message(STATUS "Cross-compiling for ${CMAKE_SYSTEM_NAME}")
    set(USE_SYSTEM_GLFW OFF CACHE BOOL "" FORCE)  # Force bundled GLFW for cross-compile
endif()

# Include ImGui source files
set(IMGUI_DIR ${CMAKE_CURRENT_SOURCE_DIR}/external/imgui)
set(IMGUI_SOURCES
    ${IMGUI_DIR}/imgui.cpp
    ${IMGUI_DIR}/imgui_draw.cpp
    ${IMGUI_DIR}/imgui_tables.cpp
    ${IMGUI_DIR}/imgui_widgets.cpp
)

set(IMGUI_BACKENDS
    ${IMGUI_DIR}/backends/imgui_impl_glfw.cpp
    ${IMGUI_DIR}/backends/imgui_impl_opengl3.cpp
)

# Create executable
add_executable(imgui_app
    src/main.cpp
    ${IMGUI_SOURCES}
    ${IMGUI_BACKENDS}
)

# Include directories
target_include_directories(imgui_app PRIVATE
    ${IMGUI_DIR}
    ${IMGUI_DIR}/backends
)

# Handle GLFW dependency
if(USE_SYSTEM_GLFW)
    # Use system GLFW
    find_package(glfw3 REQUIRED)
    target_link_libraries(imgui_app PRIVATE glfw)
else()
    # Use bundled GLFW
    if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/external/glfw/CMakeLists.txt")
        message(FATAL_ERROR "GLFW submodule not found. Please run: git submodule update --init --recursive")
    endif()
    
    # Configure GLFW build
    set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
    set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
    set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
    set(GLFW_INSTALL OFF CACHE BOOL "" FORCE)
    
    add_subdirectory(external/glfw)
    target_link_libraries(imgui_app PRIVATE glfw)
endif()

# Platform-specific linking
if(WIN32)
    message(STATUS "Configuring for Windows build")
    
    # Windows system libraries
    target_link_libraries(imgui_app PRIVATE
        opengl32
        gdi32
        user32
        shell32
    )
    
    # Static linking for MinGW
    if(MINGW)
        target_link_options(imgui_app PRIVATE 
            -static-libgcc 
            -static-libstdc++ 
            -static
        )
    endif()
    
    # Set Windows subsystem (optional - removes console window)
    # set_target_properties(imgui_app PROPERTIES WIN32_EXECUTABLE TRUE)
    
else()
    # Unix/Linux setup
    find_package(OpenGL REQUIRED)
    
    target_link_libraries(imgui_app PRIVATE
        ${OPENGL_LIBRARIES}
        dl
        pthread
    )
endif()
