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

# Find repc tool for Qt Remote Objects code generation
find_program(REPC_TOOL NAMES repc PATHS /usr/libexec /nix/store/*/libexec NO_DEFAULT_PATH)
if(NOT REPC_TOOL)
    find_program(REPC_TOOL NAMES repc)
endif()

# Define the module with .rep in SOURCES — AUTOMOC will process it
logos_module(
    NAME ia_client_ui
    SOURCES 
        src/ia_client_backend.h
        src/ia_client_backend.cpp
)

if(REPC_TOOL AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/src/ia_client_backend.rep)
    message(STATUS "Found repc: ${REPC_TOOL}")
    
    set(REPC_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated_code")
    set(REPLICA_HEADER "${REPC_OUTPUT_DIR}/ia_client_backend_replica.h")
    
    add_custom_target(repc_ia_client ALL
        COMMAND ${CMAKE_COMMAND} -E make_directory ${REPC_OUTPUT_DIR}
        COMMAND ${REPC_TOOL} -o replica ${CMAKE_CURRENT_SOURCE_DIR}/src/ia_client_backend.rep ${REPLICA_HEADER}
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/src/ia_client_backend.rep
        COMMENT "Generating Qt Remote Objects replica for ia_client_backend.rep"
        VERBATIM
    )
    
    target_include_directories(ia_client_ui_module_plugin PRIVATE ${REPC_OUTPUT_DIR})
    add_dependencies(ia_client_ui_module_plugin repc_ia_client)
endif()
