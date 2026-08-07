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

#ifndef __VG_HELPER_H__
#define __VG_HELPER_H__

#include <verilated.h>
#include <gtest/gtest.h>
#include "verilated_cov.h"
#include <string>

extern vluint64_t sim_time;

void clk_process(unsigned int clk_period);
void wait_for_rising_edge(unsigned int clk_period);
void wait_for_falling_edge(unsigned int clk_period);
void wait_cycles(unsigned int n, unsigned int clk_period);

#endif