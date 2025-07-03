import cocotb
from cocotb.triggers import Timer
from cocotb.binary import BinaryValue
import random
import fxpmath as fxp

TEST_COUNT          = 10_000
fxp_size            = cocotb.top.fxp_size.value
bits_per_level      = cocotb.top.bits_per_level.value

FXP_MIN = -2 ** (fxp_size - bits_per_level)
FXP_MAX = -FXP_MIN - 1

def bin2int(b: str) -> int:
     if b[0] == '1':
          b = -(int(''.join(list(map(lambda x: {'0': '1', '1': '0'}[x], b))), 2) + 1)
     else:
          b = int(b, 2)
     return b

def make_fixed(x: float | fxp.Fxp) -> fxp.Fxp:
     return fxp.Fxp(x, signed=True, n_word=fxp_size, n_frac=bits_per_level)

def dist_clamp(x: fxp.Fxp) -> fxp.Fxp:
     x = make_fixed(x)

     ONE_LEVEL = make_fixed(1)
     CLAMPED_LEVEL = make_fixed(3/4)

     if x <= -ONE_LEVEL:
          return -CLAMPED_LEVEL
     elif x >= ONE_LEVEL:
          return CLAMPED_LEVEL
     else:
          return make_fixed((3*x + x*x*x)/4)

def generate_tests():
     for _ in range(TEST_COUNT):
          yield make_fixed(random.uniform(FXP_MIN, FXP_MAX))     
     yield make_fixed(FXP_MIN)
     yield make_fixed(FXP_MAX)
     yield make_fixed(0)
     yield make_fixed(-0)
     yield make_fixed(1)
     yield make_fixed(-1)

@cocotb.test
async def tester(dut):
     in_sample = dut.i_sample
     out_sample = dut.o_sample
     it = 0

     for value in generate_tests():
          it += 1

          in_sample.value = BinaryValue(value.bin())
          await Timer(1)

          answer = make_fixed(0)
          answer.val = bin2int(out_sample.value.binstr)
          result = dist_clamp(value)
          
          if it % (TEST_COUNT // 20) == 0:
               print(f'Test {it}/{TEST_COUNT} has done')

          assert result == answer, f'[FAIL] {it}) Expected: {result}, got: {answer}, input: {value}'
     print('[PASSED]')