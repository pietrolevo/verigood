#!/usr/bin/perl
#		VeriGood Testbench generation script with Verilator and GTest
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

use strict;
use warnings;
use File::Path qw(make_path);
use POSIX qw(strftime);

my $today = strftime "%Y-%m-%d", localtime;

my $module_name = $ARGV[0];
if (!$module_name) {
  die "Use: perl scripts/gen_tb.pl <module_name>\n";
}

make_path("tb");

my $tb_filename = "tb/test_${module_name}.cpp";

if (-e $tb_filename) {
  print "[WARNING] file '$tb_filename' already exists.\n";
  print "Overwrite it losing all code added manually? [y/N]: ";
  my $response = <STDIN>;
  chomp($response);
  
  if ($response !~ /^[yY]es|[yY]$/) {
    print "[EXIT] Operation deleted.\n";
    exit 0;
  }
}

my $capitalized = ucfirst($module_name);

my $template = <<"CPP";
/*
#============================================================================#
| file: $tb_filename
| author: <your_name>
| date: $today
| last update: <date_of_last_update>
| brief: Testbench for $module_name
|
| VeriGood Copyright (C) 2026 Pietro Alberto Levo
| This program comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
| This is free software, and you are welcome to redistribute it
| under certain conditions; type `show c' for details.
|
| Thank you for using VeriGood environment!
#============================================================================#
*/

#include <verilated.h>
#include "V${module_name}.h"
#include <gtest/gtest.h>
#include <verilated_vcd_c.h>
#include <verilated_cov.h>

#define PICOSEC 1
#define NANOSEC 1000
#define MICROSEC 100000

class ${capitalized}Test : public ::testing::Test {
  protected:
    V${module_name}* dut;
    VerilatedVcdC* tfp;
    vluint64_t sim_time = 0;

    const int CLK_PERIOD = 10;
    const int TIME_UNIT = NANOSEC;            
    const int CLK_STEP = ((CLK_PERIOD*TIME_UNIT) / 2);

    /* use these two functions if design only combinational */
    void step(vluint64_t step_time) {
      dut->eval();
      sim_time += step_time;
      if (tfp) tfp->dump(sim_time);
    }

    void wait_ns(unsigned int ns) {
      step(ns * TIME_UNIT);
    }

    /* use these other functions for designs with clock */
    void step_half_clock(void) {
      dut->clk = !dut->clk;
      dut->eval();
      sim_time += CLK_STEP;
      if (tfp) tfp->dump(sim_time);
    }

    void wait_cycles(unsigned int n) {
      for (unsigned int i = 0; i < n; i++) {
        step_half_clock();
        step_half_clock();
      }
    }

    void wait_posedge() {
      do {
        step_half_clock();
      } while (dut->clk != 1);
    }

    void wait_negedge() {
      do {
        step_half_clock();
      } while (dut->clk != 0);
    }

    bool wait_until_true(std::function<bool()> condition, unsigned int max_cycles = 1000) {
      unsigned int elapsed_cycles = 0;
      while (!condition() && (elapsed_cycles < max_cycles)) {
        wait_cycles(1);
        elapsed_cycles++;
      }
      return condition();
    }

    void SetUp() override {
      dut = new V${module_name};
      Verilated::traceEverOn(1);
      const ::testing::TestInfo* const test_info = ::testing::UnitTest::GetInstance()->current_test_info();
      std::string vcd_filename = std::string("waveform_${module_name}_") + test_info->name() + ".vcd";

      tfp = new VerilatedVcdC;
      dut->trace(tfp, 99);
      tfp->open(vcd_filename.c_str());
      tfp->set_time_unit("1ns");
      tfp->set_time_resolution("1ps");

      /* initial reset */


      /* end initial reset */

      dut->eval();
    }

    void TearDown() override {
      tfp->close();
      delete tfp;
      
      dut->final();
      delete dut;

      const ::testing::TestInfo* const test_info = ::testing::UnitTest::GetInstance()->current_test_info();
      std::string cov_filename = std::string("logs/coverage_${module_name}_") + test_info->name() + ".dat";
      VerilatedCov::write(cov_filename.c_str());
    }

};

TEST_F(${capitalized}Test, testName) {
  /* test body */

}

int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv);
  ::testing::InitGoogleTest(&argc, argv);

  auto result = RUN_ALL_TESTS();

  return result;
}
CPP

open(my $fh, '>', $tb_filename) or die "Impossible to open file '$tb_filename': $!";
print $fh $template;
close($fh);

print "[SUCCESS] Testbench template created: $tb_filename\n";
