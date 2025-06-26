import cocotb
from cocotb.triggers import Timer
from cocotb.binary import BinaryValue
import random
import fxpmath as fxp

operand_size        = cocotb.top.operand_size.value
expansion_size      = cocotb.top.expansion_size.value

def generate(amount: int = 4000):
     min_value = - 2**(operand_size-1)
     max_value = 2**(operand_size - 1) - 1
     for _ in range(amount):
          yield random.randint(min_value, max_value)
     yield 0
     yield 1
     yield -1
def get_answer(value: int) -> str:
     return fxp.Fxp(value, signed=True, n_word=operand_size+expansion_size, n_frac=0).bin()

@cocotb.test
async def tester(dut):
     it = 0
     for i in generate():
          it+=1
          ans = get_answer(i)
          inp = fxp.Fxp(i, signed=True, n_word=operand_size, n_frac=0).bin()

          dut.inp.value = BinaryValue(inp)

          await Timer(1)

          result = dut.out.value.binstr

          assert result == ans, f'[FAIL] {it}) Expected: {result}, got: {ans}, input: {i}'
     print('[PASSED]')