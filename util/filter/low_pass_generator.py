# БИХ-фильтра низких частот (ФНЧ)| фильтр Баттерворта

import numpy as np
import matplotlib.pyplot as plt
from scipy import signal
import fxpmath as fxp
import os

# Параметры фильтра
cutoff_freq = 10000.0  # Частота среза 10 кГц
sample_rate = 48000*3    # Частота дискретизации (стандартная для аудио)
order = 4              # Порядок фильтра (выше порядок = круче срез)

# Рассчитываем нормированную частоту среза (относительно частоты Найквиста)
nyquist_freq = 0.5 * sample_rate
normalized_cutoff = cutoff_freq / nyquist_freq

# Создаем фильтр Баттерворта
b, a = signal.butter(order, normalized_cutoff, btype='low', analog=False)


'''
sum a[i]*y[n-i] = sum b[i]*x[n-i], for i in range(len(a))
'''

fxp_size = 16
fraction_part = 12

def to_fxp(x: float) -> str:
     return f'{'-' if x<0 else ''}{fxp_size + fraction_part}\'b{fxp.Fxp(abs(x), n_word=fxp_size+fraction_part, n_frac=fraction_part).bin()}'

assert a[0] == 1, 'Sowwy, i dont reawy to generate code with non one a[0] Uwu'


code = f'''
module preprocess_hipass(
\tinput clk,
\tinput rst,
\tinput i_valid,
\toutput o_valid,
\tinput  signed[FXP_SIZE-1: 0] i_sample,
\toutput signed[FXP_SIZE-1: 0] o_sample
);

\tlocalparam FXP_SIZE = {fxp_size};
\tlocalparam FXP_FRAC = {fraction_part};
\tlocalparam COMP_SIZE = FXP_SIZE + FXP_FRAC; // size of numbers in computations
\t
\t// for more precision
\twire signed[COMP_SIZE-1: 0] wide_sample;
\tsigned_expand#(
\t     .operand_size  (FXP_SIZE),
\t     .expansion_size(FXP_FRAC) 
\t) ins_sample_expand (
\t     .in(i_sample),
\t     .out(wide_sample)
\t);
\t
\t
\twire[COMP_SIZE-1: 0] y_next;
'''

for i in range(len(a)-1):
     code += f"\tlogic[COMP_SIZE-1:0] y_{i};\n"
for i in range(len(a)):
     code += f"\tlogic[COMP_SIZE-1:0] x_{i};\n"
code += '\n\tassign x_0 = wide_sample;\n'


code += f'\talways_ff@(posedge clk) begin\n'
for i in range(len(a)-1):
     code += f'''
\t\tif(rst) y_{i} <= \'0;
\t\telse if(i_valid) y_{i} <= {'y_next' if i == 0 else f'y_{i-1}'};
'''
code += f'\tend\n\n'

code += f'\talways_ff@(posedge clk) begin\n'
for i in range(1, len(a)):
     code += f'''
\t\tif(rst) x_{i} <= \'0;
\t\telse if(i_valid) x_{i} <= x_{i-1};
'''
code += f'\tend\n'

for i in range(len(a)):
     if i!=0:
          code += f'\tlocalparam a_{i} = {to_fxp(a[i])};\n'
     code += f'\tlocalparam b_{i} = {to_fxp(b[i])};\n'

code += '\n'*3

code += '\tassign y_next = $signed('
code += ' + '.join(f'b_{i} * x_{i}' for i in range(len(a))) + ' - ' + ' - '.join(f'a_{i} * y_{i-1}' for i in range(1, len(a)))
code += ') >>> FXP_FRAC;\n'
code += f'''
\tassign o_sample = y_0;

\tlogic[1:0] valid_reg;
\talways_ff @(posedge clk) begin
\t\tif (rst) 
\t\t\tvalid_reg <= '0;
\t\telse if(i_valid)
\t\t\tvalid_reg <= {{1\'b1, valid_reg[0]}};
\t\telse 
\t\t\tvalid_reg <= {{1\'b0, valid_reg[0]}};
\tend
\tassign o_valid = valid_reg[1];
'''
code += 'endmodule\n'

path = os.path.dirname(os.path.realpath(__file__)) # filter
path = os.path.dirname(path) # util
path = os.path.dirname(path) # project
path = os.path.join(path, "rtl/generated/filters/preprocess_hipass.sv")
open(path, 'w').write(code)
print('Wrote', len(code), 'b')
