import numpy as np
import matplotlib
# from sklearn.metrics import root_mean_squared_error
from functools import lru_cache
from math import *
from tabulate import tabulate

@lru_cache
def get_angle(it: int) -> float:
     return atan(4*2**-it)

@lru_cache
def get_tan(it: int) -> float:
     return tan(get_angle(it))
@lru_cache
def get_constant(it: int) -> float:
     p = 1.0
     for i in range(it + 1):
          p *= cos(get_angle(i))
     return p

def cordic_sin(theta: float, points: int = 16) -> float:
     x, y, z = 1.0, 0.0, theta
     K = get_constant(points)

     table = []
     for i in range(0, points+1):
          direction = 1 if z > 0 else -1
          tg = get_tan(i)       # 2^-i
          angle = get_angle(i)  # arctan(2^-i)

          x_next = x - direction * tg * y
          y_next = y + direction * tg * x
          z -= direction * angle

          # Store iteration details for debugging
          table.append((i, direction, -direction * angle, z, theta, z))
          x, y = x_next, y_next

     x, y = x * K, y * K
     # Print iteration table
     # print(tabulate(table, headers=['id', 'dir', 'dz', 'z', 'target', 'error']))
    
     # Return sin(theta) = y / K
     return y

ANGLE = np.pi/3

print(cordic_sin(ANGLE))
print(sin(ANGLE))


ls = []
for i in np.linspace(-np.pi, np.pi, 100):
     a, b = cordic_sin(i), sin(i)

     ls.append((i, a, b, abs(a-b)))
print(tabulate(ls, headers=['arg', 'cordic', 'correct', 'err']))