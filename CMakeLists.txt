# IA Client UI Module CMakeLists.txt

cmake_minimum_required(VERSION 3.14)
project(IaClientUiPlugin LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

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
        src/ia_client_backend.h
        src/ia_client_backend.cpp
)

# Add logos-ia include dir for IaBackendReplica header
if(DEFINED ENV{LOGOS_IA_INCLUDE_DIR})
    target_include_directories(ia_client_ui_module_plugin PRIVATE $ENV{LOGOS_IA_INCLUDE_DIR})
endif()
