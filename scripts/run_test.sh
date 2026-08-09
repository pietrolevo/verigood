#!/bin/bash
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
