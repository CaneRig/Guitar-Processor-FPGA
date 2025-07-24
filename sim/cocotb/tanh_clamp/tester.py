import cocotb
from cocotb.triggers import Timer
from cocotb.binary import BinaryValue
import random
import fxpmath as fxp
import math
import numpy as np

TEST_COUNT          = 10_000
ESP = 1e-1

fxp_size            = cocotb.top.fxp_size.value
fxp_frac            = cocotb.top.fxp_frac.value


FXP_MIN = -2 ** (fxp_size - fxp_frac)
FXP_MAX = -FXP_MIN - 1

def bin2int(b: str) -> int:
     if b[0] == '1':
          b = -(int(''.join(list(map(lambda x: {'0': '1', '1': '0'}[x], b))), 2) + 1)
     else:
          b = int(b, 2)
     return b

def make_fixed(x: float | fxp.Fxp) -> fxp.Fxp:
     return fxp.Fxp(x, signed=True, n_word=fxp_size, n_frac=fxp_frac)
def rmse(x, y): return np.sqrt(((x-y)**2).mean())

FXP_EPS = make_fixed(ESP)

def dist_clamp(x: fxp.Fxp) -> fxp.Fxp:
     true_value = math.tanh(float(x))
     fxp_value =  make_fixed(true_value)

     assert abs(true_value - float(fxp_value)) <= ESP, 'Overflow error'

     return fxp_value

def generate_tests():
     for _ in range(TEST_COUNT):
          yield make_fixed(random.uniform(FXP_MIN, FXP_MAX))     
     yield make_fixed(FXP_MIN)
     yield make_fixed(FXP_MAX)

     yield make_fixed(FXP_MIN+1)
     yield make_fixed(FXP_MIN+2)
     yield make_fixed(FXP_MIN+3)

     yield make_fixed(FXP_MAX-1)
     yield make_fixed(FXP_MAX-2)
     yield make_fixed(FXP_MAX-3)
     yield make_fixed(0)
     yield make_fixed(-0)
     yield make_fixed(1)
     yield make_fixed(-1)

@cocotb.test
async def tester(dut):
     in_sample = dut.i_sample
     out_sample = dut.o_sample
     it = 0

     expected = []
     recieved = []

     for value in generate_tests():
          it += 1

          in_sample.value = BinaryValue(value.bin())
          await Timer(1)

          answer = make_fixed(0)
          answer.val = bin2int(out_sample.value.binstr)
          answer = make_fixed(answer)
          result = dist_clamp(value)
          
          if it % (TEST_COUNT // 20) == 0:
               print(f'Test {it}/{TEST_COUNT} has done')

          expected.append(float(result))
          recieved.append(float(answer))

          assert abs(float(result) - float(answer)) <= FXP_EPS, f'[FAIL] {it}) Expected: {result}, got: {answer}, input: {value}'
     
     expected, recieved = np.array(expected), np.array(recieved)

     print('Avg error(rmse): \t', rmse(expected, recieved))
     print('Avg error(mean): \t', np.abs(expected - recieved).mean())
     print('Max error      : \t', np.abs(expected - recieved).max())
     print('Min error      : \t', np.abs(expected - recieved).min())

     print('[PASSED]')