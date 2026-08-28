# VeriGood

A workspace for developing SystemVerilog designs, simulating them with Verilator, and running unit tests using Google Test.

---

## Features

* **C++ Testing:** Write unit tests using Google Test (GTest).
* **Automated Builds:** Fast C++ compilation using CMake.
* **Code Generator:** Automatically create C++ testbench templates.
* **Coverage Analysis:** Measure code coverage and export reports to HTML.
* **Waveform Viewer:** Access to `.vcd` files via GTKWave.

---

## Prerequisites & Setup

Requires a Linux environment (Ubuntu/WSL) with `cmake`, `g++`, and `perl`.

Run the setup script to install dependencies automatically:
```bash
./scripts/setup.sh
```

---

## Repository Structure

```text
verigood/
├── CMakeLists.txt        # Root build configuration
├── rtl/
│   ├── top/              # Top-level RTL modules
│   └── mods/             # Sub-modules
├── tb/
│   ├── CMakeLists.txt    # Testbench build configuration
│   └── test_<module>.cpp # C++ Google Test files
└── scripts/              # Helper scripts
```

---

## How to Use

### 1. Generate a Testbench
To create a C++ testbench template for a module named `my_module`:
```bash
perl scripts/gen_tb.pl my_module
```

### 2. Build and Run Tests
To compile, run tests, and generate coverage for a specific module:
```bash
./scripts/run_test.sh my_module
```

### 3. View Coverage Report
Open the HTML coverage report in your browser:
```bash
./scripts/view_coverage.sh
```

### 4. View Waveforms
Interactively select and open recorded `.vcd` waveform files in GTKWave:
```bash
./scripts/view_waveform.sh
```

### 5. Clean Build Directory
Delete build artifacts:
```bash
./scripts/clean.sh
```

---

## License

Distributed under the **GNU General Public License v3.0 (GPLv3)**.  
VeriGood Copyright (C) 2026 Pietro Alberto Levo
