import numpy as np
import matplotlib.pyplot as plt
import fxpmath as fxp
import os
import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock
from cocotb.binary import BinaryValue
from cocotb.queue import Queue
from cocotb.handle import SimHandleBase
from cocotb.triggers import RisingEdge, ClockCycles
from scipy.signal import  butter, lfilter
import pathlib
import time


FXP_SIZE = cocotb.top.FXP_SIZE.value
FXP_FRAC = cocotb.top.FXP_FRAC.value
cutoff_freq = cocotb.top.cutoff_freq.value
sample_rate = cocotb.top.sample_rate.value
order = cocotb.top.order.value

# Рассчитываем нормированную частоту среза (относительно частоты Найквиста)
nyquist_freq = 0.5 * sample_rate
normalized_cutoff = cutoff_freq / nyquist_freq

# Создаем фильтр Баттерворта
b, a = butter(order, normalized_cutoff, btype='low', analog=False)

SIGNAL = np.random.rand(1000)

def make_fxp(value):
     return fxp.Fxp(value, signed=True, n_word=FXP_SIZE, n_frac=FXP_FRAC)

# Применение фильтра к сигналу 
def apply_filter(input_signal):
    return lfilter(b, a, input_signal)

CORRECT = apply_filter(SIGNAL)


async def reset(clk: SimHandleBase, rst: SimHandleBase):
    rst.value = 1
    for _ in range(3):
        await RisingEdge(clk)
    rst.value = 0
    await RisingEdge(clk)

async def send_data(clk: SimHandleBase, in_sample: SimHandleBase, in_valid: SimHandleBase):
     for i in SIGNAL:
          in_valid.value = BinaryValue(1)
          in_sample.value = BinaryValue(make_fxp(i).bin())
          await RisingEdge(clk)

async def receive_data(clk: SimHandleBase, sample_out: SimHandleBase, valid_out: SimHandleBase):
     i = 0
     array = []
     while i < len(SIGNAL):
          await RisingEdge(clk)
          if(valid_out.value.binstr != '0'):
               print('BINSTR', valid_out.value.binstr)
               i+=1
               array.append(float(make_fxp(0).from_bin(sample_out.value.binstr)))
     array = np.array(array)

     print("Mean difference:", np.abs(array - CORRECT).mean())
     print("Max difference:", np.abs(array - CORRECT).max())
     print("Min difference:", np.abs(array - CORRECT).min())

@cocotb.test
async def tester(dut):
     t_clk  = cocotb.start_soon(Clock(dut.clk, 3*len(CORRECT)).start()) 
     await reset(dut.clk, dut.rst)

     t_send = cocotb.start_soon(send_data(dut.clk, dut.in_sample, dut.i_valid))
     t_recv = cocotb.start_soon(receive_data(dut.clk, dut.out_sample, dut.o_valid))
     # t_save  = cocotb.start_soon(save_data(ready_samples))
     
     await Timer(1)

     await ClockCycles(dut.clk, 3*len(CORRECT))
