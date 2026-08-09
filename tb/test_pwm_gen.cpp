/*
#============================================================================#
| file: tb/test_pwm_gen.cpp
| author: Pietro Alberto Levo
| date: 2026-08-09
| last update: 2026-08-09
| brief: Testbench for pwm_gen
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
#include "Vpwm_gen.h"
#include <gtest/gtest.h>
#include <verilated_vcd_c.h>
#include <verilated_cov.h>

#define PICOSEC 1
#define NANOSEC 1000
#define MICROSEC 100000

class pwm_genTest : public ::testing::Test {
  protected:
    Vpwm_gen* dut;
    VerilatedVcdC* tfp;
    vluint64_t sim_time = 0;

    const int CLK_PERIOD = 10;
    const int TIME_UNIT = MICROSEC;            
    const int CLK_STEP = ((CLK_PERIOD*TIME_UNIT) / 2);

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

    void wait_ns(unsigned int n) {
      sim_time += n;
      if (tfp) tfp->dump(sim_time);
    }

    void SetUp() override {
      dut = new Vpwm_gen;
      Verilated::traceEverOn(1);
      const ::testing::TestInfo* const test_info = ::testing::UnitTest::GetInstance()->current_test_info();
      std::string vcd_filename = std::string("waveform_pwm_gen_") + test_info->name() + ".vcd";

      tfp = new VerilatedVcdC;
      dut->trace(tfp, 99);
      tfp->open(vcd_filename.c_str());
      tfp->set_time_unit("1ns");
      tfp->set_time_resolution("1ps");

      /* initial reset */
      dut->rst_n = 0;
      dut->en = 0;
      dut->duty_in = 0;
      wait_cycles(2);
      dut->rst_n = 1;
      wait_cycles(1);
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

TEST_F(pwm_genTest, testDutyCycle) {
  dut->en = 1;
  dut->duty_in = 64;
  clk_process();
  for (int i = 0; i < 512; i++) {
    if (i < 63) ASSERT_EQ(dut->pwm_out, 1);
    if (i > 63 && i < 255) ASSERT_EQ(dut->pwm_out, 0);
    clk_process();
  }

  wait_cycles(2);
  wait_ns(13);
}

int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv);
  ::testing::InitGoogleTest(&argc, argv);

  auto result = RUN_ALL_TESTS();

  VerilatedCov::write("logs/coverage_pwm_gen.dat");
  return result;
}
