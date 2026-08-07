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
#include <verilated_fst_c.h>
#include <verilated_cov.h>

TEST(${capitalized}, Basic) {
  Verilated::traceEverOn(true);

  V${module_name} dut;
  VerilatedFstC* tfp = new VerilatedFstC;

  dut.trace(tfp, 99);
  tfp->open("wave_${module_name}.fst");

  dut.eval();
  tfp->dump(0);

  tfp->close();
  delete tfp;

  SUCCEED();
}

int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv);
  ::testing::InitGoogleTest(&argc, argv);

  int result = RUN_ALL_TESTS();

  VerilatedCov::write("logs/coverage_${module_name}.dat");

  return result;
}
CPP

open(my $fh, '>', $tb_filename) or die "Impossible to open file '$tb_filename': $!";
print $fh $template;
close($fh);

print "[SUCCESS] Testbench template created: $tb_filename\n";