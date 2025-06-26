import os
import argparse
from pathlib import Path

from cocotb.runner import get_runner

proj_path = Path(__file__).resolve().parent


def load_test_names() -> dict[str, str]:
     test_path = proj_path / 'sim' / 'cocotb'
     this_tests = test_path.glob('*/dut.sv')

     return dict(map(lambda x: (str(x.parent.name), x), this_tests))

def run_test(dut_path: str, testname = '$undefined$', waves=True, gui=True):
     sim = os.getenv("SIM", "icarus")
     rtl_path = proj_path/'rtl'
     incl_path = proj_path/'common'
     build_path = proj_path/'test'
     test_dir = Path(dut_path).parent

     sources = [
          *rtl_path.glob('utility/*/*.sv'),
          *rtl_path.glob('effects/*/*.sv'),
          *rtl_path.glob('generated/*/*.sv'),
     ]
     sources = list(map(lambda x: str(x), sources))
     sources.append(dut_path)

     headers = [
        *incl_path.rglob('*.svh'),
     ]
     
     runner = get_runner(sim)
     runner.build(
          verilog_sources=sources,
          includes=headers,
          hdl_toplevel="dut",
          always=True,
          build_dir=build_path
     )

     print(f'----------------TESTING: {testname}')
     runner.test(hdl_toplevel="dut", test_dir=test_dir, test_module="tester", waves=waves, gui=gui, build_dir=build_path)

def list_tests():

     tests = load_test_names().keys()
     print('Avalible tests: ')
     for i in tests:
          print('-\t', i)


if __name__ == "__main__":
     parser = argparse.ArgumentParser()
     parser.add_argument(
          '-l', '--list',
          action='store_true'
     )
     parser.add_argument(
          '-ta', '--testall',
          action='store_true'
     )
     parser.add_argument(
          '-t', '--test',
          default=None
     )

     args = parser.parse_args()

     if args.list:
          list_tests()
          exit()
     if args.testall:
          tests = load_test_names()
          for i in tests:
               run_test(tests[i])
          exit()
     if args.test != None:
          tests = load_test_names()
          run_test(tests[args.test])
          exit()
