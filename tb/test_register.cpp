/*
#============================================================================#
| file: tb/test_register.cpp
| author: Pietro Alberto Levo
| date: 2026-08-08
| last update: 2026-09-28
| brief: Testbench for register
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
#include "Vregister.h"
#include <gtest/gtest.h>
#include <verilated_vcd_c.h>
#include <verilated_cov.h>

#define PICOSEC 1
#define NANOSEC 1000
#define MICROSEC 100000

class RegisterTest : public ::testing::Test {
  protected:
    Vregister* dut;
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
      dut = new Vregister;
      Verilated::traceEverOn(1);
      const ::testing::TestInfo* const test_info = ::testing::UnitTest::GetInstance()->current_test_info();
      std::string vcd_filename = std::string("waveform_register_") + test_info->name() + ".vcd";

      tfp = new VerilatedVcdC;
      dut->trace(tfp, 99);
      tfp->open(vcd_filename.c_str());
      tfp->set_time_unit("1ns");
      tfp->set_time_resolution("1ps");

      /* initial reset */
      dut->clk = 0;
      dut->rst_n = 0;
      dut->en = 0;
      dut->data_in = 0;
      wait_cycles(2);
      dut->rst_n = 1;
      /* end initial reset */

      dut->eval();
    }

    void TearDown() override {
      tfp->close();
      delete tfp;
      
      dut->final();
      delete dut;
      
      const ::testing::TestInfo* const test_info = ::testing::UnitTest::GetInstance()->current_test_info();
      std::string cov_filename = std::string("logs/coverage_register_") + test_info->name() + ".dat";
      VerilatedCov::write(cov_filename.c_str());
    }

};

TEST_F(RegisterTest, ResetBehavior) {
  dut->data_in = 0xA5;
  dut->en = 1;
  wait_cycles(2);

  dut->rst_n = 0;
  wait_posedge();
  
  ASSERT_EQ(dut->data_out, 0);

  dut->rst_n = 1;
  dut->en = 0;
  dut->data_in = 0x5A;
  wait_posedge();
  ASSERT_EQ(dut->data_out, 0);
}

TEST_F(RegisterTest, EnableAndLoad) {
  dut->en = 1;

  dut->data_in = 0x3C;
  wait_posedge();
  ASSERT_EQ(dut->data_out, 0x3C);

  dut->data_in = 0xC3;
  wait_posedge();
  ASSERT_EQ(dut->data_out, 0xC3);
}

TEST_F(RegisterTest, HoldWhenDisabled) {
  dut->en = 1;
  dut->data_in = 0x7F;
  wait_posedge();
  ASSERT_EQ(dut->data_out, 0x7F);

  dut->en = 0;
  dut->data_in = 0xFF;
  wait_posedge();
  wait_posedge();

  ASSERT_EQ(dut->data_out, 0x7F);
}

int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv);
  ::testing::InitGoogleTest(&argc, argv);

  auto result = RUN_ALL_TESTS();

  return result;
}
