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
SIGNAL = np.random.rand(100)
def make_fxp(value):
     return fxp.Fxp(value, signed=True, n_word=FXP_SIZE, n_frac=FXP_FRAC)
b, a = butter(order, normalized_cutoff, btype='low', analog=False)
a = list(map(make_fxp, a))
b = list(map(make_fxp, b))

# Применение фильтра к сигналу 
def apply_filter(input_signal):
     return lfilter(b, a, input_signal)
     ans = []
     x_q = [make_fxp(0) for _ in range(len(a))]
     y_q = [make_fxp(0) for _ in range(len(a)-1)]

     A = a[1:]

     dot = lambda x, y: sum(i*j for i, j in zip(x, y))

     for x in input_signal:
          x_q = [x] + x_q[:-1]

          y = (dot(x_q, b) - dot(y_q, A))

          y_q = [y] + y_q[:-1]
          ans.append(y)
     return ans

CORRECT = apply_filter(list(map(make_fxp, SIGNAL)))

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
     in_valid.value = BinaryValue('0')
     await RisingEdge(clk)

TESTED = False

async def receive_data(clk: SimHandleBase, sample_out: SimHandleBase, valid_out: SimHandleBase):
     global CORRECT
     i = 0
     array = []
     while i < len(SIGNAL):
          await RisingEdge(clk)
          if(valid_out.value.binstr != '0'):
               i+=1
               array.append(float(make_fxp(0).from_bin(sample_out.value.binstr)))
     array = np.array(array)
     CORRECT = CORRECT[-len(array):]
     error = np.abs(array - CORRECT)

     TESTED = True

     print("Parameters: ", a, b)
     print(list(map(float, SIGNAL)))
     print(list(map(float, CORRECT)))
     print(list(map(float, array)))
     print("Mean difference:", error.mean())
     print("Max difference:", error.max())
     print("Min difference:", error.min())

@cocotb.test
async def tester(dut):
     t_clk  = cocotb.start_soon(Clock(dut.clk, 3*len(CORRECT)).start()) 
     await reset(dut.clk, dut.rst)

     t_send = cocotb.start_soon(send_data(dut.clk, dut.in_sample, dut.i_valid))
     t_recv = cocotb.start_soon(receive_data(dut.clk, dut.out_sample, dut.o_valid))
     # t_save  = cocotb.start_soon(save_data(ready_samples))
     
     await Timer(1)

     await ClockCycles(dut.clk, 8*len(CORRECT))

     # assert TESTED, 'NO DATS RECIEVED'
