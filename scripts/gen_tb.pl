#!/usr/bin/perl
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

class ${module_name}Test : public ::testing::Test {
  protected:
    V${module_name}* dut;
    VerilatedVcdC* tfp;
    vluint64_t sim_time = 0;

    const int CLK_PERIOD = 10; /* ns */
    const int CLK_STEP = CLK_PERIOD / 2;

    void clk_process(void) {
      dut->clk = 0;           // low half cycle
      dut->eval();
      sim_time += CLK_STEP;
      if (tfp) tfp->dump(sim_time);

      dut->clk = 1;           // high half cycle
      dut->eval();    
      sim_time += CLK_STEP;
      if (tfp) tfp->dump(sim_time);
    }

    void wait_cycles(unsigned int n) {
      for (unsigned int i = 0; i < n; i++) {
        clk_process();
      }
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
      tfp->dump(sim_time++);
    }

    void TearDown() override {
      tfp->close();
      delete tfp;
      
      dut->final();
      delete dut;
    }

};

TEST_F(${capitalized}, testName) {
  /* test body */

}

int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv);
  ::testing::InitGoogleTest(&argc, argv);

  auto result = RUN_ALL_TESTS();

  VerilatedCov::write("logs/coverage_${module_name}.dat");
  return result;
}
CPP

open(my $fh, '>', $tb_filename) or die "Impossible to open file '$tb_filename': $!";
print $fh $template;
close($fh);

print "[SUCCESS] Testbench template created: $tb_filename\n";