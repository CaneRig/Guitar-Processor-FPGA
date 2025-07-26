import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock
from cocotb.binary import BinaryValue
from cocotb.queue import Queue
from cocotb.handle import SimHandleBase
from cocotb.triggers import RisingEdge, ClockCycles
import fxpmath as fxp
import numpy as np
import pathlib
import time
from scipy.io import wavfile

TEST_PATH      = pathlib.Path(__file__).parent
INPUT_PATH     = str(TEST_PATH / 'sample.wav')
OUTPUT_PATH    = str(TEST_PATH / 'output.wav')

GAIN_VALUE = 20

bits_per_level      = cocotb.top.bits_per_level.value
bits_per_gain_frac  = cocotb.top.bits_per_gain_frac.value
fxp_size            = cocotb.top.fxp_size.value


freq, input_samples = wavfile.read(INPUT_PATH)
input_samples = input_samples[:, 0]
input_samples = input_samples[:len(input_samples)//10]

# input_samples = np.linspace(-1, 1, 1024)

input_samples = input_samples.astype(np.float32)
input_samples = (input_samples / np.abs(input_samples).max()) [:1024]

print(f'File \"{INPUT_PATH}\" is opened with {input_samples.shape} size')

def make_fxp(value):
     return fxp.Fxp(value, signed=True, n_word=fxp_size, n_frac=bits_per_level)

def bin2int(b: str) -> int:
     if b[0] == '1':
          b = -(int(''.join(list(map(lambda x: {'0': '1', '1': '0'}[x], b))), 2) + 1)
     else:
          b = int(b, 2)
     return b

print(f'Normalized audion to {make_fxp(input_samples.max())}')

async def reset(clk: SimHandleBase, rst: SimHandleBase):
    rst.value = 1
    for _ in range(3):
        await RisingEdge(clk)
    rst.value = 0
    await RisingEdge(clk)

async def send_data(clk: SimHandleBase, sample_in: SimHandleBase, valid: SimHandleBase, logger):
     sample_id = 0

     start_time = time.time()
     for i in input_samples:
          valid.value = BinaryValue('1')
          sample_id += 1
          if sample_id % (freq // 2) == 0:
               current_time = time.time()
               elapsed = current_time - start_time
               speed = sample_id / elapsed
               print(f'Sample: #{sample_id}/#{len(input_samples)}, speed: {speed: .2f} sample/s, remained: {(len(input_samples) - sample_id) / speed: .2f} s')
          
          await RisingEdge(clk)
          sample_in.value = BinaryValue(make_fxp(i).bin())
     # valid.value = BinaryValue('0')

async def receive_data(clk: SimHandleBase, sample_out: SimHandleBase, valid: SimHandleBase, queue: Queue):
     for _ in range(len(input_samples) + 1024):
          # while(valid.value.binstr != '1'):
               # await RisingEdge(clk)

          value = sample_out.value.binstr
          queue.put_nowait(value)
          await RisingEdge(clk)
     await RisingEdge(clk)
     queue.put_nowait('END')

async def save_data(queue: Queue):
     samples = []
     delay_stopped = False
     delay_counter = 0

     while True:
          value = await queue.get()

          if value == 'END':
               break
          if 'x' in value:
                print('\'x is found in output pin -> skipping sample')
                if not delay_stopped:
                    delay_counter += 1
          else:
               fvalue = fxp.Fxp(0, signed=True, n_word=fxp_size, n_frac=bits_per_level).from_bin(value)
               samples.append(float(fvalue))
     print('Max samples: ', max(samples))
     samples = (np.array(samples) * 2**15).astype(np.int16)
     wavfile.write(OUTPUT_PATH, freq, samples)
     print(f'File saved at \"{OUTPUT_PATH}\", total samples: {len(samples)}, delay: {delay_counter}')


@cocotb.test
async def tester(dut):
     ready_samples = Queue()

     # dut.gain.value = BinaryValue(fxp.Fxp(GAIN_VALUE, signed=True, n_word=11, n_frac=bits_per_gain_frac).bin())
     dut.gain.value = BinaryValue('00000101111')

     t_clk  = cocotb.start_soon(Clock(dut.clk, 2*len(input_samples)).start()) 

     dut.in_sample = BinaryValue('0' * fxp_size)
     await RisingEdge(dut.clk)

     await reset(dut.clk, dut.rst)
     
     t_send = cocotb.start_soon(send_data(dut.clk, dut.in_sample, dut.i_valid, dut._log))
     t_recv = cocotb.start_soon(receive_data(dut.clk, dut.out_sample, dut.o_valid, ready_samples))
     # t_save  = cocotb.start_soon(save_data(ready_samples))
     
     await Timer(1)

     await save_data(ready_samples)

     # wait for the sender/receiver to finish
     # await t_send
     # await t_recv

     # signal the saver to wrap up and then wait for it
     # ready_samples.put_nowait("END")
     # await t_save

     # optional: give a few more cycles for safety
     await ClockCycles(dut.clk, 10)
