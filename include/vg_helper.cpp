/*
  VeriGood Testbench environment with Verilator and GTest
  Copyright (C) 2026  Pietro Alberto Levo

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

#include "vg_helper.h"

vluint64_t sim_time = 0;

void clk_process(unsigned int clk_period) {
  unsigned int step = clk_period / 2;
  dut->clk = 0;         /* low half cycle */
  dut->eval();
  sim_time += step;
  if (tfp) { tfp->dump(sim_time); }

  dut->clk = 1;         /* high half cycle */
  dut->eval();
  sim_time += step;
  if (tfp) { tfp->dump(sim_time); }
}


void wait_for_rising_edge(unsigned int clk_period) {
  unsigned int prev_clk = dut->clk;

  while(1) {
    clk_process(clk_period);
    if ((prev_clk == 0) && (dut->clk == 1)) {
      break;
    }
    prev_clk = dut->clk;
  }
}


void wait_for_falling_edge(unsigned int clk_period) {
  unsigned int prev_clk = dut->clk;

  while(1) {
    clk_process(clk_period);
    if ((prev_clk == 1) && (dut->clk == 0)) {
      break;
    }
    prev_clk = dut->clk;
  }
}


void wait_cycles(unsigned int n, unsigned int clk_period) {
  for (unsigned int i = 0; i < n; i++) {
    clk_process(clk_period);
  }
}