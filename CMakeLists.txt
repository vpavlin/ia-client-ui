# IA Client UI Module CMakeLists.txt
cmake_minimum_required(VERSION 3.14)
project(IaClientUiPlugin LANGUAGES CXX)

if(DEFINED ENV{LOGOS_MODULE_BUILDER_ROOT})
    include($ENV{LOGOS_MODULE_BUILDER_ROOT}/cmake/LogosModule.cmake)
elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/cmake/LogosModule.cmake")
    include(cmake/LogosModule.cmake)
else()
    message(FATAL_ERROR "LogosModule.cmake not found")
endif()

logos_module(
    NAME ia_client_ui
    SOURCES 
        src/ia_client_backend.rep
        src/ia_client_backend.h
        src/ia_client_backend.cpp
)
