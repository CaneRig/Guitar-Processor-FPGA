import numpy as np
import matplotlib.pyplot as plt
from scipy import signal

# Параметры фильтра
cutoff_freq = 10000.0  # Частота среза 10 кГц
sample_rate = 44100    # Частота дискретизации (стандартная для аудио)
order = 4              # Порядок фильтра (выше порядок = круче срез)

# Рассчитываем нормированную частоту среза (относительно частоты Найквиста)
nyquist_freq = 0.5 * sample_rate
normalized_cutoff = cutoff_freq / nyquist_freq

# Создаем фильтр Баттерворта
b, a = signal.butter(order, normalized_cutoff, btype='low', analog=False)

# Выводим коэффициенты фильтра
print("Коэффициенты числителя (b):", b)
print("Коэффициенты знаменателя (a):", a)

# Применение фильтра к сигналу (пример)
def apply_filter(input_signal):
    return signal.lfilter(b, a, input_signal)

# Генерация тестового сигнала (синусоида 1 кГц + 15 кГц)
t = np.linspace(0, 1.0, sample_rate)
signal_1khz = 0.5 * np.sin(2 * np.pi * 1000 * t)
signal_15khz = 0.5 * np.sin(2 * np.pi * 15000 * t)
input_signal = signal_1khz + signal_15khz

# Фильтрация сигнала
filtered_signal = apply_filter(input_signal)

# Визуализация результатов
plt.figure(figsize=(12, 8))

# Исходный сигнал
plt.subplot(3, 1, 1)
plt.plot(t[:500], input_signal[:500], 'b')
plt.title("Исходный сигнал (1 кГц + 15 кГц)")
plt.xlabel("Время [с]")
plt.grid(True)

# АЧХ фильтра
plt.subplot(3, 1, 2)
w, h = signal.freqz(b, a, worN=8000)
plt.plot(0.5 * sample_rate * w / np.pi, 20 * np.log10(np.abs(h)))
plt.axvline(cutoff_freq, color='r', alpha=0.5)  # Линия частоты среза
plt.title("АЧХ фильтра")
plt.xlabel("Частота [Гц]")
plt.ylabel("Амплитуда [дБ]")
plt.xlim(0, 20000)
plt.ylim(-60, 5)
plt.grid(True)

# Фильтрованный сигнал
plt.subplot(3, 1, 3)
plt.plot(t[:500], filtered_signal[:500], 'g')
plt.title("Фильтрованный сигнал")
plt.xlabel("Время [с]")
plt.grid(True)

plt.tight_layout()
plt.show()