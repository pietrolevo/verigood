#!/bin/bash
#		VeriGood run test script with Verilator and GTest
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

set -e

TARGET_MODULE=${1:-""}

echo "# Clean and configuration CMake "
mv rtl/top/* rtl/mods/.
mv rtl/mods/${TARGET_MODULE}.sv rtl/top/.

mkdir -p build
cd build

rm -rf tb/logs/coverage_*.dat logs/coverage_*.dat 2>/dev/null || true

if [ -n "$TARGET_MODULE" ]; then
  cmake .. -DTEST_MODULE="$TARGET_MODULE"
else
  cmake ..
fi

echo "# Compile and execute tests "
cmake --build . --parallel $(nproc)
ctest --output-on-failure

echo "# Coverage computation "
cmake --build . --target coverage

echo "# generating coverage report in html "
cmake --build . --target genhtml

echo "# Run complete, open in browser index.html to consult the coverage"
