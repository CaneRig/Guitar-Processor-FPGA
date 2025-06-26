import cocotb
from cocotb.triggers import Timer
from cocotb.binary import BinaryValue
import fxpmath as fxp
import random
import numpy as np


fractional_size     = cocotb.top.fractional_size.value
operand_size        = cocotb.top.operand_size.value
expansion_size      = cocotb.top.expansion_size.value

def generate_tests(amount: int = 1000_000):
     fxp_range = 2 ** (operand_size - fractional_size - 1) ** 0.5
     for _ in range(amount):
          a_fp = (random.random()*2-1) * fxp_range
          b_fp = (random.random()*2-1) * fxp_range

          a_fxp = fxp.Fxp(a_fp, n_signed=True, n_word=operand_size, n_frac=fractional_size)
          b_fxp = fxp.Fxp(b_fp, n_signed=True, n_word=operand_size, n_frac=fractional_size)
          result = (a_fxp * b_fxp)
          # result = fxp.Fxp(result, n_signed=True, n_word=operand_size, n_frac=fractional_size)

          yield (a_fxp, b_fxp, result)
          
          
@cocotb.test
async def tester(dut):
     it = 0
     errors = []
     eps = fxp.Fxp(0.001, n_signed=True, n_word=operand_size, n_frac=fractional_size)
     for a, b, result in generate_tests():
          it+=1
          dut.a.value = BinaryValue(a.bin())
          dut.b.value = BinaryValue(b.bin())
          await Timer(1)

          answer = fxp.Fxp(0, signed=True, n_word=operand_size*2, n_frac=fractional_size)
          answer.val = dut.c.value.value

          assert abs(answer - result) < eps, f"[FAIL] {it}) Error expected {result}, got {answer}, when {a}*{b}"
          errors.append(float(abs(answer-result)))
     print('Average error:', np.mean(errors))
     print('[PASSED]')
