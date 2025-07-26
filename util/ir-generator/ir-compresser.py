import numpy as np
import scipy.io.wavfile as wv 
import scipy as sc
import fxpmath as fx
import os
import math 

ir_size = 64
print('IR size:', ir_size)

fxp_bits = 16
fxp_frac_bits = 12

ir_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), "ir\'s\\OwnHammer_412_MAR-CB_V30-CH_T2_Room.wav")


# @numba.jit
def msq_error(a: np.ndarray, b: np.ndarray) -> float:
     return np.square(a-b).mean()

def gen_freq(epochs: int = 10) -> float:
     for i in range(epochs):
          yield 10 * 2 ** i

def freq_analysis(arr: np.ndarray, slice: int = ir_size, div: float = 200) -> np.ndarray:
     values = []
     fft = np.fft.fft(arr)
     for frequence in gen_freq():
          b = np.sin(np.linspace(0, len(arr), len(arr)) / div * np.pi * frequence)
          amp = np.real(np.fft.ifft(np.fft.fft(b) * fft))
          values.append(amp[:slice])
     return np.array(values)


sample_rate, ir_sample = wv.read(ir_path)
ir_sample = ir_sample / np.max(ir_sample)

ir_fft = np.fft.fft(ir_sample)


meth = []

ir_zoom = sc.ndimage.zoom(ir_sample, [ir_size / len(ir_sample)])
ir_sel  = ir_sample[::len(ir_sample) // ir_size][:ir_size]
ir_first = ir_sample[:ir_size]

meth = [('zoom', ir_zoom), ('sel', ir_sel), ('first', ir_first)]

for i in range(1, len(ir_sample) // ir_size):
     meth.append((f'stepped_{i}', ir_sample[:ir_size] + ir_sample[ir_size*i: ir_size*(i+1)]))



ref_fr_analysis = freq_analysis(ir_sample)

meth = [(freq_analysis(arr), arr, name) for name, arr in meth]
meth = [(msq_error(ref_fr_analysis, i[0]), *i) for i in meth]
meth.sort()



colors = [100 * i for i in range(len(ref_fr_analysis))]
colors = [[(i/255)%1, (i/255/255) % 1, (i/255/255/255)%1] for i in colors]

for error, freq, ir, name in meth[:7]:
     print(name, error)

     # fig, axs = plt.subplots(len(freq))
     
     # for xs, col, ax, fr in zip(freq, colors, axs, gen_freq()): 
          # ax.set_title(str(fr), loc='right', color='green')
          # ax.plot(xs, color=col)
     # for xs, col, ax in zip(ref_fr_analysis, colors, axs):
          # ax.plot(xs, color=col, linestyle='dashed')
     # plt.show()



ir_output = meth[0][2]

def to_fxp(number: float) -> str:
     f = fx.Fxp(number, n_frac=fxp_frac_bits, n_int=fxp_bits - fxp_frac_bits)
     return str(fxp_bits) + '\'h' + f.hex()[3:].upper()

ir_output = np.fft.fft(ir_output)

rfxp_ir = list(map(to_fxp, np.real(ir_output)))
ifxp_ir = list(map(to_fxp, np.imag(ir_output)))

ir_output = rfxp_ir
addr_ln = int(math.ceil(math.log2(fxp_bits))) + 1

module = f'''`include "util.svh"

module ir_weights#(
\tparameter test_vector_len = {len(ir_output)},
\t\ttest_word_width =   {fxp_bits}
)(
// \toutput[{len(ir_output)-1}: 0][{fxp_bits-1}: 0] weights_re,
// \toutput[{len(ir_output)-1}: 0][{fxp_bits-1}: 0] weights_im

\tinput [{addr_ln-1}: 0] i_addr,
\toutput[{fxp_bits-1}: 0] o_weights_re,
\toutput[{fxp_bits-1}: 0] o_weights_im
);

\t`STATIC_CHECK(test_vector_len == {len(ir_output)}, "Invalid vector length, expected: {len(ir_output)}");
\t`STATIC_CHECK(test_word_width == {fxp_bits}, "Invalid word length, expected: {fxp_bits}");

'''

module += '''
\talways_comb begin
\t\tcase(i_addr)
'''
for i in range(len(rfxp_ir)):
     module += f'''\t\t\t{addr_ln}\'d{i}: begin 
\t\t\t\to_weights_re = {rfxp_ir[i]}; 
\t\t\t\to_weights_im = {ifxp_ir[i]}; 
\t\t\tend
'''
     # module += f'\tassign weights_re[{i}] = {rfxp_ir[i]};\n'
     # module += f'\tassign weights_im[{i}] = {ifxp_ir[i]};\n'

module += '''
\t\t\tdefault: begin
\t\t\t\to_weights_re = '0;
\t\t\t\to_weights_im = '0;
\t\t\tend
\t\tendcase
\tend
'''
module += "endmodule\n"

path = os.path.dirname(os.path.realpath(__file__)) # ir-generator
path = os.path.dirname(path) # util
path = os.path.dirname(path) # project
path = os.path.join(path, "rtl/generated/ir_weights.sv")

print("Writing:", path)
open(path, 'w').write(module)