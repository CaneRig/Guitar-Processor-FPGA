import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock
from cocotb.binary import BinaryValue
from cocotb.queue import Queue
from cocotb.handle import SimHandleBase
from cocotb.triggers import RisingEdge, ClockCycles
import fxpmath as fxp
import numpy as np
from scipy.io import wavfile

INPUT_PATH = 'sample.wav'
OUTPUT_PATH = 'output.wav'

bits_per_level      = cocotb.top.bits_per_level.value
bits_per_gain_frac  = cocotb.top.bits_per_gain_frac.value
fxp_size            = cocotb.top.fxp_size.value


freq, input_samples = wavfile.read(INPUT_PATH)
input_samples = (input_samples.astype(np.float32) / np.max(input_samples))[0]

def make_fxp(value):
     return fxp.Fxp(value, signed=True, n_word=bits_per_level, n_frac=bits_per_level)

async def send_data(clk: SimHandleBase, sample_in: SimHandleBase, logger):
     sample_id = 0
     for i in input_samples:
          sample_id += 1
          if sample_id % (freq // 2) == 0:
               logger.log(f'Sample: #{sample_id}')
          
          await RisingEdge(clk)
          sample_in.value = BinaryValue(make_fxp(i).bin())

async def receive_data(clk: SimHandleBase, sample_out: SimHandleBase):
     samples = []
     for _ in range(len(input_samples) + 1024):
          await RisingEdge(clk)
          samples.append(sample_out.value)
     samples = np.array([[float(make_fxp('b' + ''.join(i.binstr_))) for i in samples]])
     wavfile.write(OUTPUT_PATH, freq, samples)

@cocotb.test
async def tester(dut):
     corr_clk  = cocotb.start_soon(Clock(dut.clk, 10, units="ns").start()) 
     corr_send = cocotb.start_soon(send_data(dut.clk, dut.in_sample, dut._log))
     corr_reic = cocotb.start_soon(receive_data(dut.clk, dut.out_sample))
     
     await ClockCycles(dut.clk, 30)
