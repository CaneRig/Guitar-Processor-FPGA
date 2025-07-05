import os
import argparse
from pathlib import Path
import shutil
from cocotb.runner import get_runner

proj_path = Path(__file__).resolve().parent
cocotb_tests_path = proj_path / 'sim' / 'cocotb'


def load_test_names() -> dict[str, str]:
     test_path = proj_path / 'sim' / 'cocotb'
     this_tests = test_path.glob('*/dut.sv')

     return dict(map(lambda x: (str(x.parent.name), x), this_tests))

def run_test(dut_path: str, testname = '$undefined$', waves=True, gui=True):
     sim = os.getenv("SIM", "icarus") 
     # sim = os.getenv("SIM", "questa") #modelsim
     rtl_path = proj_path/'rtl'
     incl_path = proj_path/'common'
     build_path = proj_path/'test'
     test_dir = Path(dut_path).parent

     sources = [
          *rtl_path.glob('utility/**/*.sv'),
          *rtl_path.glob('effects/**/*.sv'),
          *rtl_path.glob('generated/**/*.sv'),
     ]
     sources = list(map(lambda x: str(x), sources))
     sources.append(dut_path)

     headers = [
        incl_path,
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
     runner.test(hdl_toplevel="dut", test_module="tester", waves=waves, gui=gui, test_dir=test_dir)

def list_tests():

     tests = load_test_names().keys()
     print('Avalible tests: ')
     for i in tests:
          print('-\t', i)

def clear():
     cache_files = [
          *cocotb_tests_path.glob('*/dump.fst'),
          *cocotb_tests_path.glob('*/results.xml')
     ]
     cache_dirs = [
          *cocotb_tests_path.glob('*/__pycache__')
     ]
     for file in cache_files:
          print('Removing:', file)
          os.remove(file)
     for dire in cache_dirs:
          print('Removing:', dire)
          shutil.rmtree(dire)

     print('Removed', len(cache_files), 'files,', len(cache_dirs), 'directories')

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
     parser.add_argument(
          '--clear',
          action='store_true'
     )

     args = parser.parse_args()

     if args.clear:
          clear()
          exit()
     elif args.list:
          list_tests()
          exit()
     elif args.testall:
          tests = load_test_names()
          for i in tests:
               run_test(tests[i])
          exit()
     elif args.test != None:
          tests = load_test_names()
          run_test(tests[args.test])
          exit()

     print('Nothing to do')