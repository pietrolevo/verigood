#		VeriGood Testbench environment with Verilator and GTest
#		Copyright (C) 2026  Pietro Alberto Levo
#
#		This program is free software: you can redistribute it and/or modify
#		it under the terms of the GNU General Public License as published by
#		the Free Software Foundation, either version 3 of the License, or
#		(at your option) any later version.
#
#		This program is distributed in the hope that it will be useful,
#		but WITHOUT ANY WARRANTY; without even the implied warranty of
#		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#		GNU General Public License for more details.

#		You should have received a copy of the GNU General Public License
#		along with this program.  If not, see <https://www.gnu.org/licenses/>.

function(add_verilog_test MODULE_NAME SOURCE_PATH IS_TOP)
  # find C++ testbench file
  set(TEST_CPP "${CMAKE_CURRENT_SOURCE_DIR}/test_${MODULE_NAME}.cpp")
  
  if(EXISTS ${TEST_CPP})
    # define executable test for the module
    set(TEST_TARGET "test_${MODULE_NAME}")
    add_executable(${TEST_TARGET} ${TEST_CPP})

    # take all files .sv except current one
    file(GLOB ALL_RTL_FILES "${CMAKE_SOURCE_DIR}/rtl/top/*.sv" "${CMAKE_SOURCE_DIR}/rtl/mods/*.sv")
    set(RTL_MODS_EXCEPT_SELF "")
    foreach(MOD_FILE ${ALL_RTL_FILES})
      if(NOT MOD_FILE STREQUAL SOURCE_PATH)
        list(APPEND RTL_MODS_EXCEPT_SELF ${MOD_FILE})
      endif()
    endforeach()

      # translate the SystemVerilog file
      verilate(${TEST_TARGET}
        SOURCES ${SOURCE_PATH} ${RTL_MODS_EXCEPT_SELF}
        PREFIX V${MODULE_NAME}
        TOP_MODULE ${MODULE_NAME}
        TRACE
        COVERAGE
        OPTIONS -Wall -I${CMAKE_SOURCE_DIR}/rtl/top -I${CMAKE_SOURCE_DIR}/rtl/mods
      )

      # create log folder
      file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/logs")

      # include path
      target_include_directories(${TEST_TARGET}
        PRIVATE
          "${CMAKE_SOURCE_DIR}/include"
      )

      # link to google test
      target_link_libraries(${TEST_TARGET}
        PRIVATE
          GTest::gtest_main
      )

      # Register test to Ctest
      include(GoogleTest)
      add_test(NAME ${TEST_TARGET} COMMAND ${TEST_TARGET})

  else()
    message(STATUS "ERROR: C++ test file not found for ${MODULE_NAME} (${TEST_CPP})")
  endif()
endfunction()


# find top module
if(DEFINED TEST_MODULE AND NOT TEST_MODULE STREQUAL "")
  if(EXISTS "${CMAKE_SOURCE_DIR}/rtl/top/${TEST_MODULE}.sv")
    add_verilog_test("${TEST_MODULE}" "${CMAKE_SOURCE_DIR}/rtl/top/${TEST_MODULE}.sv" TRUE)
  elseif(EXISTS "${CMAKE_SOURCE_DIR}/rtl/mods/${TEST_MODULE}.sv")
    add_verilog_test("${TEST_MODULE}" "${CMAKE_SOURCE_DIR}/rtl/mods/${TEST_MODULE}.sv" FALSE)
  else()
    message(FATAL_ERROR "Module '${TEST_MODULE}' not found in rtl/top/ and rtl/mods/")
  endif()
else()

  # default: compile what is inside rtl/top/
  file(GLOB ALL_FILES "${CMAKE_SOURCE_DIR}/rtl/top/*.sv" "${CMAKE_SOURCE_DIR}/rtl/mods/*.sv")
  foreach(FILE_PATH ${ALL_FILES})
    get_filename_component(MOD_NAME ${FILE_PATH} NAME_WE)
    add_verilog_test(${MOD_NAME} ${FILE_PATH} FALSE)
  endforeach()
endif()


add_custom_target(coverage
  COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/tb/logs
  COMMAND verilator_coverage --annotate ${CMAKE_BINARY_DIR}/tb/logs/annotate 
                            --annotate-all 
                            --annotate-min 1 
                            --write-info ${CMAKE_BINARY_DIR}/tb/logs/merged.info 
                            ${CMAKE_CURRENT_BINARY_DIR}/logs/coverage_*.dat
  COMMENT "Generating coverage report..."
)

add_custom_target(genhtml
  COMMAND genhtml ${CMAKE_BINARY_DIR}/tb/logs/merged.info --output-directory ${CMAKE_BINARY_DIR}/tb/logs/html
  DEPENDS coverage
  COMMENT "Generating HTML..."
)